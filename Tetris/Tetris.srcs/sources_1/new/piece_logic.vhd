----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2026 12:37:02 PM
-- Design Name: 
-- Module Name: piece_logic - Behavioral
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

entity piece_logic is
    port (
        clk           : in  std_logic;
        reset_n       : in  std_logic;
        move_left     : in  std_logic;
        move_right    : in  std_logic;
        rotate        : in  std_logic;
        soft_drop     : in  std_logic;
        hard_drop     : in  std_logic;
        hold_piece    : in  std_logic;
        spawn_tetr   : in  std_logic;
        drop_y        : in integer range 0 to 19;
        piece_x       : out integer range -3 to 9;
        piece_y       : out integer range 0 to 19;
        rotation      : out integer range 0 to 3;
        piece_type    : out integer range 0 to 6;
        hold_type     : out integer range 0 to 5;
        hold_used     : out std_logic;
        next_type     : out integer range 0 to 6;
        has_hold      : out std_logic;
        rand_piece    : in integer range 0 to 6;
        piece_cells   : out piece_cells_t;
        rotated_cells : out piece_cells_t
    );
end piece_logic;

architecture Behavioral of piece_logic is

    signal s_piece_x    : integer range -3 to 9 := 3;
    signal s_piece_y    : integer range 0 to 19 := 0;
    signal s_rotation   : integer range 0 to 3 := 0;
    signal s_piece_type : integer range 0 to 6 := 0;
    signal next_piece_type : integer range 0 to 6 := 0;
    signal s_piece_cells   : piece_cells_t;
    signal s_rotated_cells : piece_cells_t;
    signal s_hold_type : integer range 0 to 6 := 0;
    signal s_has_hold  : std_logic := '0';
    signal s_hold_used : std_logic := '0';

begin

    --------------------------------------------------------------------------
    -- Piece position/type/rotation registers
    --------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset_n = '0' then
                s_piece_x       <= 3;
                s_piece_y       <= 0;
                s_rotation      <= 0;
                s_piece_type    <= 0;
                next_piece_type <= rand_piece;
                s_hold_type <= 0;
                s_has_hold  <= '0';
                s_hold_used <= '0';

            else
                if spawn_tetr = '1' then
                    s_piece_x    <= 3;
                    s_piece_y    <= 0;
                    s_rotation   <= 0;
                    s_hold_used <= '0';
                    s_piece_type <= next_piece_type;
                    next_piece_type <= rand_piece;
                else
                
                    if hold_piece = '1' and s_hold_used = '0' then
                    
                        if s_has_hold = '0' then
                            -- first hold: store current piece and spawn next piece
                            s_hold_type <= s_piece_type;
                            s_piece_x <= 3;
                            s_piece_y <= 0;
                            s_rotation <= 0;
                            s_piece_type <= next_piece_type;
                    
                            if next_piece_type = 6 then
                                next_piece_type <= 0;
                            else
                                next_piece_type <= next_piece_type + 1;
                            end if;
                    
                            s_has_hold <= '1';
                    
                        else
                            -- swap current piece with held piece
                            s_piece_type <= s_hold_type;
                            s_hold_type <= s_piece_type;
                            s_piece_x <= 3;
                            s_piece_y <= 0;
                            s_rotation <= 0;
                        end if;
                    
                        s_hold_used <= '1';
                    end if;

                    if move_left = '1' and s_piece_x > -3 then
                        s_piece_x <= s_piece_x - 1;
                    end if;

                    if move_right = '1' and s_piece_x < 9 then
                        s_piece_x <= s_piece_x + 1;
                    end if;

                    if rotate = '1' then
                        if s_rotation = 3 then
                            s_rotation <= 0;
                        else
                            s_rotation <= s_rotation + 1;
                        end if;
                    end if;

                    if soft_drop = '1' and s_piece_y < 19 then
                        s_piece_y <= s_piece_y + 1;
                    end if;

                    -- NOTE:
                    -- True hard drop needs collision/board info.
                    -- For now, this just moves the piece to the bottom row.
                    if hard_drop = '1' then
                        s_piece_y <= drop_y;
                    end if;
                end if;
            end if;
        end if;
    end process;

    --------------------------------------------------------------------------
    -- Convert piece_type + rotation into 4 relative cells
    -- Each cell is relative to piece_x, piece_y.
    --------------------------------------------------------------------------
    process(s_piece_type, s_rotation)
    begin
        case s_piece_type is

            ------------------------------------------------------------------
            -- I piece
            ------------------------------------------------------------------
            when 0 =>
                if s_rotation mod 2 = 0 then
                    s_piece_cells(0) <= (dx => 0, dy => 1);
                    s_piece_cells(1) <= (dx => 1, dy => 1);
                    s_piece_cells(2) <= (dx => 2, dy => 1);
                    s_piece_cells(3) <= (dx => 3, dy => 1);
                else
                    s_piece_cells(0) <= (dx => 1, dy => 0);
                    s_piece_cells(1) <= (dx => 1, dy => 1);
                    s_piece_cells(2) <= (dx => 1, dy => 2);
                    s_piece_cells(3) <= (dx => 1, dy => 3);
                end if;

            ------------------------------------------------------------------
            -- O piece
            ------------------------------------------------------------------
            when 1 =>
                s_piece_cells(0) <= (dx => 1, dy => 1);
                s_piece_cells(1) <= (dx => 2, dy => 1);
                s_piece_cells(2) <= (dx => 1, dy => 2);
                s_piece_cells(3) <= (dx => 2, dy => 2);

            ------------------------------------------------------------------
            -- T piece
            ------------------------------------------------------------------
            when 2 =>
                case s_rotation is
                    when 0 =>
                        s_piece_cells(0) <= (dx => 0, dy => 1);
                        s_piece_cells(1) <= (dx => 1, dy => 1);
                        s_piece_cells(2) <= (dx => 2, dy => 1);
                        s_piece_cells(3) <= (dx => 1, dy => 2);
                    when 1 =>
                        s_piece_cells(0) <= (dx => 1, dy => 0);
                        s_piece_cells(1) <= (dx => 1, dy => 1);
                        s_piece_cells(2) <= (dx => 1, dy => 2);
                        s_piece_cells(3) <= (dx => 0, dy => 1);
                    when 2 =>
                        s_piece_cells(0) <= (dx => 0, dy => 1);
                        s_piece_cells(1) <= (dx => 1, dy => 1);
                        s_piece_cells(2) <= (dx => 2, dy => 1);
                        s_piece_cells(3) <= (dx => 1, dy => 0);
                    when others =>
                        s_piece_cells(0) <= (dx => 1, dy => 0);
                        s_piece_cells(1) <= (dx => 1, dy => 1);
                        s_piece_cells(2) <= (dx => 1, dy => 2);
                        s_piece_cells(3) <= (dx => 2, dy => 1);
                end case;

            ------------------------------------------------------------------
            -- L piece
            ------------------------------------------------------------------
            when 3 =>
                case s_rotation is
                    when 0 =>
                        s_piece_cells(0) <= (dx => 0, dy => 0);
                        s_piece_cells(1) <= (dx => 0, dy => 1);
                        s_piece_cells(2) <= (dx => 0, dy => 2);
                        s_piece_cells(3) <= (dx => 1, dy => 2);
                    when 1 =>
                        s_piece_cells(0) <= (dx => 0, dy => 1);
                        s_piece_cells(1) <= (dx => 1, dy => 1);
                        s_piece_cells(2) <= (dx => 2, dy => 1);
                        s_piece_cells(3) <= (dx => 0, dy => 2);
                    when 2 =>
                        s_piece_cells(0) <= (dx => 1, dy => 0);
                        s_piece_cells(1) <= (dx => 1, dy => 1);
                        s_piece_cells(2) <= (dx => 1, dy => 2);
                        s_piece_cells(3) <= (dx => 0, dy => 0);
                    when others =>
                        s_piece_cells(0) <= (dx => 0, dy => 1);
                        s_piece_cells(1) <= (dx => 1, dy => 1);
                        s_piece_cells(2) <= (dx => 2, dy => 1);
                        s_piece_cells(3) <= (dx => 2, dy => 0);
                end case;

            ------------------------------------------------------------------
            -- J piece
            ------------------------------------------------------------------
            when 4 =>
                case s_rotation is
                    when 0 =>
                        s_piece_cells(0) <= (dx => 1, dy => 0);
                        s_piece_cells(1) <= (dx => 1, dy => 1);
                        s_piece_cells(2) <= (dx => 1, dy => 2);
                        s_piece_cells(3) <= (dx => 0, dy => 2);
                    when 1 =>
                        s_piece_cells(0) <= (dx => 0, dy => 1);
                        s_piece_cells(1) <= (dx => 1, dy => 1);
                        s_piece_cells(2) <= (dx => 2, dy => 1);
                        s_piece_cells(3) <= (dx => 0, dy => 0);
                    when 2 =>
                        s_piece_cells(0) <= (dx => 0, dy => 0);
                        s_piece_cells(1) <= (dx => 0, dy => 1);
                        s_piece_cells(2) <= (dx => 0, dy => 2);
                        s_piece_cells(3) <= (dx => 1, dy => 0);
                    when others =>
                        s_piece_cells(0) <= (dx => 0, dy => 1);
                        s_piece_cells(1) <= (dx => 1, dy => 1);
                        s_piece_cells(2) <= (dx => 2, dy => 1);
                        s_piece_cells(3) <= (dx => 2, dy => 2);
                end case;

            ------------------------------------------------------------------
            -- S piece
            ------------------------------------------------------------------
            when 5 =>
                if s_rotation mod 2 = 0 then
                    s_piece_cells(0) <= (dx => 1, dy => 1);
                    s_piece_cells(1) <= (dx => 2, dy => 1);
                    s_piece_cells(2) <= (dx => 0, dy => 2);
                    s_piece_cells(3) <= (dx => 1, dy => 2);
                else
                    s_piece_cells(0) <= (dx => 0, dy => 0);
                    s_piece_cells(1) <= (dx => 0, dy => 1);
                    s_piece_cells(2) <= (dx => 1, dy => 1);
                    s_piece_cells(3) <= (dx => 1, dy => 2);
                end if;

            ------------------------------------------------------------------
            -- Z piece
            ------------------------------------------------------------------
            when others =>
                if s_rotation mod 2 = 0 then
                    s_piece_cells(0) <= (dx => 0, dy => 1);
                    s_piece_cells(1) <= (dx => 1, dy => 1);
                    s_piece_cells(2) <= (dx => 1, dy => 2);
                    s_piece_cells(3) <= (dx => 2, dy => 2);
                else
                    s_piece_cells(0) <= (dx => 1, dy => 0);
                    s_piece_cells(1) <= (dx => 1, dy => 1);
                    s_piece_cells(2) <= (dx => 0, dy => 1);
                    s_piece_cells(3) <= (dx => 0, dy => 2);
                end if;

        end case;
    end process;
    
    --same as previous process, but anticipating rotation
    process(s_piece_type, s_rotation)
    variable next_rot : integer range 0 to 3;
begin
    if s_rotation = 3 then
        next_rot := 0;
    else
        next_rot := s_rotation + 1;
    end if;

    case s_piece_type is

        when 0 =>
            if next_rot mod 2 = 0 then
                s_rotated_cells(0) <= (dx => 0, dy => 1);
                s_rotated_cells(1) <= (dx => 1, dy => 1);
                s_rotated_cells(2) <= (dx => 2, dy => 1);
                s_rotated_cells(3) <= (dx => 3, dy => 1);
            else
                s_rotated_cells(0) <= (dx => 1, dy => 0);
                s_rotated_cells(1) <= (dx => 1, dy => 1);
                s_rotated_cells(2) <= (dx => 1, dy => 2);
                s_rotated_cells(3) <= (dx => 1, dy => 3);
            end if;

        when 1 =>
            s_rotated_cells(0) <= (dx => 1, dy => 1);
            s_rotated_cells(1) <= (dx => 2, dy => 1);
            s_rotated_cells(2) <= (dx => 1, dy => 2);
            s_rotated_cells(3) <= (dx => 2, dy => 2);

        when 2 =>
            case next_rot is
                when 0 =>
                    s_rotated_cells(0) <= (dx => 0, dy => 1);
                    s_rotated_cells(1) <= (dx => 1, dy => 1);
                    s_rotated_cells(2) <= (dx => 2, dy => 1);
                    s_rotated_cells(3) <= (dx => 1, dy => 2);
                when 1 =>
                    s_rotated_cells(0) <= (dx => 1, dy => 0);
                    s_rotated_cells(1) <= (dx => 1, dy => 1);
                    s_rotated_cells(2) <= (dx => 1, dy => 2);
                    s_rotated_cells(3) <= (dx => 0, dy => 1);
                when 2 =>
                    s_rotated_cells(0) <= (dx => 0, dy => 1);
                    s_rotated_cells(1) <= (dx => 1, dy => 1);
                    s_rotated_cells(2) <= (dx => 2, dy => 1);
                    s_rotated_cells(3) <= (dx => 1, dy => 0);
                when others =>
                    s_rotated_cells(0) <= (dx => 1, dy => 0);
                    s_rotated_cells(1) <= (dx => 1, dy => 1);
                    s_rotated_cells(2) <= (dx => 1, dy => 2);
                    s_rotated_cells(3) <= (dx => 2, dy => 1);
            end case;

        when others =>
            s_rotated_cells <= s_piece_cells;

    end case;
end process;

    piece_x         <= s_piece_x;
    piece_y         <= s_piece_y;
    rotation        <= s_rotation;
    piece_type      <= s_piece_type;
    piece_cells     <= s_piece_cells;
    rotated_cells   <= s_rotated_cells;
    hold_type       <= s_hold_type;
    hold_used       <= s_hold_used;
    next_type       <= next_piece_type;
    has_hold        <= s_has_hold;

end Behavioral;