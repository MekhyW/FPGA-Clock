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
tmp(20) := STA & "01" & "01" & x"04";	-- STA R1, .TIME_DEFAULT 	#base de tempo de 1 seg
tmp(21) := STA & "01" & "01" & x"03";	-- STA R1, .TIME_DIV 	#base de tempo alternativa por padrao 1 seg
tmp(22) := LDI & "10" & "00" & x"0A";	-- LDI R2, $10
tmp(23) := STA & "10" & "00" & x"07";	-- STA R2, @7 	#limite unidade
tmp(24) := STA & "10" & "00" & x"08";	-- STA R2, @8 	#limite dezena
tmp(25) := STA & "10" & "00" & x"09";	-- STA R2, @9 	#limite centena
tmp(26) := STA & "10" & "00" & x"0A";	-- STA R2, @10 	#limite unidade de milhar
tmp(27) := STA & "10" & "00" & x"0B";	-- STA R2, @11 	#limite dezena de milhar
tmp(28) := STA & "10" & "00" & x"0C";	-- STA R2, @12 	#limite centena de milhar
tmp(29) := STA & "10" & "00" & x"0E";	-- STA R2, @14 	#cte 10 para verificar estouro
tmp(30) := STA & "10" & "01" & x"FF";	-- STA R2, .CK0 	#limpa k0
tmp(31) := STA & "10" & "01" & x"FE";	-- STA R2, .CK1 	#limpa k1
tmp(32) := STA & "10" & "01" & x"FD";	-- STA R2, .CTIME 	#limpa tempo
tmp(33) := LDI & "11" & "00" & x"06";	-- LDI R3, $6
tmp(34) := STA & "11" & "00" & x"10";	-- STA R3, @16 	#cte 6 para verificar 60
tmp(35) := LDI & "11" & "00" & x"02";	-- LDI R3, $2
tmp(36) := STA & "11" & "00" & x"11";	-- STA R3, @17 	#cte 2 para verificar 24
tmp(37) := LDI & "11" & "00" & x"04";	-- LDI R3, $4
tmp(38) := STA & "11" & "00" & x"12";	-- STA R3, @18 	#cte 6 para verificar 24
tmp(39) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(40) := CEQ & "00" & "01" & x"65";	-- CEQ R0, .TIME  	#ve se passou segundo
tmp(41) := JEQ & "00" & "00" & x"2C";	-- JEQ .DEPOIS_DO_TIME 	#pula se estiver solto
tmp(42) := JSR & "00" & "00" & x"43";	-- JSR .INC 	#incrementa contagem
tmp(43) := JSR & "00" & "00" & x"B0";	-- JSR .CHECA_60 	#checa por carry de horario 
tmp(44) := JSR & "00" & "00" & x"36";	-- JSR .ATUALIZA_DISPLAY 	#atualiza info da memoria no display
tmp(45) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(46) := CEQ & "01" & "01" & x"60";	-- CEQ R1, .K0 	#ve se k0 esta pressionado
tmp(47) := JEQ & "00" & "00" & x"31";	-- JEQ .DEPOIS_DO_K0
tmp(48) := JSR & "00" & "00" & x"7B";	-- JSR .CONFIGURA_TEMPO 	#configura horario atual
tmp(49) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(50) := CEQ & "10" & "01" & x"61";	-- CEQ R2, .K1 	#ve se k0 esta pressionado
tmp(51) := JEQ & "00" & "00" & x"35";	-- JEQ .DEPOIS_DO_K1
tmp(52) := JSR & "00" & "00" & x"D6";	-- JSR .MUDA_BASE 	#muda base de tempo
tmp(53) := JMP & "00" & "00" & x"27";	-- JMP .MAIN 	#volta para o inicio do laco
tmp(54) := LDA & "00" & "00" & x"00";	-- LDA R0, @0 	#carrega unidade
tmp(55) := STA & "00" & "01" & x"20";	-- STA R0, .HEX0 	#armazena em hex0
tmp(56) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena
tmp(57) := STA & "01" & "01" & x"21";	-- STA R1, .HEX1 	#armazena em hex1
tmp(58) := LDA & "10" & "00" & x"02";	-- LDA R2, @2 	#carrega centena
tmp(59) := STA & "10" & "01" & x"22";	-- STA R2, .HEX2 	#armazena em hex2
tmp(60) := LDA & "11" & "00" & x"03";	-- LDA R3, @3 	#carrega unidade de milhar
tmp(61) := STA & "11" & "01" & x"23";	-- STA R3, .HEX3 	#armazena em hex3
tmp(62) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega dezena de milhar
tmp(63) := STA & "00" & "01" & x"24";	-- STA R0, .HEX4 	#armazena em hex4
tmp(64) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega centena de milhar
tmp(65) := STA & "01" & "01" & x"25";	-- STA R1, .HEX5 	#armazena em hex5
tmp(66) := RET & "00" & "00" & x"00";	-- RET
tmp(67) := STA & "00" & "01" & x"FD";	-- STA R0, .CTIME 	#limpa tempo
tmp(68) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(69) := CEQ & "00" & "00" & x"06";	-- CEQ R0, @6 	#compara com flag inibe contagem e retorna se for diferente de zero 
tmp(70) := JEQ & "00" & "00" & x"48";	-- JEQ .FAZ_CONTAGEM 
tmp(71) := RET & "00" & "00" & x"00";	-- RET
tmp(72) := LDA & "01" & "00" & x"00";	-- LDA R1, @0 	#carrega unidade
tmp(73) := SOMA & "01" & "00" & x"0D";	-- SOMA R1, @13 	#soma com um
tmp(74) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#armazena unidade
tmp(75) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(76) := JEQ & "00" & "00" & x"4E";	-- JEQ .CARRY_UN
tmp(77) := RET & "00" & "00" & x"00";	-- RET
tmp(78) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(79) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#zera unidade
tmp(80) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena
tmp(81) := SOMA & "01" & "00" & x"0D";	-- SOMA R1, @13 	#incrementa
tmp(82) := STA & "01" & "00" & x"01";	-- STA R1, @1 	#armazena dezena
tmp(83) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(84) := JEQ & "00" & "00" & x"56";	-- JEQ .CARRY_D
tmp(85) := RET & "00" & "00" & x"00";	-- RET
tmp(86) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(87) := STA & "10" & "00" & x"01";	-- STA R2, @1 	#zera dezena
tmp(88) := LDA & "10" & "00" & x"02";	-- LDA R2, @2 	#carrega centena
tmp(89) := SOMA & "10" & "00" & x"0D";	-- SOMA R2, @13 	#incrementa
tmp(90) := STA & "10" & "00" & x"02";	-- STA R2, @2 	#armazena centena
tmp(91) := CEQ & "10" & "00" & x"0E";	-- CEQ R2, @14 	#compara com 10 para verificar estouro
tmp(92) := JEQ & "00" & "00" & x"5E";	-- JEQ .CARRY_C
tmp(93) := RET & "00" & "00" & x"00";	-- RET
tmp(94) := LDI & "11" & "00" & x"00";	-- LDI R3, $0 	#carrega zero
tmp(95) := STA & "11" & "00" & x"02";	-- STA R3, @2 	#zera centena
tmp(96) := LDA & "11" & "00" & x"03";	-- LDA R3, @3 	#carrega unidade de milhar
tmp(97) := SOMA & "11" & "00" & x"0D";	-- SOMA R3, @13 	#incrementa
tmp(98) := STA & "11" & "00" & x"03";	-- STA R3, @3 	#armazena unidade de milhar
tmp(99) := CEQ & "11" & "00" & x"0E";	-- CEQ R3, @14 	#compara com 10 para verificar estouro
tmp(100) := JEQ & "00" & "00" & x"66";	-- JEQ .CARRY_U_MILHAR
tmp(101) := RET & "00" & "00" & x"00";	-- RET
tmp(102) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(103) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#zera unidade de milhar
tmp(104) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega dezena de milhar
tmp(105) := SOMA & "00" & "00" & x"0D";	-- SOMA R0, @13 	#incrementa
tmp(106) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#armazena dezena de milhar
tmp(107) := CEQ & "00" & "00" & x"0E";	-- CEQ R0, @14 	#compara com 10 para verificar estouro
tmp(108) := JEQ & "00" & "00" & x"6E";	-- JEQ .CARRY_D_MILHAR
tmp(109) := RET & "00" & "00" & x"00";	-- RET
tmp(110) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(111) := STA & "01" & "00" & x"04";	-- STA R1, @4 	#zera dezena de milhar
tmp(112) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega centena de milhar
tmp(113) := SOMA & "01" & "00" & x"0D";	-- SOMA R1, @13 	#incrementa
tmp(114) := STA & "01" & "00" & x"05";	-- STA R1, @5 	#armazena centena de milhar
tmp(115) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(116) := JEQ & "00" & "00" & x"76";	-- JEQ .CARRY_C_MILHAR
tmp(117) := RET & "00" & "00" & x"00";	-- RET
tmp(118) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(119) := STA & "10" & "00" & x"05";	-- STA R2, @5 	#zera centena de milhar
tmp(120) := LDI & "10" & "00" & x"01";	-- LDI R2, $1 	#carrega um
tmp(121) := STA & "10" & "01" & x"02";	-- STA R2, .LED9 	#acende led de estouro
tmp(122) := RET & "00" & "00" & x"00";	-- RET
tmp(123) := LDI & "00" & "00" & x"01";	-- LDI R0, $1 	#carrega um
tmp(124) := STA & "00" & "01" & x"00";	-- STA R0, .LEDS 	#ativa led0 pra indicar unidade segundo
tmp(125) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(126) := STA & "00" & "01" & x"FF";	-- STA R0, .CK0 	#limpa k0
tmp(127) := LDA & "01" & "01" & x"60";	-- LDA R1, .K0 	#carrega k0
tmp(128) := CEQ & "01" & "00" & x"0F";	-- CEQ R1, @15 	#compara com zero para saber se esta pressionado
tmp(129) := JEQ & "00" & "00" & x"7F";	-- JEQ .ESPERA_UN_S
tmp(130) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(131) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#armazena em unidade segundo
tmp(132) := STA & "01" & "01" & x"FF";	-- STA R1, .CK0 	#limpa k0
tmp(133) := LDI & "01" & "00" & x"02";	-- LDI R1, $2 	#carrega 2
tmp(134) := STA & "01" & "01" & x"00";	-- STA R1, .LEDS 	#ativa led1
tmp(135) := LDA & "10" & "01" & x"60";	-- LDA R2, .K0 	#carrega k0
tmp(136) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(137) := JEQ & "00" & "00" & x"87";	-- JEQ .ESPERA_D_S
tmp(138) := LDA & "10" & "01" & x"40";	-- LDA R2, .SWS 	#carrega chaves
tmp(139) := STA & "10" & "00" & x"01";	-- STA R2, @1 	#armazena em dezena segundo
tmp(140) := STA & "10" & "01" & x"FF";	-- STA R2, .CK0 	#limpa k0
tmp(141) := LDI & "10" & "00" & x"04";	-- LDI R2, $4 	#carrega 4
tmp(142) := STA & "10" & "01" & x"00";	-- STA R2, .LEDS 	#ativa led2
tmp(143) := LDA & "11" & "01" & x"60";	-- LDA R3, .K0 	#carrega k0
tmp(144) := CEQ & "11" & "00" & x"0F";	-- CEQ R3, @15 	#compara com zero para saber se esta pressionado
tmp(145) := JEQ & "00" & "00" & x"8F";	-- JEQ .ESPERA_UN_M
tmp(146) := LDA & "11" & "01" & x"40";	-- LDA R3, .SWS 	#carrega chaves
tmp(147) := STA & "11" & "00" & x"02";	-- STA R3, @2 	#armazena em unidade minuto
tmp(148) := STA & "11" & "01" & x"FF";	-- STA R3, .CK0 	#limpa k0
tmp(149) := LDI & "11" & "00" & x"08";	-- LDI R3, $8 	#carrega 8
tmp(150) := STA & "11" & "01" & x"00";	-- STA R3, .LEDS 	#ativa led3
tmp(151) := LDA & "00" & "01" & x"60";	-- LDA R0, .K0 	#carrega k0
tmp(152) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com zero para saber se esta pressionado
tmp(153) := JEQ & "00" & "00" & x"97";	-- JEQ .ESPERA_D_M
tmp(154) := LDA & "00" & "01" & x"40";	-- LDA R0, .SWS 	#carrega chaves
tmp(155) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#armazena em dezena minuto
tmp(156) := STA & "00" & "01" & x"FF";	-- STA R0, .CK0 	#limpa k0
tmp(157) := LDI & "00" & "00" & x"10";	-- LDI R0, $16 	#carrega 16
tmp(158) := STA & "00" & "01" & x"00";	-- STA R0, .LEDS 	#ativa led4
tmp(159) := LDA & "01" & "01" & x"60";	-- LDA R1, .K0 	#carrega k0
tmp(160) := CEQ & "01" & "00" & x"0F";	-- CEQ R1, @15 	#compara com zero para saber se esta pressionado
tmp(161) := JEQ & "00" & "00" & x"9F";	-- JEQ .ESPERA_UN_H
tmp(162) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(163) := STA & "01" & "00" & x"04";	-- STA R1, @4 	#armazena em unidade hora
tmp(164) := STA & "01" & "01" & x"FF";	-- STA R1, .CK0 	#limpa k0
tmp(165) := LDI & "01" & "00" & x"20";	-- LDI R1, $32 	#carrega 32
tmp(166) := STA & "01" & "01" & x"00";	-- STA R1, .LEDS 	#ativa led5
tmp(167) := LDA & "10" & "01" & x"60";	-- LDA R2, .K0 	#carrega k0
tmp(168) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(169) := JEQ & "00" & "00" & x"A7";	-- JEQ .ESPERA_D_H
tmp(170) := LDA & "10" & "01" & x"40";	-- LDA R2, .SWS 	#carrega chaves
tmp(171) := STA & "10" & "00" & x"05";	-- STA R2, @5 	#armazena em dezena hora
tmp(172) := STA & "10" & "01" & x"FF";	-- STA R2, .CK0 	#limpa k0
tmp(173) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega 0
tmp(174) := STA & "10" & "01" & x"00";	-- STA R2, .LEDS 	#desativa leds
tmp(175) := RET & "00" & "00" & x"00";	-- RET
tmp(176) := LDA & "00" & "00" & x"00";	-- LDA R0, @0 	#carrega unidade de segundo
tmp(177) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com 0
tmp(178) := JEQ & "00" & "00" & x"B4";	-- JEQ .DEPOIS_0_SEG 	#desvia se unidade for 0 seg ou retorna
tmp(179) := RET & "00" & "00" & x"00";	-- RET 
tmp(180) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena de segundo
tmp(181) := CEQ & "01" & "00" & x"10";	-- CEQ R1, @16 	#compara com 6
tmp(182) := JEQ & "00" & "00" & x"B8";	-- JEQ .MINUTO 	#desvia se dezena for 6 ou retorna
tmp(183) := RET & "00" & "00" & x"00";	-- RET
tmp(184) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(185) := STA & "00" & "00" & x"00";	-- STA R0, @0 	#zera unidade segundo
tmp(186) := STA & "00" & "00" & x"01";	-- STA R0, @1 	#zera dezena segundo
tmp(187) := LDA & "00" & "00" & x"02";	-- LDA R0, @2 	#carrega unidade de minuto
tmp(188) := SOMA & "00" & "00" & x"0D";	-- SOMA R0, @13 	#incrementa unidade de minuto
tmp(189) := STA & "00" & "00" & x"02";	-- STA R0, @2 	#salva resultado da soma
tmp(190) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com 0
tmp(191) := JEQ & "00" & "00" & x"C1";	-- JEQ .DEPOIS_0_MIN 	#desvia se unidade for 0 min ou retorna
tmp(192) := RET & "00" & "00" & x"00";	-- RET 
tmp(193) := LDA & "01" & "00" & x"03";	-- LDA R1, @3 	#carrega dezena de minuto
tmp(194) := CEQ & "01" & "00" & x"10";	-- CEQ R1, @16 	#compara com 6
tmp(195) := JEQ & "00" & "00" & x"C5";	-- JEQ .HORA 	#desvia se dezena for 6 ou retorna
tmp(196) := RET & "00" & "00" & x"00";	-- RET
tmp(197) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(198) := STA & "00" & "00" & x"02";	-- STA R0, @2 	#zera unidade min
tmp(199) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#zera dezena min
tmp(200) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega unidade de hora
tmp(201) := SOMA & "00" & "00" & x"0D";	-- SOMA R0, @13 	#incrementa unidade de hora
tmp(202) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#salva resultado da soma
tmp(203) := CEQ & "00" & "00" & x"12";	-- CEQ R0, @18 	#compara com 4
tmp(204) := JEQ & "00" & "00" & x"CE";	-- JEQ .DEPOIS_4_HOR 	#desvia se unidade for 4 horas ou retorna
tmp(205) := RET & "00" & "00" & x"00";	-- RET 
tmp(206) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega dezena de hora
tmp(207) := CEQ & "01" & "00" & x"11";	-- CEQ R1, @17 	#compara com 2
tmp(208) := JEQ & "00" & "00" & x"D2";	-- JEQ .ZERA_HORA 	#desvia se dezena for 6 ou retorna
tmp(209) := RET & "00" & "00" & x"00";	-- RET
tmp(210) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(211) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#zera unidade hora
tmp(212) := STA & "00" & "00" & x"05";	-- STA R0, @5 	#zera dezena hora
tmp(213) := RET & "00" & "00" & x"00";	-- RET
tmp(214) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(215) := STA & "00" & "01" & x"04";	-- STA R0, .TIME_DEFAULT 	#muda para base de tempo alternativa
tmp(216) := STA & "01" & "01" & x"FE";	-- STA R1, .CK1 	#limpa k1
tmp(217) := LDA & "10" & "01" & x"61";	-- LDA R2, .K1 	#carrega k1
tmp(218) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(219) := JEQ & "00" & "00" & x"D9";	-- JEQ .ESPERA
tmp(220) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(221) := STA & "01" & "01" & x"03";	-- STA R1, .TIME_DIV 	#armazena o numero de vezes mais rapido que a base de tempo alternativa eh
tmp(222) := STA & "01" & "01" & x"FE";	-- STA R1, .CK1 	#limpa k1
tmp(223) := LDI & "01" & "00" & x"64";	-- LDI R1, $100 	#carrega 100
tmp(224) := RET & "00" & "00" & x"00";	-- RET










        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;