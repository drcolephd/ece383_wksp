library ieee;
use ieee.std_logic_1164.all;

entity scancode_decoder_tb is
end entity;

architecture tb of scancode_decoder_tb is
  signal scancode      : std_logic_vector(7 downto 0) := (others => '0');
  signal decoded_value : std_logic_vector(3 downto 0);

begin
  uut: entity work.scancode_decoder
    port map (
      scancode      => scancode,
      decoded_value => decoded_value
    );

  stim: process
  begin
    scancode <= x"45"; wait for 10 ns;
    assert decoded_value = "0000" report "0x45 (expected 0)" severity error;

    scancode <= x"16"; wait for 10 ns;
    assert decoded_value = "0001" report "0x16  (expected 1)" severity error;

    scancode <= x"1E"; wait for 10 ns;
    assert decoded_value = "0010" report "0x1E (expected 2)" severity error;

    -- Test 3
    scancode <= x"26"; wait for 10 ns;
    assert decoded_value = "0011" report "0x26 (expected 3)" severity error;

    -- Test 4
    scancode <= x"25"; wait for 10 ns;
    assert decoded_value = "0100" report "0x25 (expected 4)" severity error;

    -- Test 5
    scancode <= x"2E"; wait for 10 ns;
    assert decoded_value = "0101" report "0x2E (expected 5)" severity error;

    -- Test 6
    scancode <= x"36"; wait for 10 ns;
    assert decoded_value = "0110" report "0x36 (expected 6)" severity error;

    -- Test 7
    scancode <= x"3D"; wait for 10 ns;
    assert decoded_value = "0111" report "0x3D (expected 7)" severity error;

    -- Test 8
    scancode <= x"3E"; wait for 10 ns;
    assert decoded_value = "1000" report "0x3E (expected 8)" severity error;

    -- Test 9
    scancode <= x"46"; wait for 10 ns;
    assert decoded_value = "1001" report "0x46 (expected 9)" severity error;

    -- If we got here, everything passed
    report "SUCCESS" severity note;

    wait; -- end sim
  end process;

end architecture tb;
