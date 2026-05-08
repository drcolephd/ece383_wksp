------
-- Lt Col James Trimble, 15 Jan 2025
-- Generates VGA signal with graphics
------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;
 
entity vga is
    Port(
        clk       : in  STD_LOGIC;
        reset_n   : in  STD_LOGIC;
        vga       : out vga_t;
        pixel     : out pixel_t;
        board_data: in  board_t;
        piece_x   : in integer range -3 to 9;
        piece_y   : in integer range 0 to 19;
        piece_type: in integer range 0 to 6;
        piece_cells : in piece_cells_t;
        rotation  : in integer range 0 to 3;
        score        : in unsigned(31 downto 0);
        lines_total  : in unsigned(7 downto 0);
        hold_type    : in integer range 0 to 6;
        next_type    : in integer range 0 to 6;
        rows_cleared : in integer range 0 to 4;
        has_hold     : in std_logic
    );
end vga;

architecture vga_arch of vga is
		
    signal s_position : coordinate_t;
    signal s_vga      : vga_t;
    signal s_color    : color_t;
    signal s_pixel    : pixel_t;
    	
begin

    u_vga_sig : entity work.vga_signal_generator
        port map (
            clk      => clk,
            reset_n  => reset_n,
            position => s_position,
            vga      => s_vga
        );

    u_color : entity work.color_mapper
    port map (
        color      => s_color,
        position   => s_position,
        board_data => board_data,
        piece_x    => piece_x,
        piece_y    => piece_y,
        piece_type => piece_type,
        rotation   => rotation,
        piece_cells => piece_cells,
        score       => score,
        lines_total => lines_total,
        hold_type   => hold_type,
        next_type   => next_type,
        rows_cleared => rows_cleared,
        has_hold    => has_hold
    );

    s_pixel.coordinate <= s_position;
    s_pixel.color      <= s_color;

    -- Drive output ports
    vga   <= s_vga;
    pixel <= s_pixel;


end vga_arch;
