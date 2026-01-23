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
constant grid_start_row : integer := ;
constant grid_stop_row : integer := ;
constant grid_start_col : integer := ;
constant grid_stop_col : integer := ;
constant num_horizontal_gridblocks : integer := ;
constant num_vertical_gridblocks : integer := ;
constant center_column : integer := ;
constant center_row : integer := ;
constant hash_size : integer := ;
constant hash_horizontal_spacing : integer := ;
constant hash_vertical_spacing : integer := ;

begin

-- Assign values to booleans here
is_horizontal_gridline <= 

-- Use your booleans to choose the color
color <=        trigger_color when (is_trigger_time or is_trigger_volt) else -- You can do multiple lines like this
                                   

end color_mapper_arch;
