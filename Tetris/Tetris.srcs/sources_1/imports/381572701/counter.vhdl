----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2026 09:28:12 PM
-- Design Name: 
-- Module Name: counter_tb - Behavioral
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

entity counter is
    generic (
        num_bits  : integer := 4;
        max_value : integer := 9
    );
    port (
        clk     : in  STD_LOGIC;
        reset_n : in  STD_LOGIC;
        ctrl    : in  STD_LOGIC;
        roll    : out STD_LOGIC;
        Q       : out unsigned(num_bits-1 downto 0)
    );
end counter;

architecture Behavioral of counter is
    signal roll_tide : unsigned(num_bits-1 downto 0) := (others => '0');
begin

    process(clk)
        constant C_MAX : unsigned(num_bits-1 downto 0) := to_unsigned(max_value, num_bits);
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                roll_tide <= (others => '0');
            elsif ctrl = '1' then
                if roll_tide = C_MAX then
                    roll_tide <= (others => '0');
                else
                    roll_tide <= roll_tide + 1;
                end if;
            else
                roll_tide <= roll_tide;
            end if;
        end if;
    end process;

    Q <= roll_tide;
    roll <= '1' when roll_tide = to_unsigned(max_value, num_bits) else '0';

end Behavioral;
