----------------------------------------------------------------------------------
-- Name:	Template by George York (modified from Jeff Falkinburg)
-- Date:	Spring 2023
-- File:    lab2_fsm.vhd
-- HW:	    Lab 2 
-- Pupr:	Lab 2 Finite State Machine for the write circuitry.  
--
-- Doc:	Adapted from Dr Coulston's Lab exercise
-- 	
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity lab2_fsm is
    Port ( clk : in  STD_LOGIC;
           reset_n : in  STD_LOGIC;
           sw : in  STD_LOGIC_VECTOR (2 downto 0);
           cw : out  STD_LOGIC_VECTOR (2 downto 0));
end lab2_fsm;

architecture Behavioral of lab2_fsm is

	type state_type is (reset_counter, wait_ready, wait_trigger, write_sample, increment);
	signal state: state_type;

begin

	-------------------------------------------------------------------------------
	--		SW		meaning
	--		sw(0)  audio wrapper ready
	--      sw(1)  counter finished
	--      sw(2)  triggeerrrrr
	-------------------------------------------------------------------------------
	state_proces: process(clk)  
	begin
		if (rising_edge(clk)) then
			if (reset_n = '0') then 
				state <= reset_counter;
			else 
				case state is
					when reset_counter =>
					   state <= wait_trigger;
					   
				    when wait_trigger =>
--				        state <= wait_ready;
				        if sw(2) = '1' then
				            state <= wait_ready;    
                        else
                            state <= wait_trigger;
                        end if;
                        
                    when wait_ready =>
                        if sw(0) = '1' then
                            state <= write_sample;
                        else 
                            state <= wait_ready;
                        end if;
                        
                    when write_sample =>
                            state <= increment;
                            
                    when increment =>
                        if sw(1) = '1' then
                            state <= reset_counter;
                        else
                            state <= wait_ready;
                        end if;
				end case;
			end if;
		end if;
	end process;

	-------------------------------------------------------------------------------
	--  CW output table
	--		CW		meaning
	--		cw(1:0) counter control
	--      cw(2) bram write enable
	-------------------------------------------------------------------------------
	
	with state select
        cw <=
           "010" when reset_counter, --000
           "000" when wait_trigger,
           "000" when wait_ready, --001
           "100" when write_sample, --101
           "001" when increment; --011

end Behavioral;

