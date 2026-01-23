----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/14/2026 09:28:04 PM
-- Design Name: 
-- Module Name: hw3_tb - beep
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hw3_tb is
--  Port (  );
end hw3_tb;

architecture beep of hw3_tb is
    component moop is 
        port(
            signal d : in unsigned(7 downto 0);
            signal h: out std_logic
        );
    end component moop;    
        signal w_d: unsigned(7 downto 0) := (others => '0');
        signal w_h: std_logic;     
begin
    uut: entity work.hw3
        port map(
            d => w_d,
            h => w_h
        );
    process
    begin
        w_d <= to_unsigned(0,8);
        wait for 10 ns;
        assert w_h = '1' report "0 is multiple of 17" severity error;
        
        w_d <= to_unsigned(17, 8);
        wait for 10 ns;
        assert w_h = '1' report "17 is multiple of 17" severity error;

        w_d <= to_unsigned(34, 8);
        wait for 10 ns;
        assert w_h = '1' report "34 is multiple of 17" severity error;

        w_d <= to_unsigned(51, 8);
        wait for 10 ns;
        assert w_h = '1' report "51 is multiple of 17" severity error;

        w_d <= to_unsigned(255, 8);
        wait for 10 ns;
        assert w_h = '1' report "255 is multiple of 17" severity error;

        w_d <= to_unsigned(1, 8);
        wait for 10 ns;
        assert w_h = '0' report "1 not multiple of 17" severity error;

        w_d <= to_unsigned(16, 8);
        wait for 10 ns;
        assert w_h = '0' report "16 not multiple of 17" severity error;

        w_d <= to_unsigned(18, 8);
        wait for 10 ns;
        assert w_h = '0' report "18 not multiple of 17" severity error;

        w_d <= to_unsigned(100, 8);
        wait for 10 ns;
        assert w_h = '0' report "100 not multiple of 17" severity error;

        w_d <= to_unsigned(254, 8);
        wait for 10 ns;
        assert w_h = '0' report "254 not multiple of 17" severity error;

        report "hooray" severity note;
        wait;
    end process;
end beep;
