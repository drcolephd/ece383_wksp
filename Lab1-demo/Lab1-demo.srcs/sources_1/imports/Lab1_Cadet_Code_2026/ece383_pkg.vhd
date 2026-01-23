----------------------------------------------------------------------------------
-- Lt Col James Trimble, 16 Jan 2025
-- This package is designed to house types/records, constants, functions, and components that you want to reuse.
-- Signals cannot be used here and variables are not recommended.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ece383_pkg is
  --= SUBTYPES/RECORDS =--
  subtype color_t is std_logic_vector(23 downto 0);
  
  -- Holds a location
  type coordinate_t is record
       row: unsigned (9 downto 0);
       col: unsigned (9 downto 0);
  end record;
  
  -- Holds a pixel's location and color
  type pixel_t is record
        coordinate: coordinate_t;
        color: color_t;
  end record;
    
  -- Holds the h_sync, v_sync, blank, and r,g,b signals for a VGA display
  type vga_t is record
        hsync : std_logic;
        vsync : std_logic;
        blank : std_logic;
  end record;
  
  -- Used to track the time and voltage locations for triggering
  type trigger_t is record
        t: unsigned(10 downto 0);
        v: unsigned(10 downto 0);
  end record;
  
  -- An input channel to be processed/displayed
  type channel_t is record
    active: std_logic;
    en: std_logic;
  end record;
  
  --= CONSTANTS ==-
  constant WHITE : color_t := x"FFFFFF";
  constant BLACK : color_t := x"000000";
  constant RED : color_t := x"FF0000";
  constant GREEN : color_t := x"00FF00";
  constant BLUE : color_t := x"0000FF";
  constant YELLOW : color_t := x"FFFE0E";
  
  
  --= COMPONENTS =--
  -- This is the general purpose counter from HW4.  ctrl=1 for count up mode, 0 for hold.
  component counter is
    generic (
      num_bits  : integer := 4;
      max_value : integer := 9
    );
    port ( clk : in std_logic;
           reset_n : in std_logic;
           ctrl : in std_logic;
           roll : out std_logic;
           Q : out unsigned (num_bits-1 downto 0));
  end component;

  -- The num_stepper takes input from a button and increments/decrements its register by delta based on the button presses
  component numeric_stepper is
  generic (
    num_bits  : integer := 8;
    max_value : integer := 127;
    min_value : integer := -128;
    delta     : integer := 10
  );
  port (
    clk     : in  std_logic;
    reset_n : in  std_logic;                    -- active-low synchronous reset
    en      : in  std_logic;                    -- enable
    up      : in  std_logic;                    -- increment on rising edge
    down    : in  std_logic;                    -- decrement on rising edge
    q       : out signed(num_bits-1 downto 0)   -- signed output
  );
  end component;
  
  -- Generates the signals needed for VGA video  
  component vga_signal_generator is
    port ( clk : in STD_LOGIC;
           reset_n : in STD_LOGIC;
           position: out coordinate_t;
           vga : out vga_t);
    end component;			
			
   -- Maps the pixel location (row,col) to a color based on the location, triggers, and channel values.
   component color_mapper is
   port (  color : out color_t;
           position: in coordinate_t;
		   trigger : in trigger_t;
           ch1 : in channel_t;
           ch2 : in channel_t);			
   end component;
   
   -- Holds the pixel clock, VGA component, and DVID (HDMI OUT)
   component video is
    port (  clk : in  STD_LOGIC;
            reset_n : in  STD_LOGIC;
            tmds : out  STD_LOGIC_VECTOR (3 downto 0);
            tmdsb : out  STD_LOGIC_VECTOR (3 downto 0);
            trigger: in trigger_t;
            position: out coordinate_t;
            ch1: in channel_t;
            ch2: in channel_t);
	end component;	  
	
	-- Structural component which holds the vga_signal_generator and the color_mapper
	component vga is
	port(	clk: in  STD_LOGIC;
			reset_n : in  STD_LOGIC;
			vga: out vga_t;
			pixel: out pixel_t;
			trigger: in trigger_t;
			ch1: in channel_t;
			ch2: in channel_t);
	end component;
  
  --= FUNCTIONS ==-
  function Get_Red(rgb : std_logic_vector(23 downto 0)) return std_logic_vector;
  function Get_Green(rgb : std_logic_vector(23 downto 0)) return std_logic_vector;
  function Get_Blue(rgb : std_logic_vector(23 downto 0)) return std_logic_vector;
  
end package ece383_pkg;

package body ece383_pkg is
  -- Usually empty for component-only packages.
  -- (Package bodies are for functions/procedures/constants needing implementation.)

  --= FUNCTIONS =--
  -- Function to extract the red component
  function Get_Red(rgb : std_logic_vector(23 downto 0)) return std_logic_vector is
  begin
      return rgb(23 downto 16); -- Red slice
  end function;
  
  -- Function to extract the green component
  function Get_Green(rgb : std_logic_vector(23 downto 0)) return std_logic_vector is
  begin
      return rgb(15 downto 8); -- Green slice
  end function;
  
  -- Function to extract the blue component
  function Get_Blue(rgb : std_logic_vector(23 downto 0)) return std_logic_vector is
  begin
      return rgb(7 downto 0); -- Blue slice
  end function;

end package body ece383_pkg;