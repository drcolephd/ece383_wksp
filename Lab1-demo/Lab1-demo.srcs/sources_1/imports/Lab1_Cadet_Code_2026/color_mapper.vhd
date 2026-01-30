----------------------------------------------------------------------------------
-- Lt Col James Trimble, 16-Jan-2025
-- color_mapper (previously scope face) determines the pixel color value based on the row, column, triggers, and channel inputs 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;

entity color_mapper is
    Port ( color : out color_t;
           position: in coordinate_t;
		   trigger : in trigger_t;
           ch1 : in channel_t;
           ch2 : in channel_t);
end color_mapper;

architecture color_mapper_arch of color_mapper is

signal trigger_color : color_t := YELLOW; 
-- Add other colors you want to use here

signal is_vertical_gridline, is_horizontal_gridline, is_within_grid, is_trigger_time, is_trigger_volt, is_ch1_line, is_ch2_line,
    is_horizontal_hash, is_vertical_hash : boolean := false;
    
-- Fill in values here
constant grid_start_row : integer := 20;
constant grid_stop_row : integer := 420;
constant grid_start_col : integer := 20;
constant grid_stop_col : integer := 620;
constant num_horizontal_gridblocks : integer := 10;
constant num_vertical_gridblocks : integer := 8;
constant center_column : integer := 320;
constant center_row : integer := 220;
constant hash_size : integer := 1;
constant hash_horizontal_spacing : integer := 15;
constant hash_vertical_spacing : integer := 10;

constant h_grid_space : integer := grid_stop_col - grid_start_col;
constant v_grid_space : integer := grid_stop_row - grid_start_row;
constant v_grid_step  : integer := h_grid_space / num_horizontal_gridblocks;
constant h_grid_step  : integer := v_grid_space / num_vertical_gridblocks;

begin

-- Assign values to booleans here
is_within_grid <= (to_integer(position.row) >= grid_start_row) and
                  (to_integer(position.row) <= grid_stop_row) and
                  (to_integer(position.col) >= grid_start_col) and
                  (to_integer(position.col) <= grid_stop_col);

is_vertical_gridline <=     is_within_grid and
                            (
                                (to_integer(position.col) = grid_start_col) or
                                (to_integer(position.col) = grid_stop_col) or
                                (((to_integer(position.col) - grid_start_col) mod v_grid_step) = 0)
                            );

is_horizontal_gridline <=   is_within_grid and
                            (
                                (to_integer(position.row) = grid_start_row) or
                                (to_integer(position.row) = grid_stop_row) or
                                (((to_integer(position.row) - grid_start_row) mod h_grid_step) = 0)
                            );

is_horizontal_hash <=       is_within_grid and
                                (to_integer(position.row) >= center_row - hash_size) and
                                (to_integer(position.row) <= center_row + hash_size) and
                                (((to_integer(position.col) - grid_start_col) mod hash_horizontal_spacing) = 0
                            );

is_vertical_hash <=         is_within_grid and
                                (to_integer(position.col) >= center_column - hash_size) and
                                (to_integer(position.col) <= center_column + hash_size) and
                                (((to_integer(position.row) - grid_start_row) mod hash_vertical_spacing) = 0
                            );
                            
is_ch1_line            <= true when (position.col = position.row) and is_within_grid and (ch1.en = '1' and ch1.active = '1') else false;
 
is_ch2_line            <= true when (grid_stop_row + 20 - position.row) = position.col and is_within_grid and (ch2.en = '1' and ch2.active = '1') else false;
 
is_trigger_time        <= true when is_within_grid and abs(to_integer(position.col) - to_integer(trigger.t)) < 7 - (to_integer(position.row) - 20)

                          else false;

is_trigger_volt        <= true when is_within_grid and abs(to_integer(position.row) - to_integer(trigger.v)) < 7 - (to_integer(position.col) - 20)

                          else false;
 

-- Use your booleans to choose the color                                   
color <=  trigger_color when (is_trigger_time or is_trigger_volt) else
          GREEN         when ((is_ch2_line) and is_within_grid) else
          YELLOW        when ((is_ch1_line) and is_within_grid) else
          WHITE         when (is_vertical_gridline or is_horizontal_gridline or is_horizontal_hash or is_vertical_hash) else
          BLACK;

end color_mapper_arch;
