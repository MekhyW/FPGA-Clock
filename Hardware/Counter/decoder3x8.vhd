library ieee;
use ieee.std_logic_1164.all;

entity decoder3x8 is
  port ( entrada : in std_logic_vector(2 downto 0);
         saida : out std_logic_vector(7 downto 0)
  );
end entity;

architecture comportamento of decoder3x8 is
  begin
    saida(7) <= '1' when (entrada = "111") else '0';
    saida(6) <= '1' when (entrada = "110") else '0';
    saida(5) <= '1' when (entrada = "101") else '0';
    saida(4) <= '1' when (entrada = "100") else '0';
    saida(3) <= '1' when (entrada = "011") else '0';
    saida(2) <= '1' when (entrada = "010") else '0';
    saida(1) <= '1' when (entrada = "001") else '0';
    saida(0) <= '1' when (entrada = "000") else '0';
end architecture;