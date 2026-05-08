----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/07/2026 03:33:51 PM
-- Design Name: 
-- Module Name: score_counter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity score_counter is
    port (
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        clear_pulse  : in  std_logic;
        rows_cleared : in  integer range 0 to 4;
        score        : out unsigned(31 downto 0);
        lines_total  : out unsigned(7 downto 0)
    );
end score_counter;

architecture Behavioral of score_counter is
    signal s_score : unsigned(31 downto 0) := (others => '0');
    signal s_lines : unsigned(7 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                s_score <= (others => '0');
                s_lines <= (others => '0');

            elsif clear_pulse = '1' then
                s_lines <= s_lines + to_unsigned(rows_cleared, 8);

                case rows_cleared is
                    when 1 => s_score <= s_score + to_unsigned(100, 16);
                    when 2 => s_score <= s_score + to_unsigned(300, 16);
                    when 3 => s_score <= s_score + to_unsigned(500, 16);
                    when 4 => s_score <= s_score + to_unsigned(800, 16);
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    score <= s_score;
    lines_total <= s_lines;

end Behavioral;