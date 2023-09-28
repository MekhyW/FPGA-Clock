library ieee;
use ieee.std_logic_1164.all;

entity cpu is
  port   (
    control_in : in std_logic_vector(1 downto 0);
	 control_out : out std_logic_vector(1 downto 0);
    rom_address: out std_logic_vector(8 downto 0);
	 data_in : in std_logic_vector(7 downto 0);
	 instruction_in : in std_logic_vector(12 downto 0);
	 data_out : out std_logic_vector(7 downto 0);
	 data_address : out std_logic_vector(8 downto 0)
  );
end entity;


architecture arquitetura of cpu is

  signal MUX_REG1 : std_logic_vector (7 downto 0);
  signal MUX_PC : std_logic_vector (8 downto 0);
  signal REG1_ULA_A : std_logic_vector (7 downto 0);
  signal Saida_ULA : std_logic_vector(7 downto 0);
  
  signal Sinais_Controle : std_logic_vector (11 downto 0);
  signal Sinais_decoder : std_logic_vector (3 downto 0);
  
  signal Endereco : std_logic_vector (8 downto 0);
  signal proxPC : std_logic_vector (8 downto 0);
  
  alias CLK : std_logic is control_in(1);
  alias RESET : std_logic is control_in(0);
  
  signal SelMUX : std_logic;
  signal Habilita_A : std_logic;
  signal habMem_leitura : std_logic;
  signal habMem_escrita : std_logic;
  signal JMP : std_logic;
  signal JEQ : std_logic;
  signal RET : std_logic;
  signal JSR : std_logic;
  signal Operacao_ULA : std_logic_vector(1 downto 0);
  
  signal habilitaFlag_igual : std_logic;
  signal habilita_ret : std_logic;
  signal flagIgual_in : std_logic_vector(0 downto 0);
  signal flagIgual_uc : std_logic_vector(0 downto 0);
  signal selMux_pc : std_logic_vector(1 downto 0);
  signal endret : std_logic_vector(8 downto 0);
  
  alias imediato : std_logic_vector (7 downto 0) is instruction_in(7 downto 0);
  alias endereco_bus:  std_logic_vector(8 downto 0) is instruction_in(8 downto 0);

begin

-- Instanciando os componentes:

-- O port map completo do MUX.
MUX1 :  entity work.muxGenerico2x1  generic map (larguraDados => 8)
        port map( entradaA_MUX => data_in,
                 entradaB_MUX =>  imediato,
                 seletor_MUX => SelMUX,
                 saida_MUX => MUX_REG1);

-- O port map completo do Acumulador.
REGA : entity work.registradorGenerico   generic map (larguraDados => 8)
          port map (DIN => Saida_ULA, DOUT => REG1_ULA_A, ENABLE => Habilita_A, CLK => CLK, RST => '0');

-- O port map completo do Program Counter.
PC : entity work.registradorGenerico   generic map (larguraDados => 9)
          port map (DIN => MUX_PC, DOUT => Endereco, ENABLE => '1', CLK => CLK, RST => control_in(0));

incrementaPC :  entity work.somaConstante  generic map (larguraDados => 9, constante => 1)
        port map( entrada => Endereco, saida => proxPC);


-- O port map completo da ULA:
ULA1 : entity work.ULASomaSub  generic map(larguraDados => 8)
          port map (entradaA => REG1_ULA_A, entradaB => MUX_REG1, saida => Saida_ULA, seletor => Operacao_ULA, zero => flagIgual_in(0));

dec : entity work.decoderInstru 
			port map (opcode => Sinais_decoder, saida => Sinais_Controle);

		
mux2: entity work.muxGenerico4x1 generic map(larguraDados => 9) port map( entradaA_MUX => proxPC,
                 entradaB_MUX =>  endereco_bus,
					  entradaC_MUX => endret,
					  entradaD_MUX => "000000000",
                 seletor_MUX => selMux_pc,
                 saida_MUX => MUX_PC);
					  
flagIgual : entity work.registradorGenerico   generic map (larguraDados => 1)
          port map (DIN => flagIgual_in, DOUT => flagIgual_uc, ENABLE => habilitaFlag_igual, CLK => CLK, RST => '0');
			 
endretu : entity work.registradorGenerico   generic map (larguraDados => 9)
          port map (DIN => proxPC, DOUT => endret, ENABLE => habilita_ret , CLK => CLK, RST => '0');
		

Sinais_decoder <= instruction_in(12 downto 9);
data_address <= endereco_bus;

rom_address <= Endereco;
data_out <= REG1_ULA_A;

habilita_ret <= Sinais_Controle(11);
JMP <= Sinais_Controle(10);
RET <= Sinais_Controle(9);
JSR <= Sinais_Controle(8);
JEQ <= Sinais_Controle(7);
selMUX <= Sinais_Controle(6);
Habilita_A <= Sinais_Controle(5);
Operacao_ULA <= Sinais_Controle(4 downto 3);
habilitaFlag_igual <= Sinais_Controle(2);
control_out(1) <= Sinais_Controle(1);
control_out(0) <= Sinais_Controle(0);

selMux_pc <= "10" when (RET = '1') else
				 "01" when (JMP = '1' or JSR = '1' or (JEQ = '1' and flagIgual_uc(0) = '1')) else
				 --"11" when (control_in(0) = '1') else
				 "00";

end architecture;