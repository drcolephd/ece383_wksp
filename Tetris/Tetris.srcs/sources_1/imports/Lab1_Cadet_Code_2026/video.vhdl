-- Structural component to connect clock_wiz, VGA, and DVID
-- by Lt Col James Trimble, 20 Jan 2026

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ece383_pkg.all;

entity video is
    port (
        clk        : in  STD_LOGIC;
        reset_n    : in  STD_LOGIC;
        tmds       : out STD_LOGIC_VECTOR (3 downto 0);
        tmdsb      : out STD_LOGIC_VECTOR (3 downto 0);
        position   : out coordinate_t;
        piece_x    : in integer range -3 to 9;
        piece_y    : in integer range 0 to 19;
        piece_type : in integer range 0 to 6;
        rotation   : in integer range 0 to 3;
        score        : in unsigned(31 downto 0);
        lines_total  : in unsigned(7 downto 0);
        hold_type    : in integer range 0 to 6;
        next_type    : in integer range 0 to 6;
        rows_cleared : in integer range 0 to 4;
        has_hold    : in std_logic;
        board_data : in board_t;
        piece_cells : in piece_cells_t    
    );
end video;

architecture structure of video is

	signal red, green, blue: STD_LOGIC_VECTOR(7 downto 0);
	signal pixel_clk, serialize_clk, serialize_clk_n, blank, h_sync, v_sync: STD_LOGIC;
	signal clock_s, red_s, green_s, blue_s: STD_LOGIC;
	signal h_synch, v_synch: STD_LOGIC;
	signal vga_signal: vga_t;
	signal pixel: pixel_t;


    --------------------------------------------------------------------------
    -- Clock Wizard Component Instantiation Using Xilinx Vivado 
    --------------------------------------------------------------------------
    component clk_wiz_2 is
    Port (
        clk_in1 : in STD_LOGIC;
        clk_out1 : out STD_LOGIC;
        clk_out2 : out STD_LOGIC;
        clk_out3 : out STD_LOGIC;
        resetn : in STD_LOGIC);
     end component;   

begin

	--------------------------------------------------------------------------
	-- Digital Clocking Wizard using Xilinx Vivado creates 25Mhz pixel clock and 
	-- 125MHz HDMI serial output clocks from 100MHz system clock. The Digital 
    -- Clocking Wizard is in the Vivado IP Catalog.
	--------------------------------------------------------------------------
	mmcm_adv_inst_display_clocks: clk_wiz_2
		Port Map (
			clk_in1 => clk,
			clk_out1 => pixel_clk, -- 25Mhz pixel clock
			clk_out2 => serialize_clk, -- 125Mhz HDMI serial output clock
			clk_out3 => serialize_clk_n, -- 125Mhz HDMI serial output clock 180 degrees out of phase
			resetn => reset_n);  -- active low reset for Nexys Video

	------------------------------------------------------------------------------
	-- H and V synch are used to interface to the DVID module
	------------------------------------------------------------------------------
	inst_vga: entity work.vga
    port map (
        clk        => pixel_clk,
        reset_n    => reset_n,
        vga        => vga_signal,
        pixel      => pixel,
        piece_x    => piece_x,
        piece_y    => piece_y,
        piece_type => piece_type,
        rotation   => rotation,
        board_data => board_data,
        piece_cells => piece_cells,
        score       => score,
        lines_total => lines_total,
        hold_type   => hold_type,
        next_type   => next_type,
        rows_cleared => rows_cleared,
        has_hold    => has_hold
    );
			
	position <= pixel.coordinate;
	
	------------------------------------------------------------------------------
	-- This module was provided to us free of charge.  It converts a VGA signal
	-- into DVID/HDMI signal.
	------------------------------------------------------------------------------	 
    inst_dvid: entity work.dvid 
		port map(	    clk  => serialize_clk,
						clk_n     => serialize_clk_n, 
						clk_pixel => pixel_clk,
						red_p     => Get_Red(pixel.color),
						green_p   => Get_Green(pixel.color),
						blue_p    => Get_Blue(pixel.color),
						blank     => vga_signal.blank,
						hsync     => vga_signal.hsync,
						vsync     => vga_signal.vsync,
						red_s     => red_s,
						green_s   => green_s,
						blue_s    => blue_s,
						clock_s   => clock_s		);


	------------------------------------------------------------------------------
	-- This HDMI signals are high speed so buffer to ensure signal integrity.
	------------------------------------------------------------------------------
	OBUFDS_blue  : OBUFDS port map
        ( O  => TMDS(0), OB => TMDSB(0), I  => blue_s  );
	OBUFDS_red   : OBUFDS port map
        ( O  => TMDS(1), OB => TMDSB(1), I  => green_s );
	OBUFDS_green : OBUFDS port map
        ( O  => TMDS(2), OB => TMDSB(2), I  => red_s   );
	OBUFDS_clock : OBUFDS port map
        ( O  => TMDS(3), OB => TMDSB(3), I  => clock_s );

end structure;
