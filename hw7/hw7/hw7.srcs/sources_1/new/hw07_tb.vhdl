--------------------------------------------------------------------------------
-- Name:	George York
-- Date:	Feb 2, 2021
-- File:	hw07_tb.vhdl
-- Event:   Lecture 10
--	Crs:	ECE 383
--
-- Purp:	testbench for hw07
--
-- Documentation:	I borrowed heavily from lec10_tb.vhdl
--
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY hw07_tb IS
END hw07_tb;
 
ARCHITECTURE behavior OF hw07_tb IS 
 
    -- Component Declaration for the Units Under Test (UUT)
 
    COMPONENT button_debounce
		Port(	clk: in  STD_LOGIC;
				reset : in  STD_LOGIC;
				button: in STD_LOGIC;
				action: out STD_LOGIC);
    END COMPONENT; 
 
    COMPONENT lec10    -- counter for debounced button to increment with the "action" signal
		generic (N: integer := 4);
		Port(	clk: in  STD_LOGIC;
				reset : in  STD_LOGIC;
				crtl: in std_logic_vector(1 downto 0);
				D: in unsigned (N-1 downto 0);
				Q: out unsigned (N-1 downto 0));
    END COMPONENT;
    
   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal button : std_logic := '0';
   signal action : std_logic;
   signal crtl : std_logic_vector(1 downto 0) := (others => '0');
   signal D : unsigned(4 downto 0) := (others => '0');

 	--Outputs
   signal Q : unsigned(4 downto 0);

   -- Clock period definitions  -- set for 100KHz clock... FPGA board runs at 100MHz
   constant clk_period : time := 10us;                                      -- 10ns; 
 
BEGIN
	-- Instantiate the Units Under Test (UUT)
   uut1: button_debounce 
	PORT MAP (
          clk => clk,
          reset => reset,
		  button => button,
		  action => action
        );
		
	uut2: lec10 
	Generic map(5)
	PORT MAP (
          clk => clk,
          reset => reset,
		  crtl => crtl,
          D => D,
          Q => Q
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
 	reset <= '0', '1' after 25 us;  -- synchronous, and clock at 10us
	D <= "00000";  -- not used
 	-----------------------------------------------------------------------------
	--		crtl
	--		00			hold
	--		01			count up mod 10
	--		10			load D
	--		11			synch reset
	-----------------------------------------------------------------------------
    crtl <= '0' & action;   -- if action = 0, then hold.  if action = 1, then count up
	button <= '0', 
	           '1' after 60ms, -- button pressed
	           '0' after 61ms, -- then bounces
	           '1' after 62ms, 
	           '0' after 64ms, 
	           '1' after 65ms, 
	           '0' after 120ms, -- botton released
	           '1' after 121ms,  -- then bounces
               '0' after 122ms, 
               '1' after 124ms, 
               '0' after 125ms, 
               '1' after 180ms,  -- button pressed
	           '0' after 181ms, -- then bounces
               '1' after 182ms, 
               '0' after 184ms, 
               '1' after 185ms, 
               '0' after 240ms, -- botton released
               '1' after 241ms,  -- then bounces
               '0' after 242ms, 
               '1' after 244ms, 
               '0' after 245ms;

END;