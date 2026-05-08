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

    is_increment <= (prev_up = '0') and (up = '1');
    is_decrement <= (prev_down = '0') and (down = '1');
    
    process(clk)
    
        constant C_MAX : signed(num_bits-1 downto 0) := to_signed(max_value, num_bits);
        constant C_MIN : signed(num_bits-1 downto 0) := to_signed(min_value, num_bits);
        constant C_DEL : signed(num_bits-1 downto 0) := to_signed(delta, num_bits);
        
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                process_q <= to_signed(0, num_bits);
                prev_up   <= '0';
                prev_down <= '0';

            elsif en = '1' then
                prev_up   <= up;
                prev_down <= down;

                if is_increment and (not is_decrement) then
                    if process_q + C_DEL > C_MAX then
                        process_q <= C_MAX;
                    else
                        process_q <= process_q + C_DEL;
                    end if;

                elsif is_decrement and (not is_increment) then
                    if process_q - C_DEL < C_MIN then
                        process_q <= C_MIN;
                    else
                        process_q <= process_q - C_DEL;
                    end if;

                else
                    process_q <= process_q;  -- hold
                end if;

            else
                prev_up   <= up;
                prev_down <= down;
                process_q <= process_q;
            end if;
        end if;
    end process;
    
    q <= process_q;
    
end numeric_stepper_arch;
