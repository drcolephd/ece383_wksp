----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2026 02:40:52 PM
-- Design Name: 
-- Module Name: gc1_tb - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ece383_pkg.all;

entity gc1_tb is
end entity;

architecture sim of gc1_tb is

    -- Clock
    signal clk      : std_logic := '0';
    signal reset_n  : std_logic := '0';

    -- TMDS (unused in sim but required)
    signal tmds  : std_logic_vector(3 downto 0);
    signal tmdsb : std_logic_vector(3 downto 0);

    -- BRAM signals
    signal read_addr_L : unsigned(9 downto 0) := (others => '0');
    signal read_addr_R : unsigned(9 downto 0) := (others => '0');

    signal bram_out_L : channel_t;
    signal bram_out_R : channel_t;

    -- Trigger (not used yet)
    signal trigger : trigger_t := (others => '0');

    -- Pixel position output
    signal position : coordinate_t;

begin

    ------------------------------------------------------------------
    -- Clock Generation (100 MHz)
    ------------------------------------------------------------------
    clk <= not clk after 5 ns;

    ------------------------------------------------------------------
    -- Reset
    ------------------------------------------------------------------
    process
    begin
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
        wait;
    end process;

    ------------------------------------------------------------------
    -- Increment BRAM addresses continuously
    ------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '1' then
                read_addr_L <= read_addr_L + 1;
                read_addr_R <= read_addr_R + 1;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    -- Left BRAM (Initialized)
    ------------------------------------------------------------------
    inst_bram_L : entity work.bram_left
        port map (
            clka  => clk,
            addra => std_logic_vector(read_addr_L),
            douta => bram_out_L
        );

    ------------------------------------------------------------------
    -- Right BRAM (Initialized)
    ------------------------------------------------------------------
    inst_bram_R : entity work.bram_right
        port map (
            clka  => clk,
            addra => std_logic_vector(read_addr_R),
            douta => bram_out_R
        );

    ------------------------------------------------------------------
    -- VIDEO (Lab 1)
    ------------------------------------------------------------------
    inst_video : entity work.video
        port map (
            clk       => clk,
            reset_n   => reset_n,
            tmds      => tmds,
            tmdsb     => tmdsb,
            trigger   => trigger,
            position  => position,
            ch1       => bram_out_L,
            ch2       => bram_out_R
        );

end architecture;

