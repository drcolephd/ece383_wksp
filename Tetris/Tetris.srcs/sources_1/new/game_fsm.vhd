library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity game_fsm is
    port (
        clk             : in  std_logic;
        reset_n         : in  std_logic;
        game_tick       : in  std_logic;

        btn_left        : in  std_logic;
        btn_right       : in  std_logic;
        btn_rotate      : in  std_logic;
        btn_drop        : in  std_logic;
        btn_hard_drop   : in  std_logic;

        piece_y         : in integer range 0 to 19;

        left_valid      : in std_logic;
        right_valid     : in std_logic;
        down_valid      : in std_logic;
        rotate_valid    : in std_logic;
        spawn_valid     : in std_logic;
        rotate_left_valid : in std_logic;
        rotate_right_valid : in std_logic;
        hard_drop_y_in  : in integer range 0 to 19;

        rows_cleared    : in integer range 0 to 4;
        
        piece_x     : in integer range -3 to 9;
        piece_type  : in integer range 0 to 6;
        piece_cells : in piece_cells_t;

        move_left       : out std_logic;
        move_right      : out std_logic;
        rotate          : out std_logic;
        soft_drop       : out std_logic;
        hard_drop       : out std_logic;
        spawn_tetr     : out std_logic;
        drop_y          : out integer range 0 to 19;

        wr_en           : out std_logic;
        clear_en        : out std_logic;
        shift_en        : out std_logic;
        
        lock_x      : out integer range -3 to 9;
        lock_y      : out integer range 0 to 19;
        lock_type   : out integer range 0 to 6;
        lock_cells  : out piece_cells_t;

        state_dbg       : out game_state_t
    );
end game_fsm;

architecture Behavioral of game_fsm is

    signal state      : game_state_t := RESET_INIT;
    signal next_state : game_state_t := RESET_INIT;

    signal s_move_left   : std_logic := '0';
    signal s_move_right  : std_logic := '0';
    signal s_rotate      : std_logic := '0';
    signal s_soft_drop   : std_logic := '0';
    signal s_hard_drop   : std_logic := '0';
    signal s_spawn_tetr : std_logic := '0';

    signal s_drop_y : integer range 0 to 19 := 0;

    signal s_wr_en    : std_logic := '0';
    signal s_clear_en : std_logic := '0';
    signal s_shift_en : std_logic := '0';
    
    signal s_lock_x     : integer range -3 to 9 := 0;
    signal s_lock_y     : integer range 0 to 19 := 0;
    signal s_lock_type  : integer range 0 to 6 := 0;
    signal s_lock_cells : piece_cells_t;

begin

    process(state, game_tick, btn_drop, btn_hard_drop,
            down_valid, spawn_valid, rows_cleared)
    begin
        next_state <= state;

        case state is
            when RESET_INIT =>
                next_state <= SPAWN_PIECE;

            when SPAWN_PIECE =>
                next_state <= WAIT_SPAWN;
                
            when WAIT_SPAWN =>
                next_state <= CHECK_SPAWN;

            when CHECK_SPAWN =>
                if spawn_valid = '1' then
                    next_state <= FALLING;
                else
                    next_state <= GAME_OVER;
                end if;

            when FALLING =>
                if btn_hard_drop = '1' then
                    next_state <= LOCK_CAPTURE;
                elsif game_tick = '1' or btn_drop = '1' then
                    if down_valid = '1' then
                        next_state <= FALLING;
                    else
                        next_state <= LOCK_CAPTURE;
                    end if;
                else
                    next_state <= FALLING;
                end if;
                
            when LOCK_CAPTURE =>
                next_state <= LOCK_PIECE;

            when LOCK_PIECE =>
                next_state <= WAIT_LOCK;
                
            when WAIT_LOCK =>
                next_state <= CHECK_CLEAR;    

            when CHECK_CLEAR =>
                if rows_cleared > 0 then
                    next_state <= CLEAR_ROWS;
                else
                    next_state <= SPAWN_PIECE;
                end if;

            when CLEAR_ROWS =>
                next_state <= WAIT_CLEAR;
                
            when WAIT_CLEAR =>
                next_state <= SPAWN_PIECE;

            when GAME_OVER =>
                next_state <= GAME_OVER;

            when others =>
                next_state <= RESET_INIT;
        end case;
    end process;

    process(state, btn_left, btn_right, btn_rotate, btn_drop, btn_hard_drop,
            game_tick, left_valid, right_valid, rotate_valid, down_valid,
            piece_y, hard_drop_y_in)
    begin
        s_move_left   <= '0';
        s_move_right  <= '0';
        s_rotate      <= '0';
        s_soft_drop   <= '0';
        s_hard_drop   <= '0';
        s_spawn_tetr <= '0';

        s_wr_en    <= '0';
        s_clear_en <= '0';
        s_shift_en <= '0';

        s_drop_y <= piece_y;

        case state is
            when RESET_INIT =>
                s_clear_en <= '1';

            when SPAWN_PIECE =>
                s_spawn_tetr <= '1';

            when FALLING =>
                if btn_left = '1' then
                    if left_valid = '1' then
                        s_move_left <= '1';
                    end if;
                elsif btn_right = '1' then
                    if right_valid = '1' then
                        s_move_right <= '1';
                    end if;
                elsif btn_rotate = '1' then
                    if rotate_valid = '1' then
                        s_rotate <= '1';
                
                    elsif rotate_left_valid = '1' then
                        s_move_left <= '1';
                        s_rotate <= '1';
                
                    elsif rotate_right_valid = '1' then
                        s_move_right <= '1';
                        s_rotate <= '1';
                    end if;
                end if;
                if btn_hard_drop = '1' then
                    s_drop_y <= hard_drop_y_in;
                    s_hard_drop <= '1';
                elsif game_tick = '1' or btn_drop = '1' then
                    if down_valid = '1' then
                        s_soft_drop <= '1';
                    end if;
                end if;

            when LOCK_PIECE =>
                s_wr_en <= '1';

            when CLEAR_ROWS =>
                s_shift_en <= '1';

            when others =>
                null;
        end case;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                state <= RESET_INIT;
            else
                state <= next_state;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                s_lock_x    <= 0;
                s_lock_y    <= 0;
                s_lock_type <= 0;
            elsif state = LOCK_CAPTURE then
                s_lock_x     <= piece_x;
                s_lock_type  <= piece_type;
                s_lock_cells <= piece_cells;
            
                if btn_hard_drop = '1' then
                    s_lock_y <= hard_drop_y_in;
                else
                    s_lock_y <= piece_y;
                end if;
            end if;
        end if;
    end process;

    move_left   <= s_move_left;
    move_right  <= s_move_right;
    rotate      <= s_rotate;
    soft_drop   <= s_soft_drop;
    hard_drop   <= s_hard_drop;
    spawn_tetr <= s_spawn_tetr;
    drop_y      <= s_drop_y;

    wr_en    <= s_wr_en;
    clear_en <= s_clear_en;
    shift_en <= s_shift_en;
    
    lock_x     <= s_lock_x;
    lock_y     <= s_lock_y;
    lock_type  <= s_lock_type;
    lock_cells <= s_lock_cells;

    state_dbg <= state;

end Behavioral;