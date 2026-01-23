library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity NumStepper_tb is
end entity;

architecture tb of NumStepper_tb is
    constant NUM_BITS  : integer := 8;
    constant MAX_VALUE : integer := 127;
    constant MIN_VALUE : integer := -128;

    constant CLK_PERIOD : time := 10 ns;

    signal clk     : std_logic := '0';
    signal reset_n : std_logic := '1';
    signal en      : std_logic := '1';
    signal up      : std_logic := '0';
    signal down    : std_logic := '0';
    signal q       : signed(NUM_BITS-1 downto 0);

begin
    --------------------------------------------------------------------------
    -- Clock
    --------------------------------------------------------------------------
    clk <= not clk after CLK_PERIOD / 2;

    --------------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------------
    dut : entity work.Numeric_Stepper
        generic map (
            num_bits  => NUM_BITS,
            max_value => MAX_VALUE,
            min_value => MIN_VALUE
        )
        port map (
            clk     => clk,
            reset_n => reset_n,
            en      => en,
            up      => up,
            down    => down,
            q       => q
        );

    --------------------------------------------------------------------------
    -- Stimulus
    --------------------------------------------------------------------------
    stim : process
        variable prev_q : integer;
    begin
        ----------------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------------
        reset_n <= '0';
        up <= '0';
        down <= '0';
        wait until rising_edge(clk);
        reset_n <= '1';
        wait until rising_edge(clk);

        assert to_integer(q) = 0
            report "Reset failed: q /= 0"
            severity error;

        ----------------------------------------------------------------------
        -- Hold UP high: should increment once only
        ----------------------------------------------------------------------
        prev_q := to_integer(q);
        up <= '1';

        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        assert to_integer(q) = prev_q + 1
            report "Holding UP high caused multiple increments"
            severity error;

        prev_q := to_integer(q);
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        assert to_integer(q) = prev_q
            report "Value changed while UP remained high"
            severity error;

        up <= '0';
        wait until rising_edge(clk);

        ----------------------------------------------------------------------
        -- Count all the way UP to MAX_VALUE
        ----------------------------------------------------------------------
        while to_integer(q) < MAX_VALUE loop
            up <= '1';
            wait until rising_edge(clk);
            up <= '0';
            wait until rising_edge(clk);
        end loop;

        assert to_integer(q) = MAX_VALUE
            report "Did not reach MAX_VALUE"
            severity error;

        -- Try incrementing past MAX_VALUE
        up <= '1';
        wait until rising_edge(clk);
        up <= '0';
        wait until rising_edge(clk);

        assert to_integer(q) = MAX_VALUE
            report "Exceeded MAX_VALUE"
            severity error;

        ----------------------------------------------------------------------
        -- Hold DOWN high: should decrement once only
        ----------------------------------------------------------------------
        prev_q := to_integer(q);
        down <= '1';

        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        assert to_integer(q) = prev_q - 1
            report "Holding DOWN high caused multiple decrements"
            severity error;

        prev_q := to_integer(q);
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        assert to_integer(q) = prev_q
            report "Value changed while DOWN remained high"
            severity error;

        down <= '0';
        wait until rising_edge(clk);

        ----------------------------------------------------------------------
        -- Count all the way DOWN to MIN_VALUE
        ----------------------------------------------------------------------
        while to_integer(q) > MIN_VALUE loop
            down <= '1';
            wait until rising_edge(clk);
            down <= '0';
            wait until rising_edge(clk);
        end loop;

        assert to_integer(q) = MIN_VALUE
            report "Did not reach MIN_VALUE"
            severity error;

        -- Try decrementing past MIN_VALUE
        down <= '1';
        wait until rising_edge(clk);
        down <= '0';
        wait until rising_edge(clk);

        assert to_integer(q) = MIN_VALUE
            report "Went below MIN_VALUE"
            severity error;

        ----------------------------------------------------------------------
        report "Numeric_Stepper testbench PASSED" severity note;
        wait;
    end process;

end architecture;
