-- LED BAR CONTROLLER
-- Controls the 10 LED's on the DE10 board to visually represent 16-bit values with a bar that fills up
-- Updated 23MAR2025

-- Copying inclusions from SCOMP because I don't know what we need
library altera_mf;
library lpm;
library ieee;

use altera_mf.altera_mf_components.all;
use lpm.lpm_components.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-- Entity block defines the I/O of design; how the hardware will interface with the outside world
entity LED_Bar_Controller is
	port(
	clock		:in	std_logic;			-- 100KHz Clock is used for PWM control of LED brightness
	enable		:in	std_logic;			-- Signal from IO decoder to begin driving LED's
	data_in		:in	std_logic_vector(15 downto 0);	-- 16-bit value from SCOMP
	data_out	:out	std_logic_vector(15 downto 0) 	-- LED output
	);
end LED_Bar_Controller;

-- Architecture block defines the internal behavior/structure of entity
architecture Behavior of LED_Bar_Controller is
begin
	-- Generic map block is used similarly to a '#define' section in conventional programming languages
	--generic map(
	--);
	
	-- Port map is used to connect components inside an architecture
	--port map(
	--);
	
	-- Process block defines actual behavior
	-- This process maps an unsigned 16-bit value to the 10 LED's without fading
	process(enable, data_in)
	begin
		if(enable = '1') then
		
			if(data_in > 0) then
				data_out(0) <= '1';
			else
				data_out(0) <= '0';
			end if;
			
			if(data_in > 6553) then
				data_out(1) <= '1';
			else
				data_out(1) <= '0';
			end if;
		
			if(data_in > 13106) then
				data_out(2) <= '1';
			else
				data_out(2) <= '0';
			end if;
			
			if(data_in > 19659) then
				data_out(3) <= '1';
			else
				data_out(3) <= '0';
			end if;
			
			if(data_in > 26212) then
				data_out(4) <= '1';
			else
				data_out(4) <= '0';
			end if;
			
			if(data_in > 32765) then
				data_out(5) <= '1';
			else
				data_out(5) <= '0';
			end if;
			
			if(data_in > 39318) then
				data_out(6) <= '1';
			else
				data_out(6) <= '0';
			end if;
			
			if(data_in > 45871) then
				data_out(7) <= '1';
			else
				data_out(7) <= '0';
			end if;
			
			if(data_in > 52424) then
				data_out(8) <= '1';
			else
				data_out(8) <= '0';
			end if;
			
			if(data_in > 58977) then
				data_out(9) <= '1';
			else
				data_out(9) <= '0';
			end if;
			
		else
			data_out <= "Z";	-- Output is set to high impedance if the LED bar controller is not enabled
		end if;
		
	end process;
end Behavior;
