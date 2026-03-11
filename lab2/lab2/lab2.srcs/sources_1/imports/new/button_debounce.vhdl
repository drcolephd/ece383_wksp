--------------------------------------------------------------------
-- Name:	George York
-- Date:	Feb 2, 2021
-- File:	button_debounce.vhdl
-- HW:	    Template for HW7
--	Crs:	ECE 383
--
-- Purp:	For this debouncer, we assume the clock is slowed from 100MHz to 100KHz,
--          and the ringing time is less than 20ms
--
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
------------------------------------------------------------------------- 
library IEEE;		
use IEEE.std_logic_1164.all; 
use IEEE.NUMERIC_STD.ALL;

entity button_debounce is
	Port(	clk: in  STD_LOGIC;
			reset : in  STD_LOGIC;
			button: in STD_LOGIC;
			action: out STD_LOGIC);
end button_debounce;

architecture behavior of button_debounce is
	
	signal cw: STD_LOGIC_VECTOR(1 downto 0):= (others => '0');
	--signal sw: STD_LOGIC:= '0';
	type state_type is (Init0, Comp1, Init2, Comp2, Init3, execute);
	signal state: state_type := Init0;
	
	COMPONENT lec10    -- clock for 20 msec debounce delay
		generic (N: integer := 21);
		Port(	clk: in  STD_LOGIC;
				reset : in  STD_LOGIC;
				crtl: in std_logic_vector(1 downto 0);
				D: in unsigned (N-1 downto 0);
				Q: out unsigned (N-1 downto 0));
    END COMPONENT;
	
	-- these values are for 100KHz
    signal D : unsigned(10 downto 0) := (others => '0');
    signal Q : unsigned(10 downto 0);
    
    constant max_value : unsigned(10 downto 0) := to_unsigned(1999, 11);
    signal less: STD_LOGIC;
        
begin
    ----------------------------------------------------------------------
	--   DATAPATH
	----------------------------------------------------------------------
	delay_counter: lec10 
    Generic map(N => 11)
	PORT MAP (
          clk => clk,
          reset => reset,
		  crtl => cw,
          D => max_value,
          Q => Q
        );	
	
	-- reminder: counter counter every other clock cycle!
   	-- these values are for 100KHz clock
    less <= '1' when (Q < max_value) else '0';
    
   -----------------------------------------------------------------------
   --    CONTROL UNIT
   -----------------------------------------------------------------------
   state_process: process(clk)
	 begin
		if (rising_edge(clk)) then
			if (reset = '0') then 
				state <= Init0;
			else
				case state is
					when Init0 =>
						state <= Comp1;
					when Comp1 =>
						if (button = '1') then state <= Init2; end if;
					when Init2 =>
						if (less = '0') then state <= Comp2; end if;
                    when Comp2 =>
                        if (button = '0') then state <= Init3; end if;
                    when Init3 => 
                        if (less = '0') then state <= execute; end if;
                    when execute =>
                        state <= Init0;                                        
				end case;
			end if;
		end if;
	end process;
    
	------------------------------------------------------------------------------
	--			OUTPUT EQUATIONS
	--	
	--		cw is counter control:  00 is hold; 01 is increment; 11 is reset	
	------------------------------------------------------------------------------	
	cw <=   "11" when state = Init0 else
			"00" when state = Comp1 else
			"01" when state = Init2 else
			"00" when state = Comp2 else
			"01" when state = Init3 else
			"00";
				
	action <= '1' when state = execute else '0';
	
end behavior;