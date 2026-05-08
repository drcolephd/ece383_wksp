----------------------------------------------------------------------------------
-- Lt Col James Trimble, 16-Jan-2025
-- color_mapper (previously scope face) determines the pixel color value based on the row, column, triggers, and channel inputs 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity color_mapper is
    Port (
        color      : out color_t;
        position   : in  coordinate_t;
        board_data : in  board_t;
        piece_x    : in  integer range -3 to 9;
        piece_y    : in  integer range 0 to 19;
        piece_type : in  integer range 0 to 6;
        piece_cells : in piece_cells_t;
        rotation   : in  integer range 0 to 3;
        score        : in unsigned(31 downto 0);
        lines_total  : in unsigned(7 downto 0);
        hold_type    : in integer range 0 to 6;
        next_type    : in integer range 0 to 6;
        rows_cleared : in integer range 0 to 4;
        has_hold     : in std_logic
    );
end color_mapper;

architecture Behavioral of color_mapper is

    constant BOARD_LEFT   : integer := 220;
    constant BOARD_TOP    : integer := 40;
    constant CELL_SIZE    : integer := 20;
    constant BOARD_WIDTH  : integer := 10;
    constant BOARD_HEIGHT : integer := 20;

    constant BOARD_RIGHT  : integer := BOARD_LEFT + BOARD_WIDTH * CELL_SIZE - 1;
    constant BOARD_BOTTOM : integer := BOARD_TOP + BOARD_HEIGHT * CELL_SIZE - 1;
    
    constant HOLD_LEFT : integer := 40;
    constant HOLD_TOP  : integer := 80;
    
    constant NEXT_LEFT : integer := 480;
    constant NEXT_TOP  : integer := 80;
    
    constant MINI_CELL : integer := 12;

    signal board_row       : integer range 0 to 19 := 0;
    signal board_col       : integer range 0 to 9 := 0;
    signal is_within_board : boolean := false;
    signal is_border       : boolean := false;
    signal is_active_piece : boolean := false;
    signal is_locked_block : boolean := false;
    signal is_hold_piece_preview : boolean := false;
    signal is_next_piece_preview : boolean := false;
    signal is_hold_border : boolean := false;
    signal is_next_border : boolean := false;
    signal is_score_bar : boolean := false;
    signal is_line_bar  : boolean := false;

    --------------------------------------------------------------------------
    -- Returns true if a tetromino has a block at relative location dx, dy
    --------------------------------------------------------------------------
    
    function piece_has_cell(
        ptype : integer;
        rot   : integer;
        dx    : integer;
        dy    : integer
    ) return boolean is
    begin
        case ptype is

            -- I piece
            when 0 =>
                if rot mod 2 = 0 then
                    return (dy = 1 and dx >= 0 and dx <= 3);
                else
                    return (dx = 1 and dy >= 0 and dy <= 3);
                end if;

            -- O piece
            when 1 =>
                return ((dx = 1 or dx = 2) and (dy = 1 or dy = 2));

            -- T piece
            when 2 =>
                case rot is
                    when 0 =>
                        return (dy = 1 and dx >= 0 and dx <= 2) or
                               (dx = 1 and dy = 2);
                    when 1 =>
                        return (dx = 1 and dy >= 0 and dy <= 2) or
                               (dx = 0 and dy = 1);
                    when 2 =>
                        return (dy = 1 and dx >= 0 and dx <= 2) or
                               (dx = 1 and dy = 0);
                    when others =>
                        return (dx = 1 and dy >= 0 and dy <= 2) or
                               (dx = 2 and dy = 1);
                end case;

            -- L piece
            when 3 =>
                case rot is
                    when 0 =>
                        return (dx = 0 and dy >= 0 and dy <= 2) or
                               (dx = 1 and dy = 2);
                    when 1 =>
                        return (dy = 1 and dx >= 0 and dx <= 2) or
                               (dx = 0 and dy = 2);
                    when 2 =>
                        return (dx = 1 and dy >= 0 and dy <= 2) or
                               (dx = 0 and dy = 0);
                    when others =>
                        return (dy = 1 and dx >= 0 and dx <= 2) or
                               (dx = 2 and dy = 0);
                end case;

            -- J piece
            when 4 =>
                case rot is
                    when 0 =>
                        return (dx = 1 and dy >= 0 and dy <= 2) or
                               (dx = 0 and dy = 2);
                    when 1 =>
                        return (dy = 1 and dx >= 0 and dx <= 2) or
                               (dx = 0 and dy = 0);
                    when 2 =>
                        return (dx = 0 and dy >= 0 and dy <= 2) or
                               (dx = 1 and dy = 0);
                    when others =>
                        return (dy = 1 and dx >= 0 and dx <= 2) or
                               (dx = 2 and dy = 2);
                end case;

            -- S piece
            when 5 =>
                if rot mod 2 = 0 then
                    return ((dy = 1 and (dx = 1 or dx = 2)) or
                            (dy = 2 and (dx = 0 or dx = 1)));
                else
                    return ((dx = 0 and (dy = 0 or dy = 1)) or
                            (dx = 1 and (dy = 1 or dy = 2)));
                end if;

            -- Z piece
            when others =>
                if rot mod 2 = 0 then
                    return ((dy = 1 and (dx = 0 or dx = 1)) or
                            (dy = 2 and (dx = 1 or dx = 2)));
                else
                    return ((dx = 1 and (dy = 0 or dy = 1)) or
                            (dx = 0 and (dy = 1 or dy = 2)));
                end if;

        end case;
    end function;

    --------------------------------------------------------------------------
    -- Converts stored board cell ID to display color
    --------------------------------------------------------------------------
    function cell_to_color(cell : cell_t) return color_t is
    begin
        case cell is
            when EMPTY  => return BLACK;
            when I_CELL => return BLUE;
            when O_CELL => return YELLOW;
            when T_CELL => return RED;
            when L_CELL => return GREEN;
            when J_CELL => return WHITE;
            when S_CELL => return x"00FFFF";
            when others => return x"FF00FF";
        end case;
    end function;

    --------------------------------------------------------------------------
    -- Converts active piece type to display color
    --------------------------------------------------------------------------
    function piece_color(ptype : integer) return color_t is
    begin
        case ptype is
            when 0      => return BLUE;
            when 1      => return YELLOW;
            when 2      => return RED;
            when 3      => return GREEN;
            when 4      => return WHITE;
            when 5      => return x"00FFFF";
            when others => return x"FF00FF";
        end case;
    end function;
    
    function preview_has_cell(
        ptype : integer;
        px    : integer;
        py    : integer
    ) return boolean is
    begin
        return piece_has_cell(ptype, 0, px, py);
    end function;

begin

    process(position, piece_x, piece_y, piece_type, rotation, board_data)
        variable r  : integer;
        variable c  : integer;
        variable br : integer;
        variable bc : integer;
        variable dx : integer;
        variable dy : integer;
        variable within_temp : boolean;
        variable hold_dx : integer;
        variable hold_dy : integer;
        variable next_dx : integer;
        variable next_dy : integer;
        variable is_hold_preview : boolean;
        variable is_next_preview : boolean;
        variable hold_border_temp : boolean;
        variable next_border_temp : boolean;
        
    begin
        r := to_integer(position.row);
        c := to_integer(position.col);

        within_temp :=
            (r >= BOARD_TOP) and (r <= BOARD_BOTTOM) and
            (c >= BOARD_LEFT) and (c <= BOARD_RIGHT);

        is_within_board <= within_temp;

        if within_temp then
            br := (r - BOARD_TOP) / CELL_SIZE;
            bc := (c - BOARD_LEFT) / CELL_SIZE;
        else
            br := 0;
            bc := 0;
        end if;

        board_row <= br;
        board_col <= bc;

        is_border <= within_temp and
            ((r = BOARD_TOP) or (r = BOARD_BOTTOM) or
             (c = BOARD_LEFT) or (c = BOARD_RIGHT));

        dx := bc - piece_x;
        dy := br - piece_y;

        is_active_piece <= false;

        if within_temp then
            for i in 0 to 3 loop
                if (piece_x + piece_cells(i).dx = bc) and
                   (piece_y + piece_cells(i).dy = br) then
                    is_active_piece <= true;
                end if;
            end loop;
        end if;

        if within_temp then
            is_locked_block <= (board_data(br)(bc) /= EMPTY);
        else
            is_locked_block <= false;
        end if;
        
        is_hold_preview := false;
        is_next_preview := false;
        
        if has_hold = '1' then
            if r >= HOLD_TOP and r < HOLD_TOP + 4*MINI_CELL and
               c >= HOLD_LEFT and c < HOLD_LEFT + 4*MINI_CELL then
        
                hold_dx := (c - HOLD_LEFT) / MINI_CELL;
                hold_dy := (r - HOLD_TOP) / MINI_CELL;
        
                is_hold_preview := piece_has_cell(hold_type, 0, hold_dx, hold_dy);
            end if;
        end if;
        
        if r >= HOLD_TOP and r < HOLD_TOP + 4*MINI_CELL and
           c >= HOLD_LEFT and c < HOLD_LEFT + 4*MINI_CELL then
        
            hold_dx := (c - HOLD_LEFT) / MINI_CELL;
            hold_dy := (r - HOLD_TOP) / MINI_CELL;
        
            is_hold_preview := preview_has_cell(hold_type, hold_dx, hold_dy);
        end if;
        
        if r >= NEXT_TOP and r < NEXT_TOP + 4*MINI_CELL and
           c >= NEXT_LEFT and c < NEXT_LEFT + 4*MINI_CELL then
        
            next_dx := (c - NEXT_LEFT) / MINI_CELL;
            next_dy := (r - NEXT_TOP) / MINI_CELL;
        
            is_next_preview := preview_has_cell(next_type, next_dx, next_dy);
        end if;
        
        hold_border_temp :=
            (r >= HOLD_TOP and r < HOLD_TOP + 4*MINI_CELL and
             c >= HOLD_LEFT and c < HOLD_LEFT + 4*MINI_CELL) and
            (r = HOLD_TOP or r = HOLD_TOP + 4*MINI_CELL - 1 or
             c = HOLD_LEFT or c = HOLD_LEFT + 4*MINI_CELL - 1);
        
        next_border_temp :=
            (r >= NEXT_TOP and r < NEXT_TOP + 4*MINI_CELL and
             c >= NEXT_LEFT and c < NEXT_LEFT + 4*MINI_CELL) and
            (r = NEXT_TOP or r = NEXT_TOP + 4*MINI_CELL - 1 or
             c = NEXT_LEFT or c = NEXT_LEFT + 4*MINI_CELL - 1);
             
        is_score_bar <= (r >= 450 and r <= 459 and c >= 40 and c < 40 + to_integer(score(7 downto 0)));
    
        is_line_bar <= (r >= 470 and r <= 479 and c >= 40 and c < 40 + to_integer(lines_total));
        
        is_hold_border <= hold_border_temp;
        is_next_border <= next_border_temp;
        
        is_hold_piece_preview <= is_hold_preview;
        is_next_piece_preview <= is_next_preview;

    end process;

    color <= 
             WHITE when is_border else
             WHITE when is_hold_border else
             WHITE when is_next_border else
             GREEN when is_score_bar else
             YELLOW when is_line_bar else
             piece_color(hold_type) when is_hold_piece_preview else
             piece_color(next_type) when is_next_piece_preview else
             piece_color(piece_type) when is_active_piece else
             cell_to_color(board_data(board_row)(board_col)) when is_locked_block else
             BLACK;

end Behavioral;