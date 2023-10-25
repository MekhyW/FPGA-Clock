LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity divisorGenerico_e_Interface is
   port(clk      :   in std_logic;
      limpaLeitura : in std_logic;
		base_div : in std_logic_vector(7 downto 0);
      leituraReg :   out std_logic
   );
end entity;

architecture interface of divisorGenerico_e_Interface is
  signal sinalUmSegundo : std_logic;
  signal saidaclk_reg1seg : std_logic;
begin

baseTempo: entity work.divisorGenerico
           generic map (divisor => 25000000)   -- divide por 10.
           port map (clk => clk, saida_clk => saidaclk_reg1seg, div_base => base_div);

registraUmSegundo: entity work.flipflopGenerico
   port map (DIN => '1', DOUT => leituraReg,
         ENABLE => '1', CLK => saidaclk_reg1seg,
         RST => limpaLeitura);


end architecture interface;