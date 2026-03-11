-- Edited by Lt Col James Trimble to provide user feedback describing the configuration of Lab2
-- George York, modification of C2C Alexandre Some's final project, which...
-- This code was not mine and I edited it to fit my needs. 
-- Written by Ryan Kim, Digilent Inc.
-- Modified by Alexandre Some and then George York
-- 
-- Description: Top level controller that controls the OLED display.
--   After you press CPU_Reset_button, displays background LED_screen
--   and then overlays a zero or one (binary) for each of the 8 switches
--   and also prints the value as two Hex digits.
--   The values of the 8 switches are also shown on the 8 LEDs

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;


entity Lab2_OLED is
    port (  clk         : in std_logic;
            reset_n     : in std_logic;
            oled_sdin   : out std_logic;
            oled_sclk   : out std_logic;
            oled_dc     : out std_logic;
            oled_res    : out std_logic;
            oled_vbat   : out std_logic;
            oled_vdd    : out std_logic;            
            switch      : in STD_LOGIC_VECTOR(7 downto 0));
end Lab2_OLED;

architecture Lab2_OLED_arch of Lab2_OLED is

    component oled_init is
        port (  clk         : in std_logic;
                rst         : in std_logic;
                en          : in std_logic;                
                sdout       : out std_logic;
                oled_sclk   : out std_logic;
                oled_dc     : out std_logic;
                oled_res    : out std_logic;
                oled_vbat   : out std_logic;
                oled_vdd    : out std_logic;
                fin         : out std_logic);
    end component;

    component oled_ex is
        port (  clk         : in std_logic;
                rst         : in std_logic;
                en          : in std_logic;
                switch      : in std_logic_vector(7 downto 0);
                sdout       : out std_logic;
                oled_sclk   : out std_logic;
                oled_dc     : out std_logic;
                fin         : out std_logic);
    end component;

    type states is (Idle, OledInitialize, OledExample, Done);

    signal current_state : states := Idle;

    signal init_en          : std_logic := '0';
    signal init_done        : std_logic;
    signal init_sdata       : std_logic;
    signal init_spi_clk     : std_logic;
    signal init_dc          : std_logic;

    signal example_en       : std_logic := '0';
    signal example_sdata    : std_logic;
    signal example_spi_clk  : std_logic;
    signal example_dc       : std_logic;
    signal example_done     : std_logic;
    
    signal rst              : std_logic;
begin

    rst <= reset_n;
    
    Initialize: oled_init port map (clk => clk,
                                    rst => rst,
                                    en => init_en,
                                    sdout => init_sdata,
                                    oled_sclk => init_spi_clk,
                                    oled_dc => init_dc,
                                    oled_res => oled_res,
                                    oled_vbat => oled_vbat,
                                    oled_vdd => oled_vdd,
                                    fin => init_done);

    Example: oled_ex port map ( clk => clk,
                                rst => rst,
                                en => example_en,
                                sdout => example_sdata,
                                switch => switch,  
                                oled_sclk => example_spi_clk,
                                oled_dc => example_dc,
                                fin => example_done);

    -- MUXes to indicate which outputs are routed out depending on which block is enabled
    oled_sdin <= init_sdata when current_state = OledInitialize else example_sdata;
    oled_sclk <= init_spi_clk when current_state = OledInitialize else example_spi_clk;
    oled_dc <= init_dc when current_state = OledInitialize else example_dc;
    -- End output MUXes

    -- MUXes that enable blocks when in the proper states
    init_en <= '1' when current_state = OledInitialize else '0';
    example_en <= '1' when current_state = OledExample else '0';
    -- End enable MUXes

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                current_state <= Idle;
            else
                case current_state is
                    when Idle =>
                        current_state <= OledInitialize;
                    -- Go through the initialization sequence
                    when OledInitialize =>
                        if init_done = '1' then
                            current_state <= OledExample;
                        end if;
                    -- Do example and do nothing when finished
                    when OledExample =>
                        if example_done = '1' then
                            current_state <= Done;
                        end if;
                    -- Do nthing
                    when Done =>
                        current_state <= Done;
                    when others =>
                        current_state <= Idle;
                end case;
            end if;
        end if;
    end process;

end Lab2_OLED_arch;
