----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2026 02:05:13 PM
-- Design Name: 
-- Module Name: Tetris - Behavioral
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
use work.ece383_pkg.ALL;

entity Tetris is
    Port (
        clk         : in  STD_LOGIC;
        reset_n     : in  STD_LOGIC;
        btn         : in  STD_LOGIC_VECTOR(4 downto 0);
--        nes_data    : in STD_LOGIC;
--        nes_latch   : out STD_LOGIC;
--        nes_clk     : out STD_LOGIC;
        led         : out STD_LOGIC_VECTOR(2 downto 0);
        ja          : inout std_logic_vector(7 downto 0);
        tmds        : out STD_LOGIC_VECTOR(3 downto 0);
        tmdsb       : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Tetris;

architecture structure of Tetris is

    signal position : coordinate_t;

    signal game_tick : std_logic;

    signal btn_left_db   : std_logic;
    signal btn_right_db  : std_logic;
    signal btn_rotate_db : std_logic;
    signal btn_drop_db   : std_logic;
    signal btn_hard_db   : std_logic;

    signal piece_x       : integer range -3 to 9;
    signal piece_y       : integer range 0 to 19;
    signal piece_type    : integer range 0 to 6;
    signal rotation      : integer range 0 to 3;
    signal drop_y        : integer range 0 to 19;
    signal has_hold      : std_logic;

    signal piece_cells   : piece_cells_t;
    signal rotated_cells : piece_cells_t;

    signal board_data : board_t;
    signal lock_x       : integer range -3 to 9;
    signal lock_y       : integer range 0 to 19;
    signal lock_type    : integer range 0 to 6;
    signal lock_cells   : piece_cells_t;

    signal move_left   : std_logic;
    signal move_right  : std_logic;
    signal rotate_cmd  : std_logic;
    signal soft_drop   : std_logic;
    signal hard_drop   : std_logic;
    signal spawn_tetr : std_logic;

    signal wr_en    : std_logic;
    signal clear_en : std_logic;
    signal shift_en : std_logic;

    signal left_valid   : std_logic;
    signal right_valid  : std_logic;
    signal down_valid   : std_logic;
    signal rotate_valid : std_logic;
    signal spawn_valid  : std_logic;
    signal rotate_left_valid  : std_logic;
    signal rotate_right_valid : std_logic;
    signal hard_drop_y  : integer range 0 to 19;

    signal lc_clear_en  : std_logic;
    signal lc_shift_en  : std_logic;
    signal rows_cleared : integer range 0 to 4;
    signal score        : unsigned(31 downto 0);
    
    signal nes_a        : std_logic;
    signal nes_b        : std_logic;
    signal nes_select   : std_logic;
    signal nes_start    : std_logic;
    signal nes_up       : std_logic;
    signal nes_down     : std_logic;
    signal nes_left     : std_logic;
    signal nes_right    : std_logic;
    signal nes_latch_s : std_logic;
    signal nes_clk_s   : std_logic;
    signal nes_data_s  : std_logic;
    
    signal nes_a_prev      : std_logic := '0';
    signal nes_b_prev      : std_logic := '0';
    signal nes_down_prev   : std_logic := '0';
    signal nes_left_prev   : std_logic := '0';
    signal nes_right_prev  : std_logic := '0';
    signal nes_start_prev  : std_logic := '0';
    
    signal nes_a_pulse     : std_logic := '0';
    signal nes_b_pulse     : std_logic := '0';
    signal nes_down_pulse  : std_logic := '0';
    signal nes_left_pulse  : std_logic := '0';
    signal nes_right_pulse : std_logic := '0';
    signal nes_select_prev  : std_logic := '0';
    signal nes_select_pulse : std_logic := '0';
    signal nes_start_pulse : std_logic := '0';
    signal game_reset_n    : std_logic;
    signal hold_piece_cmd   : std_logic;
    signal hold_type        : integer range 0 to 6;
    signal hold_used        : std_logic;
    
    signal game_btn_left      : std_logic;
    signal game_btn_right     : std_logic;
    signal game_btn_rotate    : std_logic;
    signal game_btn_drop      : std_logic;
    signal game_btn_hard_drop : std_logic;
    
    signal nes_debug_state : std_logic_vector(2 downto 0);
    signal nes_bit_index   : std_logic_vector(2 downto 0);
    signal nes_shift_reg   : std_logic_vector(7 downto 0);
    
    signal total_score : unsigned(31 downto 0);
    signal lines_total : unsigned(7 downto 0);
    signal next_type   : integer range 0 to 6;
    
    signal rand_piece : integer range 0 to 6;

    signal state_dbg : game_state_t;

begin

    u_game_clock : entity work.game_clock
        port map (
            clk       => clk,
            reset_n   => reset_n,
            game_tick => game_tick,
            score     => score
        );

    u_btn_left : entity work.button_debounce
        port map (
            clk    => clk,
            reset  => reset_n,
            button => btn(2),
            action => btn_left_db
        );

    u_btn_right : entity work.button_debounce
        port map (
            clk    => clk,
            reset  => reset_n,
            button => btn(3),
            action => btn_right_db
        );

    u_btn_rotate : entity work.button_debounce
        port map (
            clk    => clk,
            reset  => reset_n,
            button => btn(1),
            action => btn_rotate_db
        );

    u_btn_drop : entity work.button_debounce
        port map (
            clk    => clk,
            reset  => reset_n,
            button => btn(4),
            action => btn_drop_db
        );

    u_btn_hard : entity work.button_debounce
        port map (
            clk    => clk,
            reset  => reset_n,
            button => btn(0),
            action => btn_hard_db
        );

    u_piece_logic : entity work.piece_logic
        port map (
            clk           => clk,
            reset_n       => game_reset_n,
            move_left     => move_left,
            move_right    => move_right,
            rotate        => rotate_cmd,
            soft_drop     => soft_drop,
            hard_drop     => hard_drop,
            drop_y        => drop_y,
            spawn_tetr    => spawn_tetr,
            piece_x       => piece_x,
            piece_y       => piece_y,
            rotation      => rotation,
            piece_type    => piece_type,
            piece_cells   => piece_cells,
            rotated_cells => rotated_cells,
            hold_piece    => hold_piece_cmd,
            hold_type     => hold_type,
            next_type     => next_type,
            hold_used     => hold_used,
            has_hold      => has_hold,
            rand_piece    => rand_piece
        );
        
    u_piece_randomizer : entity work.piece_randomizer
        port map (
            clk        => clk,
            reset_n    => game_reset_n,
            rand_piece => rand_piece
        );

    u_board_memory : entity work.board_memory
        port map (
            clk         => clk,
            reset_n     => game_reset_n,
            wr_en       => wr_en,
            clear_en    => clear_en,
            shift_en    => shift_en,
            piece_x     => lock_x,
            piece_y     => lock_y,
            piece_type  => lock_type,
            piece_cells => lock_cells,
            board_data  => board_data
        );

    u_collision_detector : entity work.collision_detector
        port map (
            board_data         => board_data,
            piece_x            => piece_x,
            piece_y            => piece_y,
            piece_cells        => piece_cells,
            rotated_cells      => rotated_cells,
            left_valid         => left_valid,
            right_valid        => right_valid,
            down_valid         => down_valid,
            rotate_valid       => rotate_valid,
            rotate_left_valid  => rotate_left_valid,
            rotate_right_valid => rotate_right_valid,
            spawn_valid        => spawn_valid,
            hard_drop_y        => hard_drop_y
        );

    u_line_clear : entity work.line_clear
        port map (
            board_data   => board_data,
            clear_en     => lc_clear_en,
            rows_cleared => rows_cleared,
            shift_en     => lc_shift_en,
            score        => score
        );
        
    u_score_counter : entity work.score_counter
        port map (
            clk          => clk,
            reset_n      => game_reset_n,
            clear_pulse  => shift_en,
            rows_cleared => rows_cleared,
            score        => total_score,
            lines_total  => lines_total
        );

    u_game_fsm : entity work.game_fsm
        port map (
            clk             => clk,
            reset_n         => game_reset_n,
            game_tick       => game_tick,
            btn_left      => game_btn_left,
            btn_right     => game_btn_right,
            btn_rotate    => game_btn_rotate,
            btn_drop      => game_btn_drop,
            btn_hard_drop => game_btn_hard_drop,
            piece_y         => piece_y,
            left_valid      => left_valid,
            right_valid     => right_valid,
            down_valid      => down_valid,
            rotate_valid    => rotate_valid,
            spawn_valid     => spawn_valid,
            hard_drop_y_in  => hard_drop_y,
            rows_cleared    => rows_cleared,
            move_left       => move_left,
            move_right      => move_right,
            rotate          => rotate_cmd,
            soft_drop       => soft_drop,
            hard_drop       => hard_drop,
            spawn_tetr     => spawn_tetr,
            drop_y          => drop_y,
            wr_en           => wr_en,
            clear_en        => clear_en,
            shift_en        => shift_en,
            piece_x       => piece_x,
            piece_type    => piece_type,
            piece_cells   => piece_cells,
            lock_x        => lock_x,
            lock_y        => lock_y,
            lock_type     => lock_type,
            lock_cells    => lock_cells,
            rotate_left_valid  => rotate_left_valid,
            rotate_right_valid => rotate_right_valid,
            state_dbg       => state_dbg
        );

    u_video : entity work.video
        port map (
            clk        => clk,
            reset_n    => reset_n,
            tmds       => tmds,
            tmdsb      => tmdsb,
            position   => position,
            board_data => board_data,
            piece_x    => piece_x,
            piece_y    => piece_y,
            piece_type => piece_type,
            rotation   => rotation,
            piece_cells => piece_cells,
            score       => total_score,
            lines_total => lines_total,
            hold_type   => hold_type,
            next_type   => next_type,
            rows_cleared => rows_cleared,
            has_hold    => has_hold
        );
        
    u_nes : entity work.nes
        port map (
            clk        => clk,
            reset_n    => reset_n,
            nes_data  => nes_data_s,
            nes_latch => nes_latch_s,
            nes_clk   => nes_clk_s,
            btn_a      => nes_a,
            btn_b      => nes_b,
            btn_select => nes_select,
            btn_start  => nes_start,
            btn_up     => nes_up,
            btn_down   => nes_down,
            btn_left   => nes_left,
            btn_right  => nes_right,
            debug_state     => nes_debug_state,
            debug_bit_index => nes_bit_index,
            debug_shift_reg => nes_shift_reg
        );
        
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                nes_a_prev      <= '0';
                nes_b_prev      <= '0';
                nes_down_prev   <= '0';
                nes_left_prev   <= '0';
                nes_right_prev  <= '0';
                nes_select_prev  <= '0';
                nes_start_prev  <= '0';
    
                nes_a_pulse     <= '0';
                nes_b_pulse     <= '0';
                nes_down_pulse  <= '0';
                nes_left_pulse  <= '0';
                nes_right_pulse <= '0';
                nes_select_pulse <= '0';
                nes_start_pulse <= '0';

    
            else
                nes_a_pulse     <= nes_a     and not nes_a_prev;
                nes_b_pulse     <= nes_b     and not nes_b_prev;
                nes_down_pulse  <= nes_down  and not nes_down_prev;
                nes_left_pulse  <= nes_left  and not nes_left_prev;
                nes_right_pulse <= nes_right and not nes_right_prev;
                nes_select_pulse <= nes_select and not nes_select_prev;
                nes_start_pulse <= nes_start and not nes_start_prev;

    
                nes_a_prev      <= nes_a;
                nes_b_prev      <= nes_b;
                nes_down_prev   <= nes_down;
                nes_left_prev   <= nes_left;
                nes_right_prev  <= nes_right;
                nes_select_prev  <= nes_select;
                nes_start_prev  <= nes_start;
                
            end if;
        end if;
    end process;

    led(0) <= '1' when state_dbg = GAME_OVER else '0';
    led(1) <= nes_left;
    led(2) <= nes_right;
    
    game_btn_left      <= btn_left_db   or nes_left_pulse;
    game_btn_right     <= btn_right_db  or nes_right_pulse;
    game_btn_rotate    <= btn_rotate_db or nes_a_pulse;
    game_btn_drop      <= btn_drop_db   or nes_down_pulse;
    game_btn_hard_drop <= btn_hard_db   or nes_b_pulse;
    
    game_reset_n <= reset_n and not nes_start_pulse;
    
    hold_piece_cmd <= nes_select_pulse;
    
-- JA wiring for NES controller
    nes_data_s <= ja(2);

    ja(0) <= nes_latch_s;
    ja(1) <= nes_clk_s;
    
    ja(3) <= nes_debug_state(0);
    ja(4) <= nes_debug_state(1);
    ja(5) <= nes_debug_state(2);
    
    ja(6) <= nes_left;
    ja(7) <= nes_right;

end structure;