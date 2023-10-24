library ieee;
use ieee.std_logic_1164.all;

entity Clock is
  -- Total de bits das entradas e saidas
  generic (
        simulacao : boolean := TRUE -- para gravar na placa, altere de TRUE para FALSE
  );
  port   (
    CLOCK_50 : in std_logic;
	 FPGA_RESET_N : in std_logic;
    KEY: in std_logic_vector(3 downto 0);
	 SW : in std_logic_vector(9 downto 0);
    LEDR: out std_logic_vector(9 downto 0);
	 HEX0: OUT std_logic_vector(6 downto 0);
	 HEX1: OUT std_logic_vector(6 downto 0);
	 HEX2: OUT std_logic_vector(6 downto 0);
	 HEX3: OUT std_logic_vector(6 downto 0);
	 HEX4: OUT std_logic_vector(6 downto 0);
	 HEX5: OUT std_logic_vector(6 downto 0)
  );
end entity;


architecture arquitetura of Clock is


signal control_in : std_logic_vector(1 downto 0);
signal control_out : std_logic_vector(1 downto 0);

signal rom_addr : std_logic_vector(9 downto 0);
signal instruction : std_logic_vector(16 downto 0);

signal ramToCpu : std_logic_vector(7 downto 0);
signal cpuToRam : std_logic_vector(7 downto 0);
signal data_addr : std_logic_vector(9 downto 0);

signal blockDec : std_logic_vector(7 downto 0);
signal addrDec : std_logic_vector(7 downto 0);

signal Habilita_led : std_logic;
signal Habilita_wr : std_logic;
signal Habilita_rd : std_logic;

signal Habilita_sws : std_logic;
signal Habilita_sw8 : std_logic;
signal Habilita_sw9 : std_logic;

signal auxK0 : std_logic;
signal auxK1 : std_logic;
signal k0_out : std_logic_vector(0 downto 0);
signal k1_out : std_logic_vector(0 downto 0);
signal k0_reset : std_logic;
signal k1_reset : std_logic;

signal Habilita_key0 : std_logic;
signal Habilita_key1 : std_logic;
signal Habilita_key2 : std_logic;
signal Habilita_key3 : std_logic;
signal Habilita_reset : std_logic;

signal hex0ToDec : std_logic_vector(3 downto 0);
signal hex1ToDec : std_logic_vector(3 downto 0);
signal hex2ToDec : std_logic_vector(3 downto 0);
signal hex3ToDec : std_logic_vector(3 downto 0);
signal hex4ToDec : std_logic_vector(3 downto 0);
signal hex5ToDec : std_logic_vector(3 downto 0);

signal Habilita_hex0 : std_logic;
signal Habilita_hex1 : std_logic;
signal Habilita_hex2 : std_logic;
signal Habilita_hex3 : std_logic;
signal Habilita_hex4 : std_logic;
signal Habilita_hex5 : std_logic; 

begin


control_in(1) <= CLOCK_50;


detectorSub0: work.edgeDetector(bordaSubida) port map (clk => CLOCK_50, entrada => (not KEY(0)), saida => auxK0);
detectorSub1: work.edgeDetector(bordaSubida) port map (clk => CLOCK_50, entrada => (not KEY(1)), saida => auxK1);


proc : work.cpu port map(control_in => control_in, control_out => control_out, rom_address => rom_addr,
								instruction_in => instruction, data_in => ramToCpu, data_out => cpuToRam, data_address => data_addr);


ROM1 : entity work.memoriaROM   generic map (dataWidth => 17, addrWidth => 10)
          port map (Endereco => rom_addr, Dado => instruction);

ram: entity work.memoriaRAM generic map (dataWidth => 8, addrWidth => 6)
		port map (addr => data_addr(5 downto 0), we => control_out(0), re => control_out(1), habilita => blockDec(0),
		CLK => control_in(1), dado_in => cpuToRam, dado_out => ramToCpu);
		
blockControl :  entity work.decoder3x8
        port map( entrada => data_addr(8 downto 6),
                 saida => blockDec);
					  
addControl :  entity work.decoder3x8
        port map( entrada => data_addr(2 downto 0),
                 saida => addrDec);
					  
led_reg : entity work.registradorGenerico   generic map (larguraDados => 8)
          port map (DIN => cpuToRam, DOUT => LEDR(7 downto 0), ENABLE => Habilita_led, CLK => control_in(1), RST => '0');


wr_reg : entity work.registradorGenerico   generic map (larguraDados => 1)
          port map (DIN => cpuToRam(0 downto 0), DOUT => LEDR(8 downto 8), ENABLE => Habilita_wr, CLK => control_in(1), RST => '0');
			 
			 
k0_reg : entity work.registradorGenerico   generic map (larguraDados => 1)
          port map (DIN => "1", DOUT => k0_out(0 downto 0), ENABLE => '1', CLK => auxK0, RST => k0_reset);

			 
k1_reg : entity work.registradorGenerico   generic map (larguraDados => 1)
          port map (DIN => "1", DOUT => k1_out(0 downto 0), ENABLE => '1', CLK => auxK1, RST => k1_reset);

			 
rd_reg : entity work.registradorGenerico   generic map (larguraDados => 1)
          port map (DIN => cpuToRam(0 downto 0), DOUT => LEDR(9 downto 9), ENABLE => Habilita_rd, CLK => control_in(1), RST => '0');

hex0_dec :  entity work.conversorHex7Seg
            port map(dadoHex => hex0ToDec,
                    saida7seg => HEX0);
						  
hex1_dec :  entity work.conversorHex7Seg
            port map(dadoHex => hex1ToDec,
                    saida7seg => HEX1);
						  
hex2_dec :  entity work.conversorHex7Seg
            port map(dadoHex => hex2ToDec,
                    saida7seg => HEX2);
						  
hex3_dec :  entity work.conversorHex7Seg
            port map(dadoHex => hex3ToDec,
                    saida7seg => HEX3);
						  
hex4_dec :  entity work.conversorHex7Seg
            port map(dadoHex => hex4ToDec,
                    saida7seg => HEX4);
						  
hex5_dec :  entity work.conversorHex7Seg
            port map(dadoHex => hex5ToDec,
                    saida7seg => HEX5);
			 

hex0_reg : entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => cpuToRam(3 downto 0), DOUT => hex0ToDec, ENABLE => Habilita_hex0, CLK => control_in(1), RST => '0');


hex1_reg : entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => cpuToRam(3 downto 0), DOUT => hex1ToDec, ENABLE => Habilita_hex1, CLK => control_in(1), RST => '0');
			 
			 
hex2_reg : entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => cpuToRam(3 downto 0), DOUT => hex2ToDec, ENABLE => Habilita_hex2, CLK => control_in(1), RST => '0');			 


hex3_reg : entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => cpuToRam(3 downto 0), DOUT => hex3ToDec, ENABLE => Habilita_hex3, CLK => control_in(1), RST => '0');			 


hex4_reg : entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => cpuToRam(3 downto 0), DOUT => hex4ToDec, ENABLE => Habilita_hex4, CLK => control_in(1), RST => '0');


hex5_reg : entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => cpuToRam(3 downto 0), DOUT => hex5ToDec, ENABLE => Habilita_hex5, CLK => control_in(1), RST => '0');

buffer_8 :  entity work.buffer_3_state_8portas
        port map(entrada => SW(7 downto 0), habilita =>  Habilita_sws, saida => ramToCpu);

buffer_sw8 :  entity work.buffer_3_state
        port map(entrada => SW(8), habilita =>  Habilita_sw8, saida => ramToCpu(0));

buffer_sw9 :  entity work.buffer_3_state
        port map(entrada => SW(9), habilita =>  Habilita_sw9, saida => ramToCpu(0));

buffer_key0 :  entity work.buffer_3_state
        port map(entrada => k0_out(0), habilita =>  Habilita_key0, saida => ramToCpu(0));		  

buffer_key1 :  entity work.buffer_3_state
        port map(entrada => k1_out(0), habilita =>  Habilita_key1, saida => ramToCpu(0));

buffer_key2 :  entity work.buffer_3_state
        port map(entrada => (not KEY(2)), habilita =>  Habilita_key2, saida => ramToCpu(0));

buffer_key3 :  entity work.buffer_3_state
        port map(entrada => (not KEY(3)), habilita =>  Habilita_key3, saida => ramToCpu(0));

buffer_fpga :  entity work.buffer_3_state
        port map(entrada => (not FPGA_RESET_N), habilita =>  Habilita_reset, saida => ramToCpu(0));

		  
control_in(0) <= not(FPGA_RESET_N);	

Habilita_led <= (addrDec(0) and control_out(0) and blockDec(4) and (not(data_addr(5))));
Habilita_wr <= (addrDec(1) and control_out(0) and blockDec(4) and (not(data_addr(5))));
Habilita_rd <= (addrDec(2) and control_out(0) and blockDec(4) and (not(data_addr(5))));


Habilita_hex0 <= (addrDec(0) and control_out(0) and blockDec(4) and data_addr(5));
Habilita_hex1 <= (addrDec(1) and control_out(0) and blockDec(4) and data_addr(5));
Habilita_hex2 <= (addrDec(2) and control_out(0) and blockDec(4) and data_addr(5));
Habilita_hex3 <= (addrDec(3) and control_out(0) and blockDec(4) and data_addr(5));
Habilita_hex4 <= (addrDec(4) and control_out(0) and blockDec(4) and data_addr(5));
Habilita_hex5 <= (addrDec(5) and control_out(0) and blockDec(4) and data_addr(5));


Habilita_sws <= (addrDec(0) and control_out(1) and blockDec(5) and (not(data_addr(5))));
Habilita_sw8 <= (addrDec(1) and control_out(1) and blockDec(5) and (not(data_addr(5))));
Habilita_sw9 <= (addrDec(2) and control_out(1) and blockDec(5) and (not(data_addr(5))));


Habilita_key0 <= (addrDec(0) and control_out(1) and blockDec(5) and data_addr(5));
Habilita_key1 <= (addrDec(1) and control_out(1) and blockDec(5) and data_addr(5));
Habilita_key2 <= (addrDec(2) and control_out(1) and blockDec(5) and data_addr(5));
Habilita_key3 <= (addrDec(3) and control_out(1) and blockDec(5) and data_addr(5));
Habilita_reset <= (addrDec(4) and control_out(1) and blockDec(5) and data_addr(5));

k0_reset <= (control_out(0) and data_addr(0) and data_addr(1) and data_addr(2) and data_addr(3) and data_addr(4) and data_addr(5) and
data_addr(6) and data_addr(7) and data_addr(8));

k1_reset <= (control_out(0) and (not(data_addr(0))) and data_addr(1) and data_addr(2) and data_addr(3) and data_addr(4) and data_addr(5) and
data_addr(6) and data_addr(7) and data_addr(8)); 

end architecture;