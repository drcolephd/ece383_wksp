library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

ENTITY instructor_tb IS
END instructor_tb;

ARCHITECTURE behavior OF instructor_tb IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT vga_signal_generator is
        Port (
            clk      : in  STD_LOGIC;
            reset_n  : in  STD_LOGIC;
            position : out coordinate_t;
            vga      : out vga_t
        );
    END COMPONENT;

    -- Inputs
    signal clk     : std_logic := '0';
    signal reset_n : std_logic := '0';

    -- Outputs (from vga_signal_generator)
    signal position : coordinate_t;
    signal vga      : vga_t;

    -- Aliases so the rest of the testbench logic stays almost identical
    signal h_sync, v_sync, blank  : std_logic;

    -- If your coordinate_t uses different field names (e.g., x/y instead of row/column),
    -- update these aliases accordingly.
    alias row    : unsigned(9 downto 0) is position.row;
    alias column : unsigned(9 downto 0) is position.col;

    -- Clock period definitions
    constant clk_period : time := 40 ns;

BEGIN

    h_sync <= vga.hsync;
    v_sync <= vga.vsync;
    blank <= vga.blank;

    -- Instantiate the Unit Under Test (UUT)
    uut: vga_signal_generator
        PORT MAP (
            clk      => clk,
            reset_n  => reset_n,
            position => position,
            vga      => vga
        );

    -- Clock process definitions
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- (Optional) keep your original reset waveform; the test process also drives reset.
    reset_n <= '0', '1' after 30 ns;

    -- Test process
    test_process: process
    begin
        -- Reset the UUT
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';

        -- Test h_sync transitions on falling edge of clock
        report "Testing h_sync" severity note;
        wait until column = 655 and clk = '0';
        assert h_sync = '1' report "h_sync should be HIGH at column 655" severity warning;
        wait until column = 656 and clk = '0';
        assert h_sync = '0' report "h_sync should be LOW at column 656" severity warning;
        wait until column = 751 and clk = '0';
        assert h_sync = '0' report "h_sync should be LOW at column 751" severity warning;
        wait until column = 752 and clk = '0';
        assert h_sync = '1' report "h_sync should be HIGH at column 752" severity warning;
        wait until column = 0 and clk = '0';
        assert h_sync = '1' report "h_sync should be HIGH at column 0" severity warning;
        wait until column = 799 and clk = '0';
        assert h_sync = '1' report "h_sync should be HIGH at column 799" severity warning;

        -- Test v_sync transitions on falling edge of clock
        report "Testing v_sync" severity note;
        wait until row = 489 and clk = '0';
        assert v_sync = '1' report "v_sync should be HIGH at row 489" severity warning;
        wait until row = 490 and clk = '0';
        assert v_sync = '0' report "v_sync should be LOW at row 490" severity warning;
        wait until row = 491 and clk = '0';
        assert v_sync = '0' report "v_sync should be LOW at row 491" severity warning;
        wait until row = 492 and clk = '0';
        assert v_sync = '1' report "v_sync should be HIGH at row 492" severity warning;
        wait until row = 0 and clk = '0';
        assert v_sync = '1' report "v_sync should be HIGH at row 0" severity warning;
        wait until row = 524 and clk = '0';
        assert v_sync = '1' report "v_sync should be HIGH at row 524" severity warning;

        -- Test blank transitions on falling edge of clock
        report "Testing blank" severity note;
        wait until row = 0 and column = 0 and clk = '0';
        assert blank = '0' report "blank should be LOW at row 0, col 0" severity warning;
        wait until row = 0 and column = 639 and clk = '0';
        assert blank = '0' report "blank should be LOW at row 0, col 639" severity warning;
        wait until row = 0 and column = 640 and clk = '0';
        assert blank = '1' report "blank should be HIGH at row 0, col 640" severity warning;
        wait until row = 1 and column = 0 and clk = '0';
        assert blank = '0' report "blank should be LOW at row 1, col 0" severity warning;
        wait until row = 479 and column = 0 and clk = '0';
        assert blank = '0' report "blank should be LOW at row 479, col 0" severity warning;
        wait until row = 480 and column = 0 and clk = '0';
        assert blank = '1' report "blank should be HIGH at row 480, col 0" severity warning;

        -- Test complete
        report "Testbench completed successfully." severity note;
        wait;
    end process;

END;
