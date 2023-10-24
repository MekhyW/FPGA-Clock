library IEEE;
use ieee.std_logic_1164.all;

entity buffer_3_state is
    port(
        entrada  : in std_logic;
        habilita : in std_logic;
        saida    : out std_logic);
end entity;

architecture comportamento of buffer_3_state is
begin
    -- A saida esta ativa quando o habilita = 1.
    saida <= 'Z' when (habilita = '0') else entrada;
end architecture;