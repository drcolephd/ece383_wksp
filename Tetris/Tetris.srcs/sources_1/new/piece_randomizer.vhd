----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/07/2026 06:20:32 PM
-- Design Name: 
-- Module Name: piece_randomizer - Behavioral
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

entity piece_randomizer is
    port (
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        rand_piece : out integer range 0 to 6
    );
end piece_randomizer;

architecture Behavioral of piece_randomizer is

    signal curNum   : std_logic_vector(7 downto 0);
    signal nextNum  : std_logic_vector(7 downto 0);
    signal feedback : std_logic;
    signal raw_val  : unsigned(2 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                curNum <= "00000001";
            else
                curNum <= nextNum;
            end if;
        end if;
    end process;

    feedback <= curNum(4) xor curNum(3) xor curNum(2) xor curNum(0);

    nextNum <= feedback & curNum(7 downto 1);

    raw_val <= unsigned(curNum(2 downto 0));

    process(raw_val)
    begin
        if raw_val = 7 then
            rand_piece <= 0;
        else
            rand_piece <= to_integer(raw_val);
        end if;
    end process;

end Behavioral;