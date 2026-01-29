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

    constant H_MAX : integer := 799;
    constant V_MAX : integer := 524;

    signal horizontal_roll, vertical_roll: std_logic := '0';		
    signal h_counter_ctrl, v_counter_ctrl: std_logic := '1'; -- Default to counting up
    signal h_sync_is_low, v_sync_is_low, h_blank_is_low, v_blank_is_low : boolean := false;
    signal current_pos : coordinate_t;
    signal h_count, v_count :   unsigned(9 downto 0);
    
    constant H_SYNC_START : integer := 656; --active + front porch
    constant H_SYNC_END   : integer := 751; -- + sync
    constant V_SYNC_START : integer := 490; -- active + front porch
    constant V_SYNC_END   : integer := 491; -- + sync
    
    constant H_VISIBLE    : integer := 640; --working display space
    constant V_VISIBLE    : integer := 480;
    
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
h_sync_is_low <=    (to_integer(h_count) >= H_SYNC_START) and
                    (to_integer(h_count) <= H_SYNC_END);

-- vsync low during sync pulse rows 490..491
v_sync_is_low <=    (to_integer(v_count) >= V_SYNC_START) and
                    (to_integer(v_count) <= V_SYNC_END);

-- IMPORTANT: your test expects blank LOW during active video
-- So make these booleans mean "active video" (low-blanking)
h_blank_is_low <= (to_integer(h_count) < H_VISIBLE);
v_blank_is_low <= (to_integer(v_count) < V_VISIBLE);

process (clk)
begin
    if rising_edge(clk) then
        -- position outputs
        current_pos.col <= h_count;
        current_pos.row <= v_count;

        -- hsync (active low)
        if h_sync_is_low then
            vga.hsync <= '0';
        else
            vga.hsync <= '1';
        end if;

        -- vsync (active low)
        if v_sync_is_low then
            vga.vsync <= '0';
        else
            vga.vsync <= '1';
        end if;

        -- blank LOW during active video (both active)
        if (h_blank_is_low and v_blank_is_low) then
            vga.blank <= '0';
        else
            vga.blank <= '1';
        end if;
    end if;
end process;

-- Assign output ports
    position <= current_pos;

end vga_signal_generator_arch;
