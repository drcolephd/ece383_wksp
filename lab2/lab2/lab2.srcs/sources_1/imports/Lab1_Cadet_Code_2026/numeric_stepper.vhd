-- Numeric Stepper: Holds a value and increments or decrements it based on button presses
-- James Trimble, 20 Jan 2026

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity numeric_stepper is
  generic (
    num_bits  : integer := 8;
    max_value : integer := 127;
    min_value : integer := -128;
    delta     : integer := 10
  );
  port (
    clk     : in  std_logic;
    reset_n : in  std_logic;                    -- active-low synchronous reset
    en      : in  std_logic;                    -- enable
    up      : in  std_logic;                    -- increment on rising edge
    down    : in  std_logic;                    -- decrement on rising edge
    q       : out signed(num_bits-1 downto 0)   -- signed output
  );
end numeric_stepper;

architecture numeric_stepper_arch of numeric_stepper is
    signal process_q : signed(num_bits-1 downto 0) := to_signed(0,num_bits);
    signal prev_up, prev_down : std_logic := '0';
    signal is_increment, is_decrement : boolean := false;
begin

    is_increment <= true when en = '1' and up = '1' and prev_up = '0' else false;
    is_decrement <= true when en = '1' and down = '1' and prev_down = '0' else false;
    
    process(clk)
    begin
    
        if rising_edge(clk) then
            if is_increment and process_q <= max_value - delta then process_q <= process_q + delta;
            end if;
        
            if is_decrement and process_q >= min_value + delta then process_q <= process_q - delta;
            end if;
            
        prev_up <= up;
        prev_down <= down;
      
        end if;
    end process;

q <= process_q;

end numeric_stepper_arch;
