----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2026 02:05:15 PM
-- Design Name: 
-- Module Name: game_fsm - Behavioral
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
use work.ece383_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity game_clock is
    generic (
        MAX_COUNT : integer := 25_000_000
    );
    
    port (
        clk       : in std_logic;
        reset_n   : in std_logic;
        score     : in unsigned(31 downto 0);
        game_tick : out std_logic
    );
end game_clock;

architecture Behavioral of game_clock is

    signal count_q      : unsigned(25 downto 0) := (others => '0');
    signal max_count_s  : unsigned(25 downto 0);

begin

    -- Level speed based on score
    process(score)
    begin
        if score < 1000 then
            max_count_s <= to_unsigned(25_000_000, 26); -- slow
        elsif score < 2000 then
            max_count_s <= to_unsigned(20_000_000, 26);
        elsif score < 3000 then
            max_count_s <= to_unsigned(15_000_000, 26);
        elsif score < 4000 then
            max_count_s <= to_unsigned(10_000_000, 26);
        else
            max_count_s <= to_unsigned(5_000_000, 26);  -- fast
        end if;
    end process;

    -- Game tick counter
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            count_q <= (others => '0');
            game_tick <= '0';

        elsif rising_edge(clk) then
            if count_q >= max_count_s then
                count_q <= (others => '0');
                game_tick <= '1';
            else
                count_q <= count_q + 1;
                game_tick <= '0';
            end if;
        end if;
    end process;

end Behavioral;