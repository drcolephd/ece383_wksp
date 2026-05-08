----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/01/2026 01:56:20 PM
-- Design Name: 
-- Module Name: collision_detector - Behavioral
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

entity collision_detector is
    port (
        board_data    : in board_t;

        piece_x       : in integer range -3 to 9;
        piece_y       : in integer range 0 to 19;
        piece_cells   : in piece_cells_t;
        rotated_cells : in piece_cells_t;

        left_valid    : out std_logic;
        right_valid   : out std_logic;
        down_valid    : out std_logic;
        rotate_valid  : out std_logic;
        spawn_valid   : out std_logic;

        hard_drop_y   : out integer range 0 to 19;
        
        rotate_left_valid  : out std_logic;
        rotate_right_valid : out std_logic
    );
end collision_detector;

architecture Behavioral of collision_detector is

    function valid_position(
        b     : board_t;
        cells : piece_cells_t;
        px    : integer;
        py    : integer
    ) return boolean is
        variable bx : integer;
        variable by : integer;
    begin
        for i in 0 to 3 loop
            bx := px + cells(i).dx;
            by := py + cells(i).dy;

            if bx < 0 or bx > 9 or by < 0 or by > 19 then
                return false;
            end if;

            if b(by)(bx) /= EMPTY then
                return false;
            end if;
        end loop;

        return true;
    end function;

    function find_hard_drop_y(
        b     : board_t;
        cells : piece_cells_t;
        px    : integer;
        py    : integer
    ) return integer is
        variable final_y : integer := py;
    begin
        for test_y in 0 to 19 loop
            if test_y >= py then
                if valid_position(b, cells, px, test_y) then
                    final_y := test_y;
                else
                    return final_y;
                end if;
            end if;
        end loop;

        return final_y;
    end function;

begin

    process(board_data, piece_x, piece_y, piece_cells, rotated_cells)
    begin
        if valid_position(board_data, piece_cells, piece_x - 1, piece_y) then
            left_valid <= '1';
        else
            left_valid <= '0';
        end if;

        if valid_position(board_data, piece_cells, piece_x + 1, piece_y) then
            right_valid <= '1';
        else
            right_valid <= '0';
        end if;

        if valid_position(board_data, piece_cells, piece_x, piece_y + 1) then
            down_valid <= '1';
        else
            down_valid <= '0';
        end if;

        if valid_position(board_data, rotated_cells, piece_x, piece_y) then
            rotate_valid <= '1';
        else
            rotate_valid <= '0';
        end if;

        if valid_position(board_data, piece_cells, piece_x, piece_y) then
            spawn_valid <= '1';
        else
            spawn_valid <= '0';
        end if;

        hard_drop_y <= find_hard_drop_y(board_data, piece_cells, piece_x, piece_y);
    
        if valid_position(board_data, rotated_cells, piece_x - 1, piece_y) then
            rotate_left_valid <= '1';
        else
            rotate_left_valid <= '0';
        end if;
        
        if valid_position(board_data, rotated_cells, piece_x + 1, piece_y) then
            rotate_right_valid <= '1';
        else
            rotate_right_valid <= '0';
        end if;
    end process;
    

end Behavioral;
