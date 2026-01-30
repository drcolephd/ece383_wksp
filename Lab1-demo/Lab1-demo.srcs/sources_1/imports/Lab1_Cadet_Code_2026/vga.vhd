------
-- Lt Col James Trimble, 15 Jan 2025
-- Generates VGA signal with graphics
------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ece383_pkg.ALL;
 
entity vga is
	Port(	clk: in  STD_LOGIC;
			reset_n : in  STD_LOGIC;
			vga : out vga_t;
            pixel : out pixel_t;
			trigger : in trigger_t;
            ch1 : in channel_t;
            ch2 : in channel_t);
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
            color    => s_color,
            position => s_position,
            trigger  => trigger,
            ch1      => ch1,
            ch2      => ch2
        );

    s_pixel.coordinate <= s_position;
    s_pixel.color      <= s_color;

    -- Drive output ports
    vga   <= s_vga;
    pixel <= s_pixel;


end vga_arch;
