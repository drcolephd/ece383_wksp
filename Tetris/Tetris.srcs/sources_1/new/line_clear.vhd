----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2026 01:36:59 PM
-- Design Name: 
-- Module Name: line_clear - Behavioral
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


----------------------------------------------------------------------------------
-- line_clear.vhdl
-- Detects completed rows and calculates score increment
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity line_clear is
    port (
        board_data   : in  board_t;
        clear_en     : out std_logic;
        rows_cleared : out integer range 0 to 4;
        shift_en     : out std_logic;
        score        : out unsigned(31 downto 0)
    );
end line_clear;

architecture Behavioral of line_clear is

begin

    process(board_data)
        variable row_full_count : integer range 0 to 20;
        variable full           : boolean;
    begin
        row_full_count := 0;

        for y in 0 to 19 loop
            full := true;

            for x in 0 to 9 loop
                if board_data(y)(x) = EMPTY then
                    full := false;
                end if;
            end loop;

            if full = true then
                row_full_count := row_full_count + 1;
            end if;
        end loop;

        if row_full_count > 0 then
            clear_en <= '1';
            shift_en <= '1';
        else
            clear_en <= '0';
            shift_en <= '0';
        end if;

        if row_full_count > 4 then
            rows_cleared <= 4;
        else
            rows_cleared <= row_full_count;
        end if;

        -- simple scoring
        case row_full_count is
            when 1 =>
                score <= to_unsigned(100, 32);
            when 2 =>
                score <= to_unsigned(300, 32);
            when 3 =>
                score <= to_unsigned(500, 32);
            when 4 =>
                score <= to_unsigned(800, 32);
            when others =>
                score <= to_unsigned(0, 32);
        end case;

    end process;

end Behavioral;