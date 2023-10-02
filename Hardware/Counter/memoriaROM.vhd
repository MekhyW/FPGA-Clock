library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoriaROM is
   generic (
          dataWidth: natural := 13;
          addrWidth: natural := 9
    );
   port (
          Endereco : in std_logic_vector (addrWidth-1 DOWNTO 0);
          Dado : out std_logic_vector (dataWidth-1 DOWNTO 0)
    );
end entity;

architecture assincrona of memoriaROM is

  constant NOP  : std_logic_vector(3 downto 0) := "0000";
  constant LDA  : std_logic_vector(3 downto 0) := "0001";
  constant SOMA : std_logic_vector(3 downto 0) := "0010";
  constant SUB  : std_logic_vector(3 downto 0) := "0011";
  constant LDI : std_logic_vector(3 downto 0) := "0100";
  constant STA : std_logic_vector(3 downto 0) := "0101";
  constant JMP : std_logic_vector(3 downto 0) := "0110";
  constant JEQ : std_logic_vector(3 downto 0) := "0111";
  constant CEQ : std_logic_vector(3 downto 0) := "1000";
  constant JSR : std_logic_vector(3 downto 0) := "1001";
  constant RET : std_logic_vector(3 downto 0) := "1010";
  constant OP_AND : std_logic_vector(3 downto 0) := "1011";

  type blocoMemoria is array(0 TO 2**addrWidth - 1) of std_logic_vector(dataWidth-1 DOWNTO 0);

  function initMemory
        return blocoMemoria is variable tmp : blocoMemoria := (others => (others => '0'));
  begin
        -- Inicializa os endereços:
       tmp(0) := x"4" & '0' & x"00";	-- LDI $0 	#setup inicializa em 0
tmp(1) := x"5" & '1' & x"00";	-- STA .LEDS
tmp(2) := x"5" & '1' & x"01";	-- STA .LED8
tmp(3) := x"5" & '1' & x"02";	-- STA .LED9
tmp(4) := x"5" & '1' & x"20";	-- STA .HEX0
tmp(5) := x"5" & '1' & x"21";	-- STA .HEX1
tmp(6) := x"5" & '1' & x"22";	-- STA .HEX2
tmp(7) := x"5" & '1' & x"23";	-- STA .HEX3
tmp(8) := x"5" & '1' & x"24";	-- STA .HEX4
tmp(9) := x"5" & '1' & x"25";	-- STA .HEX5
tmp(10) := x"5" & '0' & x"00";	-- STA @0 	#unidade
tmp(11) := x"5" & '0' & x"01";	-- STA @1 	#dezena
tmp(12) := x"5" & '0' & x"02";	-- STA @2 	#centena
tmp(13) := x"5" & '0' & x"03";	-- STA @3 	#unidade de milhar
tmp(14) := x"5" & '0' & x"04";	-- STA @4 	#dezena de milhar
tmp(15) := x"5" & '0' & x"05";	-- STA @5 	#centena de milhar
tmp(16) := x"5" & '0' & x"06";	-- STA @6 	#flag inibe contagem
tmp(17) := x"5" & '0' & x"0F";	-- STA @15 	#cte 0 para saber se botao esta solto
tmp(18) := x"4" & '0' & x"01";	-- LDI $1
tmp(19) := x"5" & '0' & x"0D";	-- STA @13 	#cte 1 para incrementar
tmp(20) := x"4" & '0' & x"0A";	-- LDI $10
tmp(21) := x"5" & '0' & x"07";	-- STA @7 	#limite unidade
tmp(22) := x"5" & '0' & x"08";	-- STA @8 	#limite dezena
tmp(23) := x"5" & '0' & x"09";	-- STA @9 	#limite centena
tmp(24) := x"5" & '0' & x"0A";	-- STA @10 	#limite unidade de milhar
tmp(25) := x"5" & '0' & x"0B";	-- STA @11 	#limite dezena de milhar
tmp(26) := x"5" & '0' & x"0C";	-- STA @12 	#limite centena de milhar
tmp(27) := x"5" & '0' & x"0E";	-- STA @14 	#cte 10 para verificar estouro
tmp(28) := x"5" & '1' & x"FF";	-- STA .CK0 	#limpa k0
tmp(29) := x"5" & '1' & x"FE";	-- STA .CK1 	#limpa k1
tmp(30) := x"0" & '0' & x"00";	-- NOP
tmp(31) := x"4" & '0' & x"00";	-- LDI $0 	#carrega zero
tmp(32) := x"8" & '1' & x"60";	-- CEQ .K0  	#ve se k0 esta pressionado
tmp(33) := x"7" & '0' & x"23";	-- JEQ .DEPOIS_DO_K0 	#pula se estiver solto
tmp(34) := x"9" & '0' & x"56";	-- JSR .INC 	#incrementa contagem
tmp(35) := x"9" & '0' & x"48";	-- JSR .ATUALIZA_DISPLAY 	#atualiza info da memoria no display
tmp(36) := x"4" & '0' & x"00";	-- LDI $0 	#carrega zero
tmp(37) := x"8" & '1' & x"61";	-- CEQ .K1 	#ve se k1 esta pressionado
tmp(38) := x"7" & '0' & x"28";	-- JEQ .DEPOIS_DO_K1
tmp(39) := x"9" & '0' & x"8F";	-- JSR .ATUALIZA_LIMITE 	#atualiza limite da contagem
tmp(40) := x"9" & '0' & x"2B";	-- JSR .LIMITE 	#verifica limite da contagem
tmp(41) := x"6" & '0' & x"1F";	-- JMP .MAIN 	#volta para o inicio do laco
tmp(42) := x"0" & '0' & x"00";	-- NOP
tmp(43) := x"1" & '0' & x"00";	-- LDA @0 	#carrega unidade
tmp(44) := x"8" & '0' & x"07";	-- CEQ @7 	#compara com limite unidade
tmp(45) := x"7" & '0' & x"2F";	-- JEQ .CONTINUA_UNIDADE 	#pula se for igual ou retorna
tmp(46) := x"A" & '0' & x"00";	-- RET 
tmp(47) := x"1" & '0' & x"01";	-- LDA @1 	#carrega dezena
tmp(48) := x"8" & '0' & x"08";	-- CEQ @8 	#compara com limite dezena
tmp(49) := x"7" & '0' & x"33";	-- JEQ .CONTINUA_DEZENA 	#pula se for igual ou retorna
tmp(50) := x"A" & '0' & x"00";	-- RET
tmp(51) := x"1" & '0' & x"02";	-- LDA @2 	#carrega centena
tmp(52) := x"8" & '0' & x"09";	-- CEQ @9 	#compara com limite centena
tmp(53) := x"7" & '0' & x"37";	-- JEQ .CONTINUA_CENTENA 	#pula se for igual ou retorna
tmp(54) := x"A" & '0' & x"00";	-- RET
tmp(55) := x"1" & '0' & x"03";	-- LDA @3 	#carrega unidade de milhar
tmp(56) := x"8" & '0' & x"0A";	-- CEQ @10 	#compara com limite unidade de milhar
tmp(57) := x"7" & '0' & x"3B";	-- JEQ .CONTINUA_U_MILHAR 	#pula se for igual ou retorna
tmp(58) := x"A" & '0' & x"00";	-- RET
tmp(59) := x"1" & '0' & x"04";	-- LDA @4 	#carrega dezena de milhar
tmp(60) := x"8" & '0' & x"0B";	-- CEQ @11 	#compara com limite dezena de milhar
tmp(61) := x"7" & '0' & x"3F";	-- JEQ .CONTINUA_D_MILHAR 	#pula se for igual ou retorna
tmp(62) := x"A" & '0' & x"00";	-- RET
tmp(63) := x"1" & '0' & x"05";	-- LDA @5 	#carrega centena de milhar
tmp(64) := x"8" & '0' & x"0C";	-- CEQ @12 	#compara com limite centena de milhar
tmp(65) := x"7" & '0' & x"43";	-- JEQ .CONTINUA_C_MILHAR 	#pula se for igual ou retorna
tmp(66) := x"A" & '0' & x"00";	-- RET
tmp(67) := x"4" & '0' & x"01";	-- LDI $1 	#carrega 1 para ativar flag
tmp(68) := x"5" & '0' & x"06";	-- STA @6 	#ativa flag inibe contagem
tmp(69) := x"5" & '1' & x"01";	-- STA .LED8 	#ativa led limite atingido
tmp(70) := x"A" & '0' & x"00";	-- RET 	#retorna
tmp(71) := x"0" & '0' & x"00";	-- NOP
tmp(72) := x"1" & '0' & x"00";	-- LDA @0 	#carrega unidade
tmp(73) := x"5" & '1' & x"20";	-- STA .HEX0 	#armazena em hex0
tmp(74) := x"1" & '0' & x"01";	-- LDA @1 	#carrega dezena
tmp(75) := x"5" & '1' & x"21";	-- STA .HEX1 	#armazena em hex1
tmp(76) := x"1" & '0' & x"02";	-- LDA @2 	#carrega centena
tmp(77) := x"5" & '1' & x"22";	-- STA .HEX2 	#armazena em hex2
tmp(78) := x"1" & '0' & x"03";	-- LDA @3 	#carrega unidade de milhar
tmp(79) := x"5" & '1' & x"23";	-- STA .HEX3 	#armazena em hex3
tmp(80) := x"1" & '0' & x"04";	-- LDA @4 	#carrega dezena de milhar
tmp(81) := x"5" & '1' & x"24";	-- STA .HEX4 	#armazena em hex4
tmp(82) := x"1" & '0' & x"05";	-- LDA @5 	#carrega centena de milhar
tmp(83) := x"5" & '1' & x"25";	-- STA .HEX5 	#armazena em hex5
tmp(84) := x"A" & '0' & x"00";	-- RET
tmp(85) := x"0" & '0' & x"00";	-- NOP
tmp(86) := x"5" & '1' & x"FF";	-- STA .CK0 	#limpa K0
tmp(87) := x"4" & '0' & x"00";	-- LDI $0 	#carrega zero
tmp(88) := x"8" & '0' & x"06";	-- CEQ @6 	#compara com flag inibe contagem e retorna se for diferente de zero 
tmp(89) := x"7" & '0' & x"5B";	-- JEQ .FAZ_CONTAGEM 
tmp(90) := x"A" & '0' & x"00";	-- RET
tmp(91) := x"1" & '0' & x"00";	-- LDA @0 	#carrega unidade
tmp(92) := x"2" & '0' & x"0D";	-- SOMA @13 	#soma com um
tmp(93) := x"5" & '0' & x"00";	-- STA @0 	#armazena unidade
tmp(94) := x"8" & '0' & x"0E";	-- CEQ @14 	#compara com 10 para verificar estouro
tmp(95) := x"7" & '0' & x"61";	-- JEQ .CARRY_UN
tmp(96) := x"A" & '0' & x"00";	-- RET
tmp(97) := x"4" & '0' & x"00";	-- LDI $0 	#carrega zero
tmp(98) := x"5" & '0' & x"00";	-- STA @0 	#zera unidade
tmp(99) := x"1" & '0' & x"01";	-- LDA @1 	#carrega dezena
tmp(100) := x"2" & '0' & x"0D";	-- SOMA @13 	#incrementa
tmp(101) := x"5" & '0' & x"01";	-- STA @1 	#armazena dezena
tmp(102) := x"8" & '0' & x"0E";	-- CEQ @14 	#compara com 10 para verificar estouro
tmp(103) := x"7" & '0' & x"69";	-- JEQ .CARRY_D
tmp(104) := x"A" & '0' & x"00";	-- RET
tmp(105) := x"4" & '0' & x"00";	-- LDI $0 	#carrega zero
tmp(106) := x"5" & '0' & x"01";	-- STA @1 	#zera dezena
tmp(107) := x"1" & '0' & x"02";	-- LDA @2 	#carrega centena
tmp(108) := x"2" & '0' & x"0D";	-- SOMA @13 	#incrementa
tmp(109) := x"5" & '0' & x"02";	-- STA @2 	#armazena centena
tmp(110) := x"8" & '0' & x"0E";	-- CEQ @14 	#compara com 10 para verificar estouro
tmp(111) := x"7" & '0' & x"71";	-- JEQ .CARRY_C
tmp(112) := x"A" & '0' & x"00";	-- RET
tmp(113) := x"4" & '0' & x"00";	-- LDI $0 	#carrega zero
tmp(114) := x"5" & '0' & x"02";	-- STA @2 	#zera centena
tmp(115) := x"1" & '0' & x"03";	-- LDA @3 	#carrega unidade de milhar
tmp(116) := x"2" & '0' & x"0D";	-- SOMA @13 	#incrementa
tmp(117) := x"5" & '0' & x"03";	-- STA @3 	#armazena unidade de milhar
tmp(118) := x"8" & '0' & x"0E";	-- CEQ @14 	#compara com 10 para verificar estouro
tmp(119) := x"7" & '0' & x"79";	-- JEQ .CARRY_U_MILHAR
tmp(120) := x"A" & '0' & x"00";	-- RET
tmp(121) := x"4" & '0' & x"00";	-- LDI $0 	#carrega zero
tmp(122) := x"5" & '0' & x"03";	-- STA @3 	#zera unidade de milhar
tmp(123) := x"1" & '0' & x"04";	-- LDA @4 	#carrega dezena de milhar
tmp(124) := x"2" & '0' & x"0D";	-- SOMA @13 	#incrementa
tmp(125) := x"5" & '0' & x"04";	-- STA @4 	#armazena dezena de milhar
tmp(126) := x"8" & '0' & x"0E";	-- CEQ @14 	#compara com 10 para verificar estouro
tmp(127) := x"7" & '0' & x"81";	-- JEQ .CARRY_D_MILHAR
tmp(128) := x"A" & '0' & x"00";	-- RET
tmp(129) := x"4" & '0' & x"00";	-- LDI $0 	#carrega zero
tmp(130) := x"5" & '0' & x"04";	-- STA @4 	#zera dezena de milhar
tmp(131) := x"1" & '0' & x"05";	-- LDA @5 	#carrega centena de milhar
tmp(132) := x"2" & '0' & x"0D";	-- SOMA @13 	#incrementa
tmp(133) := x"5" & '0' & x"05";	-- STA @5 	#armazena centena de milhar
tmp(134) := x"8" & '0' & x"0E";	-- CEQ @14 	#compara com 10 para verificar estouro
tmp(135) := x"7" & '0' & x"89";	-- JEQ .CARRY_C_MILHAR
tmp(136) := x"A" & '0' & x"00";	-- RET
tmp(137) := x"4" & '0' & x"00";	-- LDI $0 	#carrega zero
tmp(138) := x"5" & '0' & x"05";	-- STA @5 	#zera centena de milhar
tmp(139) := x"4" & '0' & x"01";	-- LDI $1 	#carrega um
tmp(140) := x"5" & '1' & x"02";	-- STA .LED9 	#acende led de estouro
tmp(141) := x"A" & '0' & x"00";	-- RET
tmp(142) := x"0" & '0' & x"00";	-- NOP
tmp(143) := x"4" & '0' & x"01";	-- LDI $1 	#carrega um
tmp(144) := x"5" & '1' & x"00";	-- STA .LEDS 	#ativa led0 pra indicar unidade
tmp(145) := x"4" & '0' & x"00";	-- LDI $0 	#carrega zero
tmp(146) := x"5" & '1' & x"01";	-- STA .LED8 	#limpa led limite
tmp(147) := x"5" & '0' & x"06";	-- STA @6 	#limpa flag inibe contagem
tmp(148) := x"5" & '1' & x"FE";	-- STA .CK1 	#limpa k1
tmp(149) := x"1" & '1' & x"61";	-- LDA .K1 	#carrega k1
tmp(150) := x"8" & '0' & x"0F";	-- CEQ @15 	#compara com zero para saber se esta pressionado
tmp(151) := x"7" & '0' & x"95";	-- JEQ .ESPERA_UN
tmp(152) := x"1" & '1' & x"40";	-- LDA .SWS 	#carrega chaves
tmp(153) := x"5" & '0' & x"07";	-- STA @7 	#armazena em limite unidades
tmp(154) := x"5" & '1' & x"FE";	-- STA .CK1 	#limpa k1
tmp(155) := x"4" & '0' & x"02";	-- LDI $2 	#carrega 2
tmp(156) := x"5" & '1' & x"00";	-- STA .LEDS 	#ativa led1
tmp(157) := x"1" & '1' & x"61";	-- LDA .K1 	#carrega k1
tmp(158) := x"8" & '0' & x"0F";	-- CEQ @15 	#compara com zero para saber se esta pressionado
tmp(159) := x"7" & '0' & x"9D";	-- JEQ .ESPERA_D
tmp(160) := x"1" & '1' & x"40";	-- LDA .SWS 	#carrega chaves
tmp(161) := x"5" & '0' & x"08";	-- STA @8 	#armazena em limite dezena
tmp(162) := x"5" & '1' & x"FE";	-- STA .CK1 	#limpa k1
tmp(163) := x"4" & '0' & x"04";	-- LDI $4 	#carrega 4
tmp(164) := x"5" & '1' & x"00";	-- STA .LEDS 	#ativa led2
tmp(165) := x"1" & '1' & x"61";	-- LDA .K1 	#carrega k1
tmp(166) := x"8" & '0' & x"0F";	-- CEQ @15 	#compara com zero para saber se esta pressionado
tmp(167) := x"7" & '0' & x"A5";	-- JEQ .ESPERA_C
tmp(168) := x"1" & '1' & x"40";	-- LDA .SWS 	#carrega chaves
tmp(169) := x"5" & '0' & x"09";	-- STA @9 	#armazena em limite centena
tmp(170) := x"5" & '1' & x"FE";	-- STA .CK1 	#limpa k1
tmp(171) := x"4" & '0' & x"08";	-- LDI $8 	#carrega 8
tmp(172) := x"5" & '1' & x"00";	-- STA .LEDS 	#ativa led3
tmp(173) := x"1" & '1' & x"61";	-- LDA .K1 	#carrega k1
tmp(174) := x"8" & '0' & x"0F";	-- CEQ @15 	#compara com zero para saber se esta pressionado
tmp(175) := x"7" & '0' & x"AD";	-- JEQ .ESPERA_U_MILHAR
tmp(176) := x"1" & '1' & x"40";	-- LDA .SWS 	#carrega chaves
tmp(177) := x"5" & '0' & x"0A";	-- STA @10 	#armazena em limite unidade de milhar
tmp(178) := x"5" & '1' & x"FE";	-- STA .CK1 	#limpa k1
tmp(179) := x"4" & '0' & x"10";	-- LDI $16 	#carrega 16
tmp(180) := x"5" & '1' & x"00";	-- STA .LEDS 	#ativa led4
tmp(181) := x"1" & '1' & x"61";	-- LDA .K1 	#carrega k1
tmp(182) := x"8" & '0' & x"0F";	-- CEQ @15 	#compara com zero para saber se esta pressionado
tmp(183) := x"7" & '0' & x"B5";	-- JEQ .ESPERA_D_MILHAR
tmp(184) := x"1" & '1' & x"40";	-- LDA .SWS 	#carrega chaves
tmp(185) := x"5" & '0' & x"0B";	-- STA @11 	#armazena em limite dezena de milhar
tmp(186) := x"5" & '1' & x"FE";	-- STA .CK1 	#limpa k1
tmp(187) := x"4" & '0' & x"20";	-- LDI $32 	#carrega 32
tmp(188) := x"5" & '1' & x"00";	-- STA .LEDS 	#ativa led5
tmp(189) := x"1" & '1' & x"61";	-- LDA .K1 	#carrega k1
tmp(190) := x"8" & '0' & x"0F";	-- CEQ @15 	#compara com zero para saber se esta pressionado
tmp(191) := x"7" & '0' & x"BD";	-- JEQ .ESPERA_C_MILHAR
tmp(192) := x"1" & '1' & x"40";	-- LDA .SWS 	#carrega chaves
tmp(193) := x"5" & '0' & x"0C";	-- STA @12 	#armazena em limite centena de milhar
tmp(194) := x"5" & '1' & x"FE";	-- STA .CK1 	#limpa k1
tmp(195) := x"4" & '0' & x"00";	-- LDI $0 	#carrega 0
tmp(196) := x"5" & '1' & x"00";	-- STA .LEDS 	#desativa leds
tmp(197) := x"A" & '0' & x"00";	-- RET


        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;