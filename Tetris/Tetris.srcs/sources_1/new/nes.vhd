----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/04/2026 02:05:11 PM
-- Design Name: 
-- Module Name: nes - Behavioral
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

entity nes is
    generic (
        CLK_FREQ_HZ     : integer := 100_000_000;
        POLL_HZ         : integer := 60;
        HALF_CYCLE_US   : integer := 6
    );
    port (
        clk        : in  std_logic;
        reset_n    : in  std_logic;

        nes_data   : in  std_logic;
        nes_latch  : out std_logic;
        nes_clk    : out std_logic;

        btn_a      : out std_logic;
        btn_b      : out std_logic;
        btn_select : out std_logic;
        btn_start  : out std_logic;
        btn_up     : out std_logic;
        btn_down   : out std_logic;
        btn_left   : out std_logic;
        btn_right  : out std_logic;
        
        debug_state     : out std_logic_vector(2 downto 0);
        debug_bit_index : out std_logic_vector(2 downto 0);
        debug_shift_reg : out std_logic_vector(7 downto 0)
    );
end nes;

architecture Behavioral of nes is

    constant POLL_COUNT_MAX : integer := CLK_FREQ_HZ / POLL_HZ;
    constant STEP_COUNT_MAX : integer := (CLK_FREQ_HZ / 1_000_000) * HALF_CYCLE_US;

    type nes_state_t is (
        IDLE,
        LATCH_HIGH,
        LATCH_LOW,
        CLK_HIGH,
        CLK_LOW,
        DONE
    );

    signal state : nes_state_t := IDLE;

    signal poll_count : integer range 0 to POLL_COUNT_MAX := 0;
    signal step_count : integer range 0 to STEP_COUNT_MAX := 0;

    signal poll_tick : std_logic := '0';
    signal step_tick : std_logic := '0';

    signal bit_count : integer range 0 to 7 := 0;
    signal shift_reg : std_logic_vector(7 downto 0) := (others => '1');

    signal s_latch : std_logic := '0';
    signal s_clk   : std_logic := '0';

begin

    --------------------------------------------------------------------------
    -- 60 Hz poll tick
    --------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                poll_count <= 0;
                poll_tick  <= '0';
            else
                if poll_count = POLL_COUNT_MAX - 1 then
                    poll_count <= 0;
                    poll_tick  <= '1';
                else
                    poll_count <= poll_count + 1;
                    poll_tick  <= '0';
                end if;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------------
    -- 6 us step tick
    --------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                step_count <= 0;
                step_tick  <= '0';
            else
                if state = IDLE then
                    step_count <= 0;
                    step_tick  <= '0';
                else
                    if step_count = STEP_COUNT_MAX - 1 then
                        step_count <= 0;
                        step_tick  <= '1';
                    else
                        step_count <= step_count + 1;
                        step_tick  <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------------
    -- NES read FSM
    --------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                state     <= IDLE;
                bit_count <= 0;
                shift_reg <= (others => '1');
                s_latch   <= '0';
                s_clk     <= '0';

            else
                case state is

                    when IDLE =>
                        s_latch <= '0';
                        s_clk   <= '0';

                        if poll_tick = '1' then
                            bit_count <= 0;
                            s_latch   <= '1';
                            state     <= LATCH_HIGH;
                        end if;

                    when LATCH_HIGH =>
                        if step_tick = '1' then
                            s_latch <= '0';
                            shift_reg(0) <= nes_data;
                            state <= CLK_HIGH;
                        end if;

                    when CLK_HIGH =>
                        if step_tick = '1' then
                            s_clk <= '1';
                            state <= CLK_LOW;
                        end if;

                    when CLK_LOW =>
                        if step_tick = '1' then
                            s_clk <= '0';

                            if bit_count = 7 then
                                state <= DONE;
                            else
                                bit_count <= bit_count + 1;
                                shift_reg(bit_count + 1) <= nes_data;
                                state <= CLK_HIGH;
                            end if;
                        end if;

                    when DONE =>
                        s_latch <= '0';
                        s_clk   <= '0';
                        state   <= IDLE;

                    when others =>
                        state <= IDLE;

                end case;
            end if;
        end if;
    end process;

    nes_latch <= s_latch;
    nes_clk   <= s_clk;

    -- NES buttons are active-low
    btn_a      <= not shift_reg(0);
    btn_b      <= not shift_reg(1);
    btn_select <= not shift_reg(2);
    btn_start  <= not shift_reg(3);
    btn_up     <= not shift_reg(4);
    btn_down   <= not shift_reg(5);
    btn_left   <= not shift_reg(6);
    btn_right  <= not shift_reg(7);
    
    debug_bit_index <= std_logic_vector(to_unsigned(bit_count, 3));
    debug_shift_reg <= shift_reg;
    
    with state select
        debug_state <=
            "000" when IDLE,
            "001" when LATCH_HIGH,
            "010" when LATCH_LOW,
            "011" when CLK_HIGH,
            "100" when CLK_LOW,
            "101" when DONE,
            "111" when others;

end Behavioral;