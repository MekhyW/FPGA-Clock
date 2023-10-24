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

  constant NOP  : std_logic_vector(4 downto 0) := "00000";
  constant LDA  : std_logic_vector(4 downto 0) := "00001";
  constant SOMA : std_logic_vector(4 downto 0) := "00010";
  constant SUB  : std_logic_vector(4 downto 0) := "00011";
  constant LDI : std_logic_vector(4 downto 0) := "00100";
  constant STA : std_logic_vector(4 downto 0) := "00101";
  constant JMP : std_logic_vector(4 downto 0) := "00110";
  constant JEQ : std_logic_vector(4 downto 0) := "00111";
  constant CEQ : std_logic_vector(4 downto 0) := "01000";
  constant JSR : std_logic_vector(4 downto 0) := "01001";
  constant RET : std_logic_vector(4 downto 0) := "01010";
  constant OP_AND : std_logic_vector(4 downto 0) := "01011";

  type blocoMemoria is array(0 TO 2**addrWidth - 1) of std_logic_vector(dataWidth-1 DOWNTO 0);

  function initMemory
        return blocoMemoria is variable tmp : blocoMemoria := (others => (others => '0'));
  begin
        -- Inicializa os endereços:
tmp(0) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#setup inicializa em 0
tmp(1) := STA & "00" & "01" & x"00";	-- STA R0, .LEDS
tmp(2) := STA & "00" & "01" & x"01";	-- STA R0, .LED8
tmp(3) := STA & "00" & "01" & x"02";	-- STA R0, .LED9
tmp(4) := STA & "00" & "01" & x"20";	-- STA R0, .HEX0
tmp(5) := STA & "00" & "01" & x"21";	-- STA R0, .HEX1
tmp(6) := STA & "00" & "01" & x"22";	-- STA R0, .HEX2
tmp(7) := STA & "00" & "01" & x"23";	-- STA R0, .HEX3
tmp(8) := STA & "00" & "01" & x"24";	-- STA R0, .HEX4
tmp(9) := STA & "00" & "01" & x"25";	-- STA R0, .HEX5
tmp(10) := STA & "00" & "00" & x"00";	-- STA R0, @0 	#unidade
tmp(11) := STA & "00" & "00" & x"01";	-- STA R0, @1 	#dezena
tmp(12) := STA & "00" & "00" & x"02";	-- STA R0, @2 	#centena
tmp(13) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#unidade de milhar
tmp(14) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#dezena de milhar
tmp(15) := STA & "00" & "00" & x"05";	-- STA R0, @5 	#centena de milhar
tmp(16) := STA & "00" & "00" & x"06";	-- STA R0, @6 	#flag inibe contagem
tmp(17) := STA & "00" & "00" & x"0F";	-- STA R0, @15 	#cte 0 para saber se botao esta solto
tmp(18) := LDI & "01" & "00" & x"01";	-- LDI R1, $1
tmp(19) := STA & "01" & "00" & x"0D";	-- STA R1, @13 	#cte 1 para incrementar
tmp(20) := LDI & "10" & "00" & x"0A";	-- LDI R2, $10
tmp(21) := STA & "10" & "00" & x"07";	-- STA R2, @7 	#limite unidade
tmp(22) := STA & "10" & "00" & x"08";	-- STA R2, @8 	#limite dezena
tmp(23) := STA & "10" & "00" & x"09";	-- STA R2, @9 	#limite centena
tmp(24) := STA & "10" & "00" & x"0A";	-- STA R2, @10 	#limite unidade de milhar
tmp(25) := STA & "10" & "00" & x"0B";	-- STA R2, @11 	#limite dezena de milhar
tmp(26) := STA & "10" & "00" & x"0C";	-- STA R2, @12 	#limite centena de milhar
tmp(27) := STA & "10" & "00" & x"0E";	-- STA R2, @14 	#cte 10 para verificar estouro
tmp(28) := STA & "10" & "01" & x"FF";	-- STA R2, .CK0 	#limpa k0
tmp(29) := STA & "10" & "01" & x"FE";	-- STA R2, .CK1 	#limpa k1
tmp(30) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(31) := CEQ & "00" & "01" & x"60";	-- CEQ R0, .K0  	#ve se k0 esta pressionado
tmp(32) := JEQ & "00" & "00" & x"22";	-- JEQ .DEPOIS_DO_K0 	#pula se estiver solto
tmp(33) := JSR & "00" & "00" & x"52";	-- JSR .INC 	#incrementa contagem
tmp(34) := JSR & "00" & "00" & x"45";	-- JSR .ATUALIZA_DISPLAY 	#atualiza info da memoria no display
tmp(35) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(36) := CEQ & "01" & "01" & x"61";	-- CEQ R1, .K1 	#ve se k1 esta pressionado
tmp(37) := JEQ & "00" & "00" & x"27";	-- JEQ .DEPOIS_DO_K1
tmp(38) := JSR & "00" & "00" & x"8A";	-- JSR .ATUALIZA_LIMITE 	#atualiza limite da contagem
tmp(39) := JSR & "00" & "00" & x"29";	-- JSR .LIMITE 	#verifica limite da contagem
tmp(40) := JMP & "00" & "00" & x"1E";	-- JMP .MAIN 	#volta para o inicio do laco
tmp(41) := LDA & "00" & "00" & x"00";	-- LDA R0, @0 	#carrega unidade
tmp(42) := CEQ & "00" & "00" & x"07";	-- CEQ R0, @7 	#compara com limite unidade
tmp(43) := JEQ & "00" & "00" & x"2D";	-- JEQ .CONTINUA_UNIDADE 	#pula se for igual ou retorna
tmp(44) := RET & "00" & "00" & x"00";	-- RET 
tmp(45) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena
tmp(46) := CEQ & "01" & "00" & x"08";	-- CEQ R1, @8 	#compara com limite dezena
tmp(47) := JEQ & "00" & "00" & x"31";	-- JEQ .CONTINUA_DEZENA 	#pula se for igual ou retorna
tmp(48) := RET & "00" & "00" & x"00";	-- RET
tmp(49) := LDA & "10" & "00" & x"02";	-- LDA R2, @2 	#carrega centena
tmp(50) := CEQ & "10" & "00" & x"09";	-- CEQ R2, @9 	#compara com limite centena
tmp(51) := JEQ & "00" & "00" & x"35";	-- JEQ .CONTINUA_CENTENA 	#pula se for igual ou retorna
tmp(52) := RET & "00" & "00" & x"00";	-- RET
tmp(53) := LDA & "11" & "00" & x"03";	-- LDA R3, @3 	#carrega unidade de milhar
tmp(54) := CEQ & "11" & "00" & x"0A";	-- CEQ R3, @10 	#compara com limite unidade de milhar
tmp(55) := JEQ & "00" & "00" & x"39";	-- JEQ .CONTINUA_U_MILHAR 	#pula se for igual ou retorna
tmp(56) := RET & "00" & "00" & x"00";	-- RET
tmp(57) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega dezena de milhar
tmp(58) := CEQ & "00" & "00" & x"0B";	-- CEQ R0, @11 	#compara com limite dezena de milhar
tmp(59) := JEQ & "00" & "00" & x"3D";	-- JEQ .CONTINUA_D_MILHAR 	#pula se for igual ou retorna
tmp(60) := RET & "00" & "00" & x"00";	-- RET
tmp(61) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega centena de milhar
tmp(62) := CEQ & "01" & "00" & x"0C";	-- CEQ R1, @12 	#compara com limite centena de milhar
tmp(63) := JEQ & "00" & "00" & x"41";	-- JEQ .CONTINUA_C_MILHAR 	#pula se for igual ou retorna
tmp(64) := RET & "00" & "00" & x"00";	-- RET
tmp(65) := LDI & "10" & "00" & x"01";	-- LDI R2, $1 	#carrega 1 para ativar flag
tmp(66) := STA & "10" & "00" & x"06";	-- STA R2, @6 	#ativa flag inibe contagem
tmp(67) := STA & "10" & "01" & x"01";	-- STA R2, .LED8 	#ativa led limite atingido
tmp(68) := RET & "00" & "00" & x"00";	-- RET 	#retorna
tmp(69) := LDA & "00" & "00" & x"00";	-- LDA R0, @0 	#carrega unidade
tmp(70) := STA & "00" & "01" & x"20";	-- STA R0, .HEX0 	#armazena em hex0
tmp(71) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena
tmp(72) := STA & "01" & "01" & x"21";	-- STA R1, .HEX1 	#armazena em hex1
tmp(73) := LDA & "10" & "00" & x"02";	-- LDA R2, @2 	#carrega centena
tmp(74) := STA & "10" & "01" & x"22";	-- STA R2, .HEX2 	#armazena em hex2
tmp(75) := LDA & "11" & "00" & x"03";	-- LDA R3, @3 	#carrega unidade de milhar
tmp(76) := STA & "11" & "01" & x"23";	-- STA R3, .HEX3 	#armazena em hex3
tmp(77) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega dezena de milhar
tmp(78) := STA & "00" & "01" & x"24";	-- STA R0, .HEX4 	#armazena em hex4
tmp(79) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega centena de milhar
tmp(80) := STA & "01" & "01" & x"25";	-- STA R1, .HEX5 	#armazena em hex5
tmp(81) := RET & "00" & "00" & x"00";	-- RET
tmp(82) := STA & "00" & "01" & x"FF";	-- STA R0, .CK0 	#limpa K0
tmp(83) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(84) := CEQ & "00" & "00" & x"06";	-- CEQ R0, @6 	#compara com flag inibe contagem e retorna se for diferente de zero 
tmp(85) := JEQ & "00" & "00" & x"57";	-- JEQ .FAZ_CONTAGEM 
tmp(86) := RET & "00" & "00" & x"00";	-- RET
tmp(87) := LDA & "01" & "00" & x"00";	-- LDA R1, @0 	#carrega unidade
tmp(88) := SOMA & "01" & "00" & x"0D";	-- SOMA R1, @13 	#soma com um
tmp(89) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#armazena unidade
tmp(90) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(91) := JEQ & "00" & "00" & x"5D";	-- JEQ .CARRY_UN
tmp(92) := RET & "00" & "00" & x"00";	-- RET
tmp(93) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(94) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#zera unidade
tmp(95) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena
tmp(96) := SOMA & "01" & "00" & x"0D";	-- SOMA R1, @13 	#incrementa
tmp(97) := STA & "01" & "00" & x"01";	-- STA R1, @1 	#armazena dezena
tmp(98) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(99) := JEQ & "00" & "00" & x"65";	-- JEQ .CARRY_D
tmp(100) := RET & "00" & "00" & x"00";	-- RET
tmp(101) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(102) := STA & "10" & "00" & x"01";	-- STA R2, @1 	#zera dezena
tmp(103) := LDA & "10" & "00" & x"02";	-- LDA R2, @2 	#carrega centena
tmp(104) := SOMA & "10" & "00" & x"0D";	-- SOMA R2, @13 	#incrementa
tmp(105) := STA & "10" & "00" & x"02";	-- STA R2, @2 	#armazena centena
tmp(106) := CEQ & "10" & "00" & x"0E";	-- CEQ R2, @14 	#compara com 10 para verificar estouro
tmp(107) := JEQ & "00" & "00" & x"6D";	-- JEQ .CARRY_C
tmp(108) := RET & "00" & "00" & x"00";	-- RET
tmp(109) := LDI & "11" & "00" & x"00";	-- LDI R3, $0 	#carrega zero
tmp(110) := STA & "11" & "00" & x"02";	-- STA R3, @2 	#zera centena
tmp(111) := LDA & "11" & "00" & x"03";	-- LDA R3, @3 	#carrega unidade de milhar
tmp(112) := SOMA & "11" & "00" & x"0D";	-- SOMA R3, @13 	#incrementa
tmp(113) := STA & "11" & "00" & x"03";	-- STA R3, @3 	#armazena unidade de milhar
tmp(114) := CEQ & "11" & "00" & x"0E";	-- CEQ R3, @14 	#compara com 10 para verificar estouro
tmp(115) := JEQ & "00" & "00" & x"75";	-- JEQ .CARRY_U_MILHAR
tmp(116) := RET & "00" & "00" & x"00";	-- RET
tmp(117) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(118) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#zera unidade de milhar
tmp(119) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega dezena de milhar
tmp(120) := SOMA & "00" & "00" & x"0D";	-- SOMA R0, @13 	#incrementa
tmp(121) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#armazena dezena de milhar
tmp(122) := CEQ & "00" & "00" & x"0E";	-- CEQ R0, @14 	#compara com 10 para verificar estouro
tmp(123) := JEQ & "00" & "00" & x"7D";	-- JEQ .CARRY_D_MILHAR
tmp(124) := RET & "00" & "00" & x"00";	-- RET
tmp(125) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(126) := STA & "01" & "00" & x"04";	-- STA R1, @4 	#zera dezena de milhar
tmp(127) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega centena de milhar
tmp(128) := SOMA & "01" & "00" & x"0D";	-- SOMA R1, @13 	#incrementa
tmp(129) := STA & "01" & "00" & x"05";	-- STA R1, @5 	#armazena centena de milhar
tmp(130) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(131) := JEQ & "00" & "00" & x"85";	-- JEQ .CARRY_C_MILHAR
tmp(132) := RET & "00" & "00" & x"00";	-- RET
tmp(133) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(134) := STA & "10" & "00" & x"05";	-- STA R2, @5 	#zera centena de milhar
tmp(135) := LDI & "10" & "00" & x"01";	-- LDI R2, $1 	#carrega um
tmp(136) := STA & "10" & "01" & x"02";	-- STA R2, .LED9 	#acende led de estouro
tmp(137) := RET & "00" & "00" & x"00";	-- RET
tmp(138) := LDI & "00" & "00" & x"01";	-- LDI R0, $1 	#carrega um
tmp(139) := STA & "00" & "01" & x"00";	-- STA R0, .LEDS 	#ativa led0 pra indicar unidade
tmp(140) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(141) := STA & "00" & "01" & x"01";	-- STA R0, .LED8 	#limpa led limite
tmp(142) := STA & "00" & "00" & x"06";	-- STA R0, @6 	#limpa flag inibe contagem
tmp(143) := STA & "00" & "01" & x"FE";	-- STA R0, .CK1 	#limpa k1
tmp(144) := LDA & "01" & "01" & x"61";	-- LDA R1, .K1 	#carrega k1
tmp(145) := CEQ & "01" & "00" & x"0F";	-- CEQ R1, @15 	#compara com zero para saber se esta pressionado
tmp(146) := JEQ & "00" & "00" & x"90";	-- JEQ .ESPERA_UN
tmp(147) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(148) := STA & "01" & "00" & x"07";	-- STA R1, @7 	#armazena em limite unidades
tmp(149) := STA & "01" & "01" & x"FE";	-- STA R1, .CK1 	#limpa k1
tmp(150) := LDI & "01" & "00" & x"02";	-- LDI R1, $2 	#carrega 2
tmp(151) := STA & "01" & "01" & x"00";	-- STA R1, .LEDS 	#ativa led1
tmp(152) := LDA & "10" & "01" & x"61";	-- LDA R2, .K1 	#carrega k1
tmp(153) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(154) := JEQ & "00" & "00" & x"98";	-- JEQ .ESPERA_D
tmp(155) := LDA & "10" & "01" & x"40";	-- LDA R2, .SWS 	#carrega chaves
tmp(156) := STA & "10" & "00" & x"08";	-- STA R2, @8 	#armazena em limite dezena
tmp(157) := STA & "10" & "01" & x"FE";	-- STA R2, .CK1 	#limpa k1
tmp(158) := LDI & "10" & "00" & x"04";	-- LDI R2, $4 	#carrega 4
tmp(159) := STA & "10" & "01" & x"00";	-- STA R2, .LEDS 	#ativa led2
tmp(160) := LDA & "11" & "01" & x"61";	-- LDA R3, .K1 	#carrega k1
tmp(161) := CEQ & "11" & "00" & x"0F";	-- CEQ R3, @15 	#compara com zero para saber se esta pressionado
tmp(162) := JEQ & "00" & "00" & x"A0";	-- JEQ .ESPERA_C
tmp(163) := LDA & "11" & "01" & x"40";	-- LDA R3, .SWS 	#carrega chaves
tmp(164) := STA & "11" & "00" & x"09";	-- STA R3, @9 	#armazena em limite centena
tmp(165) := STA & "11" & "01" & x"FE";	-- STA R3, .CK1 	#limpa k1
tmp(166) := LDI & "11" & "00" & x"08";	-- LDI R3, $8 	#carrega 8
tmp(167) := STA & "11" & "01" & x"00";	-- STA R3, .LEDS 	#ativa led3
tmp(168) := LDA & "00" & "01" & x"61";	-- LDA R0, .K1 	#carrega k1
tmp(169) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com zero para saber se esta pressionado
tmp(170) := JEQ & "00" & "00" & x"A8";	-- JEQ .ESPERA_U_MILHAR
tmp(171) := LDA & "00" & "01" & x"40";	-- LDA R0, .SWS 	#carrega chaves
tmp(172) := STA & "00" & "00" & x"0A";	-- STA R0, @10 	#armazena em limite unidade de milhar
tmp(173) := STA & "00" & "01" & x"FE";	-- STA R0, .CK1 	#limpa k1
tmp(174) := LDI & "00" & "00" & x"10";	-- LDI R0, $16 	#carrega 16
tmp(175) := STA & "00" & "01" & x"00";	-- STA R0, .LEDS 	#ativa led4
tmp(176) := LDA & "01" & "01" & x"61";	-- LDA R1, .K1 	#carrega k1
tmp(177) := CEQ & "01" & "00" & x"0F";	-- CEQ R1, @15 	#compara com zero para saber se esta pressionado
tmp(178) := JEQ & "00" & "00" & x"B0";	-- JEQ .ESPERA_D_MILHAR
tmp(179) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(180) := STA & "01" & "00" & x"0B";	-- STA R1, @11 	#armazena em limite dezena de milhar
tmp(181) := STA & "01" & "01" & x"FE";	-- STA R1, .CK1 	#limpa k1
tmp(182) := LDI & "01" & "00" & x"20";	-- LDI R1, $32 	#carrega 32
tmp(183) := STA & "01" & "01" & x"00";	-- STA R1, .LEDS 	#ativa led5
tmp(184) := LDA & "10" & "01" & x"61";	-- LDA R2, .K1 	#carrega k1
tmp(185) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(186) := JEQ & "00" & "00" & x"B8";	-- JEQ .ESPERA_C_MILHAR
tmp(187) := LDA & "10" & "01" & x"40";	-- LDA R2, .SWS 	#carrega chaves
tmp(188) := STA & "10" & "00" & x"0C";	-- STA R2, @12 	#armazena em limite centena de milhar
tmp(189) := STA & "10" & "01" & x"FE";	-- STA R2, .CK1 	#limpa k1
tmp(190) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega 0
tmp(191) := STA & "10" & "01" & x"00";	-- STA R2, .LEDS 	#desativa leds
tmp(192) := RET & "00" & "00" & x"00";	-- RET






        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;