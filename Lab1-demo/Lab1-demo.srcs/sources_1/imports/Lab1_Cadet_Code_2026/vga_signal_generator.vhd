-- vga_signal_generator Generates the hsync, vsync, blank, and row, col for the VGA signal

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity vga_signal_generator is
    Port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           position: out coordinate_t;
           vga : out vga_t);
end vga_signal_generator;

architecture vga_signal_generator_arch of vga_signal_generator is

    constant H_MAX : integer := 639;
    constant V_MAX : integer := 479;

    signal horizontal_roll, vertical_roll: std_logic := '0';		
    signal h_counter_ctrl, v_counter_ctrl: std_logic := '1'; -- Default to counting up
    signal h_sync_is_low, v_sync_is_low, h_blank_is_low, v_blank_is_low : boolean := false;
    signal current_pos : coordinate_t;
    signal h_count, v_count :   unsigned(9 downto 0);
    
begin

-- horizontal counter
    h_counter : entity work.counter
    generic map (
        num_bits  => 10,
        max_value => H_MAX
    )
    port map (
        clk     => clk,
        reset_n => reset_n,
        ctrl    => '1',              -- always counting
        roll    => horizontal_roll,
        Q       => h_count
    );
-- Glue code to connect the horizontal and vertical counters
        v_counter_ctrl <= horizontal_roll;

-- vertical counter
    
    v_counter : entity work.counter
        generic map (
            num_bits  => 10,
            max_value => V_MAX
        )
        port map (
            clk     => clk,
            reset_n => reset_n,
            ctrl    => v_counter_ctrl,   -- increments only on horizontal rollover
            roll    => open,
            Q       => v_count
        );
-- Assign VGA outputs in a gated manner
    h_sync_is_low  <= (h_count = to_unsigned(H_MAX, 10));
    v_sync_is_low  <= (v_count = to_unsigned(V_MAX, 10));
    h_blank_is_low <= false;
    v_blank_is_low <= false;

process (clk)
begin
    if rising_edge(clk) then
        current_pos.col <= h_count;
        current_pos.row <= v_count;

        if h_sync_is_low then
            vga.hsync <= '0';
        else
            vga.hsync <= '1';
        end if;

        if v_sync_is_low then
            vga.vsync <= '0';
        else
            vga.vsync <= '1';
        end if;

        if (h_blank_is_low or v_blank_is_low) then
            vga.blank <= '0';
        else
            vga.blank <= '1';
        end if;
    end if;
end process;

-- Assign output ports
    position <= current_pos;

end vga_signal_generator_arch;
