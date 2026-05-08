----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2026 12:52:50 PM
-- Design Name: 
-- Module Name: board_memory - Behavioral
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

entity board_memory is
    port (
        clk         : in  std_logic;
        reset_n     : in  std_logic;

        wr_en       : in  std_logic;
        clear_en    : in  std_logic;
        shift_en    : in  std_logic;

        piece_x     : in integer range -3 to 9;
        piece_y     : in integer range 0 to 19;
        piece_type  : in integer range 0 to 6;
        piece_cells : in piece_cells_t;

        board_data  : out board_t
    );
end board_memory;

architecture Behavioral of board_memory is

    signal s_board : board_t := (others => (others => EMPTY));

--    function piece_color(ptype : integer) return color_t is
--    begin
--        case ptype is
--            when 0      => return BLUE;
--            when 1      => return YELLOW;
--            when 2      => return RED;
--            when 3      => return GREEN;
--            when 4      => return WHITE;
--            when 5      => return x"00FFFF";
--            when others => return x"FF00FF";
--        end case;
--    end function;

    function row_full(row : row_t) return boolean is
    begin
        for x in 0 to 9 loop
            if row(x) = EMPTY then
                return false;
            end if;
        end loop;

        return true;
    end function;
    
    function piece_cell(ptype : integer) return cell_t is
    begin
        case ptype is
            when 0      => return I_CELL;
            when 1      => return O_CELL;
            when 2      => return T_CELL;
            when 3      => return L_CELL;
            when 4      => return J_CELL;
            when 5      => return S_CELL;
            when others => return Z_CELL;
        end case;
    end function;

begin

    process(clk)
    variable bx        : integer;
    variable by        : integer;
    variable temp_board : board_t;
    variable new_board  : board_t;
    variable write_y    : integer range 0 to 19;
begin
    if rising_edge(clk) then
        if reset_n = '0' then
            s_board <= (others => (others => EMPTY));

        elsif clear_en = '1' then
            s_board <= (others => (others => EMPTY));

        else
            temp_board := s_board;

            ----------------------------------------------------------
            -- Write locked piece
            ----------------------------------------------------------
            if wr_en = '1' then
                for i in 0 to 3 loop
                    bx := piece_x + piece_cells(i).dx;
                    by := piece_y + piece_cells(i).dy;

                    if bx >= 0 and bx <= 9 and by >= 0 and by <= 19 then
                        temp_board(by)(bx) := piece_cell(piece_type);
                    end if;
                end loop;
            end if;

            ----------------------------------------------------------
            -- Clear full rows and shift down
            ----------------------------------------------------------
            if shift_en = '1' then
                new_board := (others => (others => EMPTY));
                write_y := 19;

                for y in 19 downto 0 loop
                    if row_full(temp_board(y)) = false then
                        new_board(write_y) := temp_board(y);

                        if write_y > 0 then
                            write_y := write_y - 1;
                        end if;
                    end if;
                end loop;

                temp_board := new_board;
            end if;

            s_board <= temp_board;
        end if;
    end if;
end process;

    board_data <= s_board;

end Behavioral;