library ieee;

use ieee.std_logic_1164.all;

entity scancode_decoder is
  port (
    scancode      : in  std_logic_vector(7 downto 0);
    decoded_value : out std_logic_vector(3 downto 0)
  );
  
end entity scancode_decoder;

architecture hw2 of scancode_decoder is
begin
  with scancode select
    decoded_value <=
      "0000" when x"45",
      "0001" when x"16",
      "0010" when x"1E",
      "0011" when x"26",
      "0100" when x"25",
      "0101" when x"2E",
      "0110" when x"36",
      "0111" when x"3D",
      "1000" when x"3E",
      "1001" when x"46",
      "0000" when others;
end architecture hw2;
