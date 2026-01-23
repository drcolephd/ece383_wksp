-- vga_log_tb.vhd
--
-- Testbench: instantiates vga_signal_generator + color_mapper
-- and writes one line per rising edge of clk to a .txt log file:
--   <sim_time> <units>: hs vs red green blue
-- Example:
--   50 ns: 1 1 00000000 00000000 00000000
--
-- Works well in GHDL (uses textio + std_logic_textio).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

use work.ece383_pkg.all;

entity vga_log_tb is
end entity;

architecture tb of vga_log_tb is

  -- ====== USER SETTINGS ======
  -- Set this to your intended pixel clock period.
  -- (25.175 MHz VGA pixel clock is ~39.72 ns, but use whatever your design expects.)
  constant CLK_PERIOD : time := 40 ns; -- 25 MHz

  -- Output filename (created in your simulation working directory)
  constant LOG_FILENAME : string := "vga_log.txt";

  -- How long to run
  constant RUN_TIME : time := 40 ms;
  -- ===========================

  signal clk     : std_logic := '0';
  signal reset_n : std_logic := '0';

  signal position : coordinate_t;
  signal vga      : vga_t;
  signal color    : color_t;

  -- color_mapper inputs
  signal trigger : trigger_t := (
    t => (others => '0'),
    v => (others => '0')
  );

  signal ch1 : channel_t := (active => '0', en => '0');
  signal ch2 : channel_t := (active => '0', en => '0');

  -- Convenience slices (8-bit each with your package)
  signal red8   : std_logic_vector(7 downto 0);
  signal green8 : std_logic_vector(7 downto 0);
  signal blue8  : std_logic_vector(7 downto 0);

begin

  -- Pixel clock
  clk <= not clk after CLK_PERIOD/2;

  -- DUTs
  u_gen : vga_signal_generator
    port map (
      clk      => clk,
      reset_n  => reset_n,
      position => position,
      vga      => vga
    );

  u_map : color_mapper
    port map (
      color    => color,
      position => position,
      trigger  => trigger,
      ch1      => ch1,
      ch2      => ch2
    );
    
    -- Turn on/off ch1 and ch2
    ch1.en <= '1';
    ch2.en <= '0';    
    ch1.active <= '1' when (position.row = position.col) else '0';
    ch2.active <= '1' when (position.row = 440 - position.col) else '0';

  -- Extract RGB (your package functions return 8-bit slices)
  red8   <= Get_Red(color);
  green8 <= Get_Green(color);
  blue8  <= Get_Blue(color);

  -- Reset + stimulus
  stim : process
  begin
    -- hold reset low for a few cycles
    reset_n <= '0';
    wait for 10*CLK_PERIOD;
    reset_n <= '1';

    -- optional: enable channels / trigger changes (edit as desired)
    wait for 200*CLK_PERIOD;



    -- run for the configured time then stop
    wait for RUN_TIME;
    assert false report "Simulation complete." severity failure;
  end process;

  -- Logger: one line per rising edge
  logger : process
    file f        : text open write_mode is LOG_FILENAME;
    variable l    : line;

    -- For time formatting
    variable t_ns : integer;
  begin
    -- Wait until sim starts
    wait for 0 ns;

    -- Main logging loop
    while now < RUN_TIME loop
      wait until rising_edge(clk);

      -- Convert sim time to integer in ns for "50 ns:" style output
      -- (integer(now / 1 ns) is safe for typical lab-scale sims)
      t_ns := integer(now / 1 ns);

      -- Write: "<time> ns: "
      write(l, t_ns);
      write(l, string'(" ns: "));

      -- hs vs
      write(l, vga.hsync);
      write(l, character'(' '));
      write(l, vga.vsync);
      write(l, string'(" "));

      -- ====== RGB OUTPUT FORMAT ======
      -- 24-bit color_t => 8/8/8 binary strings
      write(l, red8);
      write(l, character'(' '));
      write(l, green8);
      write(l, character'(' '));
      write(l, blue8);

      -- If you *instead* want 3/3/2 like your example (010 010 01),
      -- comment out the 8/8/8 writes above and use this:
      --
      -- write(l, red8(7 downto 5));   write(l, character'(' '));
      -- write(l, green8(7 downto 5)); write(l, character'(' '));
      -- write(l, blue8(7 downto 6));
      --
      -- ===============================

      writeline(f, l);
    end loop;

    wait;
  end process;

end architecture;
