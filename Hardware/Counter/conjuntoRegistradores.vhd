library ieee;
use ieee.std_logic_1164.all;

entity conjuntoRegistradores is
  port   (
    data_in : in std_logic_vector(7 downto 0);
	 data_out : out std_logic_vector(7 downto 0);
	 habilita : in std_logic;
	 CLK : in std_logic;
	 seletor : in std_logic_vector(1 downto 0)
  );
end entity;


architecture arquitetura of conjuntoRegistradores is

signal reg0tobuf : std_logic_vector(7 downto 0);
signal reg1tobuf : std_logic_vector(7 downto 0);
signal reg2tobuf : std_logic_vector(7 downto 0);
signal reg3tobuf : std_logic_vector(7 downto 0);

signal habReg0 : std_logic;
signal habReg1 : std_logic;
signal habReg2 : std_logic;
signal habReg3 : std_logic;


begin

REG0 : entity work.registradorGenerico   generic map (larguraDados => 8)
          port map (DIN => data_in, DOUT => reg0tobuf, ENABLE => (habilita and habReg0), CLK => CLK, RST => '0');
			 
			 
REG1 : entity work.registradorGenerico   generic map (larguraDados => 8)
          port map (DIN => data_in, DOUT => reg1tobuf, ENABLE => (habilita and habReg1), CLK => CLK, RST => '0');
			 
			 
REG2 : entity work.registradorGenerico   generic map (larguraDados => 8)
          port map (DIN => data_in, DOUT => reg2tobuf, ENABLE => (habilita and habReg2), CLK => CLK, RST => '0');
			 
			 
REG3 : entity work.registradorGenerico   generic map (larguraDados => 8)
          port map (DIN => data_in, DOUT => reg3tobuf, ENABLE => (habilita and habReg3), CLK => CLK, RST => '0');
			 
			 
buffer0 :  entity work.buffer_3_state_8portas
        port map(entrada => reg0tobuf, habilita => habReg0, saida => data_out);
		  
		  
buffer1 :  entity work.buffer_3_state_8portas
        port map(entrada => reg1tobuf, habilita => habReg1, saida => data_out);
		  
		  
buffer2 :  entity work.buffer_3_state_8portas
        port map(entrada => reg2tobuf, habilita => habReg2, saida => data_out);
		  
		  
buffer3 :  entity work.buffer_3_state_8portas
        port map(entrada => reg3tobuf, habilita => habReg3, saida => data_out);
		  
		  
habReg0 <= '1' when (seletor = "00") else '0';
habReg1 <= '1' when (seletor = "01") else '0';
habReg2 <= '1' when (seletor = "10") else '0';
habReg3 <= '1' when (seletor = "11") else '0';


end architecture;