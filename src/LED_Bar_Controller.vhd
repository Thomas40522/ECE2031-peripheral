-- LED BAR CONTROLLER
-- Controls the 10 LED's on the DE10 board to visually represent 16-bit values with a bar that fills up
-- Updated 23MAR2025

-- Inclusions
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity block defines the I/O of design; how the hardware will interface with the outside world
entity LED_Bar_Controller is
	port(
	resetn      :in   std_logic;				-- active low reset
	clock			:in	std_logic;		-- 100KHz Clock is used for PWM control of LED brightness
	led_write	:in	std_logic;                      -- signal to allow the value to be displayed to be updated
	mval_write  :in   std_logic;				-- signal to allow the max value to be updated
	data_in		:in	std_logic_vector(15 downto 0);	-- 16-bit value from SCOMP
	data_out		:out	std_logic_vector(15 downto 0) 	-- LED output
	);
end LED_Bar_Controller;

-- Architecture block defines the internal behavior/structure of entity
architecture Behavior of LED_Bar_Controller is
	-- Typedef
	type 		int_array is array(0 to 9) of integer;
	type gamma_array is array(0 to 255) of integer;
	
	-- Signals (Variables)
	signal 	led_order : int_array;					-- Array that holds the order the LED's will illuminate in
	signal 	input_mag : integer;					-- Absolute value of input
	signal	fade_led	 : integer;				-- Reflects which LED needs to be driven by PWM
	signal	full_out	 : std_logic_vector(9 downto 0); 	-- Vector representing which LED's are being fully illuminated
	signal	pwm_out	 : std_logic_vector(9 downto 0); 		-- Vector representing which LED's are being partially illuminated
	signal   brightness_index : integer := 0;			-- Used to index into gamma table for the faded LED
	signal	clk_count : integer := 0;				-- Counter used for PWM logic
	signal   max_val   : integer := 1000;				-- Relative max value that is represented by the bar
	signal   led_range : integer := (max_val / 10);			-- The "amount" that each LED represents (used for logic below)
	
	-- Constants
	constant gamma_table : gamma_array := (				-- Gamme table with gamma values
0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,
1,  1,  1,  1,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  2,  2,
2,  3,  3,  3,  3,  3,  3,  3,  4,  4,  4,  4,  4,  5,  5,  5,
5,  6,  6,  6,  6,  7,  7,  7,  7,  8,  8,  8,  9,  9,  9, 10,
10, 10, 11, 11, 11, 12, 12, 13, 13, 13, 14, 14, 15, 15, 16, 16,
17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 24, 24, 25,
25, 26, 27, 27, 28, 29, 29, 30, 31, 32, 32, 33, 34, 35, 35, 36,
37, 38, 39, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 50,
51, 52, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 66, 67, 68,
69, 70, 72, 73, 74, 75, 77, 78, 79, 81, 82, 83, 85, 86, 87, 89,
90, 92, 93, 95, 96, 98, 99,101,102,104,105,107,109,110,112,114,
115,117,119,120,122,124,126,127,129,131,133,135,137,138,140,142,
144,146,148,150,152,154,156,158,160,162,164,167,169,171,173,175,
177,180,182,184,186,189,191,193,196,198,200,203,205,208,210,213,
215,218,220,223,225,228,231,233,236,239,241,244,247,249,252,255

);
	
begin
	-- This process only runs when a value is written to the LED bar or when the max value is updated
	process(led_write, mval_write, resetn)
	begin
		-- Reset necessary signals when reset is active (low)
		if(resetn = '0') then
			input_mag <= 0;
			full_out <= "0000000000";
		-- Only update the LED values when led_write is high
		elsif(led_write = '1') then
			-- Calculate absolute value of input
			input_mag <= abs(to_integer(signed(data_in)));
			-- Swap the illumination order if input is negative
			if(data_in(15) = '0') then
				led_order <= (9, 8, 7, 6, 5, 4, 3, 2, 1, 0);
			else
				led_order <= (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
			end if;	
			-- For loop creates parallel circuitry for each LED
			for i in 0 to 9 loop
				-- Determine which LED's are fully-illuminated
				if(input_mag >= led_range*(i+1)) then
					full_out(led_order(i)) <= '1';
				else
					-- Don't drive LED if it isn't fully illuminated to allow PWM to drive
					full_out(led_order(i)) <= '0';
					-- If LED isn't illuminated, check if the input lies in its range
					if(input_mag >= led_range*i) then
						fade_led <= i;
					end if;
				end if;
			end loop;
		-- If mval_write is active, then we update our relative max value
		elsif (mval_write = '1') then
			max_val <= abs(to_integer(signed(data_in)));
		end if;
	end process;
	
	-- This process controls the counter used by the PWM process
	process(clock)
	begin
		-- Clk counter resets after 100 clocks
		if rising_edge(clock) then
			if(clk_count >= 255) then
				clk_count <= 0;
			else
				clk_count <= clk_count + 1;
			end if;
		end if;
	end process;
	
	-- This process generates the PWM signal to control fade_led
	process(clk_count, resetn)
	begin
		-- PWM output vector defaults to 0's for undriven components
		pwm_out <= (others => '0');
		-- Reset necessary pwm signals on reset
		if(resetn = '0') then
			pwm_out <= "0000000000";
		-- Ensure pwm_out holds proper value (1) when the threshold is reached for a perfectly divisible input
		elsif (input_mag mod led_range = 0 and input_mag /= 0) then
			pwm_out(led_order(input_mag / led_range - 1)) <= '1';
		else
			-- calculate brightness percentage, scaled by 255, to index into the gamma table
			brightness_index <= ((input_mag mod led_range) * 255) / led_range;
			 if (brightness_index > 255) then
			     brightness_index <= 255;
			 end if;
			-- PWM logic using the gamme table
			if(clk_count < gamma_table(brightness_index)) then
				pwm_out(led_order(fade_led)) <= '1';
			else
				pwm_out(led_order(fade_led)) <= '0';
			end if;
		end if;
	end process;
	
	-- Combine fully and partially driven LED vectors into one output vector
	data_out(9 downto 0) <= full_out or pwm_out;
	
end Behavior;
