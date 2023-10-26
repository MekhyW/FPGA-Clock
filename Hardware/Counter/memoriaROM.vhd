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
tmp(10) := STA & "00" & "00" & x"00";	-- STA R0, @0 	#unidade de segundo
tmp(11) := STA & "00" & "00" & x"01";	-- STA R0, @1 	#dezena de segundo
tmp(12) := STA & "00" & "00" & x"02";	-- STA R0, @2 	#unidade de minuto
tmp(13) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#dezena de minuto
tmp(14) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#unidade de hora
tmp(15) := STA & "00" & "00" & x"05";	-- STA R0, @5 	#dezena de hora
tmp(16) := STA & "00" & "00" & x"06";	-- STA R0, @6 	#flag inibe contagem
tmp(17) := STA & "00" & "00" & x"0F";	-- STA R0, @15 	#cte 0 para saber se botao esta solto
tmp(18) := LDI & "01" & "00" & x"01";	-- LDI R1, $1
tmp(19) := STA & "01" & "00" & x"0D";	-- STA R1, @13 	#cte 1 para incrementar
tmp(20) := STA & "01" & "01" & x"03";	-- STA R1, .TIME_DIV 	#base de tempo por padrao 1 seg
tmp(21) := LDI & "10" & "00" & x"0A";	-- LDI R2, $10
tmp(22) := STA & "10" & "00" & x"0E";	-- STA R2, @14 	#cte 10 para verificar estouro
tmp(23) := STA & "10" & "01" & x"FF";	-- STA R2, .CK0 	#limpa k0
tmp(24) := STA & "10" & "01" & x"FE";	-- STA R2, .CK1 	#limpa k1
tmp(25) := STA & "10" & "01" & x"FD";	-- STA R2, .CTIME 	#limpa tempo
tmp(26) := LDI & "11" & "00" & x"06";	-- LDI R3, $6
tmp(27) := STA & "11" & "00" & x"10";	-- STA R3, @16 	#cte 6 para verificar 60
tmp(28) := LDI & "11" & "00" & x"02";	-- LDI R3, $2
tmp(29) := STA & "11" & "00" & x"11";	-- STA R3, @17 	#cte 2 para verificar 24
tmp(30) := LDI & "11" & "00" & x"04";	-- LDI R3, $4
tmp(31) := STA & "11" & "00" & x"12";	-- STA R3, @18 	#cte 6 para verificar 24
tmp(32) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(33) := CEQ & "00" & "01" & x"65";	-- CEQ R0, .TIME  	#ve se passou segundo
tmp(34) := JEQ & "00" & "00" & x"25";	-- JEQ .DEPOIS_DO_TIME 	#pula se estiver solto
tmp(35) := JSR & "00" & "00" & x"3C";	-- JSR .INC 	#incrementa contagem
tmp(36) := JSR & "00" & "00" & x"AC";	-- JSR .CHECA_60 	#checa por carry de horario 
tmp(37) := JSR & "00" & "00" & x"2F";	-- JSR .ATUALIZA_DISPLAY 	#atualiza info da memoria no display
tmp(38) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(39) := CEQ & "01" & "01" & x"60";	-- CEQ R1, .K0 	#ve se k0 esta pressionado
tmp(40) := JEQ & "00" & "00" & x"2A";	-- JEQ .DEPOIS_DO_K0
tmp(41) := JSR & "00" & "00" & x"77";	-- JSR .CONFIGURA_TEMPO 	#configura horario atual
tmp(42) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(43) := CEQ & "10" & "01" & x"61";	-- CEQ R2, .K1 	#ve se k0 esta pressionado
tmp(44) := JEQ & "00" & "00" & x"2E";	-- JEQ .DEPOIS_DO_K1
tmp(45) := JSR & "00" & "00" & x"D0";	-- JSR .MUDA_BASE 	#muda base de tempo
tmp(46) := JMP & "00" & "00" & x"20";	-- JMP .MAIN 	#volta para o inicio do laco
tmp(47) := LDA & "00" & "00" & x"00";	-- LDA R0, @0 	#carrega unidade
tmp(48) := STA & "00" & "01" & x"20";	-- STA R0, .HEX0 	#armazena em hex0
tmp(49) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena
tmp(50) := STA & "01" & "01" & x"21";	-- STA R1, .HEX1 	#armazena em hex1
tmp(51) := LDA & "10" & "00" & x"02";	-- LDA R2, @2 	#carrega centena
tmp(52) := STA & "10" & "01" & x"22";	-- STA R2, .HEX2 	#armazena em hex2
tmp(53) := LDA & "11" & "00" & x"03";	-- LDA R3, @3 	#carrega unidade de milhar
tmp(54) := STA & "11" & "01" & x"23";	-- STA R3, .HEX3 	#armazena em hex3
tmp(55) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega dezena de milhar
tmp(56) := STA & "00" & "01" & x"24";	-- STA R0, .HEX4 	#armazena em hex4
tmp(57) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega centena de milhar
tmp(58) := STA & "01" & "01" & x"25";	-- STA R1, .HEX5 	#armazena em hex5
tmp(59) := RET & "00" & "00" & x"00";	-- RET
tmp(60) := STA & "00" & "01" & x"FD";	-- STA R0, .CTIME 	#limpa tempo
tmp(61) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(62) := CEQ & "00" & "00" & x"06";	-- CEQ R0, @6 	#compara com flag inibe contagem e retorna se for diferente de zero 
tmp(63) := JEQ & "00" & "00" & x"41";	-- JEQ .FAZ_CONTAGEM 
tmp(64) := RET & "00" & "00" & x"00";	-- RET
tmp(65) := LDA & "01" & "00" & x"00";	-- LDA R1, @0 	#carrega unidade
tmp(66) := SOMA & "01" & "00" & x"0D";	-- SOMA R1, @13 	#soma com um
tmp(67) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#armazena unidade
tmp(68) := JSR & "00" & "00" & x"46";	-- JSR .VERIFICA_ESTOURO 	#verifica estouro
tmp(69) := RET & "00" & "00" & x"00";	-- RET
tmp(70) := LDA & "01" & "00" & x"00";	-- LDA R1, @0 	#carrega unidade
tmp(71) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(72) := JEQ & "00" & "00" & x"4A";	-- JEQ .CARRY_UN_S
tmp(73) := RET & "00" & "00" & x"00";	-- RET
tmp(74) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(75) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#zera unidade seg
tmp(76) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena seg
tmp(77) := SOMA & "01" & "00" & x"0D";	-- SOMA R1, @13 	#incrementa
tmp(78) := STA & "01" & "00" & x"01";	-- STA R1, @1 	#armazena dezena seg
tmp(79) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(80) := JEQ & "00" & "00" & x"52";	-- JEQ .CARRY_D_S
tmp(81) := RET & "00" & "00" & x"00";	-- RET
tmp(82) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(83) := STA & "10" & "00" & x"01";	-- STA R2, @1 	#zera dezena seg
tmp(84) := LDA & "10" & "00" & x"02";	-- LDA R2, @2 	#carrega unidade min
tmp(85) := SOMA & "10" & "00" & x"0D";	-- SOMA R2, @13 	#incrementa
tmp(86) := STA & "10" & "00" & x"02";	-- STA R2, @2 	#armazena unidade min
tmp(87) := CEQ & "10" & "00" & x"0E";	-- CEQ R2, @14 	#compara com 10 para verificar estouro
tmp(88) := JEQ & "00" & "00" & x"5A";	-- JEQ .CARRY_UN_M
tmp(89) := RET & "00" & "00" & x"00";	-- RET
tmp(90) := LDI & "11" & "00" & x"00";	-- LDI R3, $0 	#carrega zero
tmp(91) := STA & "11" & "00" & x"02";	-- STA R3, @2 	#zera unidade min
tmp(92) := LDA & "11" & "00" & x"03";	-- LDA R3, @3 	#carrega dezena min
tmp(93) := SOMA & "11" & "00" & x"0D";	-- SOMA R3, @13 	#incrementa
tmp(94) := STA & "11" & "00" & x"03";	-- STA R3, @3 	#armazena dezena min
tmp(95) := CEQ & "11" & "00" & x"0E";	-- CEQ R3, @14 	#compara com 10 para verificar estouro
tmp(96) := JEQ & "00" & "00" & x"62";	-- JEQ .CARRY_D_M
tmp(97) := RET & "00" & "00" & x"00";	-- RET
tmp(98) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(99) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#zera dezena min
tmp(100) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega unidade hora
tmp(101) := SOMA & "00" & "00" & x"0D";	-- SOMA R0, @13 	#incrementa
tmp(102) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#armazena unidade hora
tmp(103) := CEQ & "00" & "00" & x"0E";	-- CEQ R0, @14 	#compara com 10 para verificar estouro
tmp(104) := JEQ & "00" & "00" & x"6A";	-- JEQ .CARRY_UN_H
tmp(105) := RET & "00" & "00" & x"00";	-- RET
tmp(106) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(107) := STA & "01" & "00" & x"04";	-- STA R1, @4 	#zera unidade hora
tmp(108) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega dezena hora
tmp(109) := SOMA & "01" & "00" & x"0D";	-- SOMA R1, @13 	#incrementa
tmp(110) := STA & "01" & "00" & x"05";	-- STA R1, @5 	#armazena dezena hora
tmp(111) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(112) := JEQ & "00" & "00" & x"72";	-- JEQ .CARRY_D_H
tmp(113) := RET & "00" & "00" & x"00";	-- RET
tmp(114) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(115) := STA & "10" & "00" & x"05";	-- STA R2, @5 	#zera dezena hora
tmp(116) := LDI & "10" & "00" & x"01";	-- LDI R2, $1 	#carrega um
tmp(117) := STA & "10" & "01" & x"02";	-- STA R2, .LED9 	#acende led de erro
tmp(118) := RET & "00" & "00" & x"00";	-- RET
tmp(119) := LDI & "00" & "00" & x"01";	-- LDI R0, $1 	#carrega um
tmp(120) := STA & "00" & "01" & x"00";	-- STA R0, .LEDS 	#ativa led0 pra indicar unidade segundo
tmp(121) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(122) := STA & "00" & "01" & x"FF";	-- STA R0, .CK0 	#limpa k0
tmp(123) := LDA & "01" & "01" & x"60";	-- LDA R1, .K0 	#carrega k0
tmp(124) := CEQ & "01" & "00" & x"0F";	-- CEQ R1, @15 	#compara com zero para saber se esta pressionado
tmp(125) := JEQ & "00" & "00" & x"7B";	-- JEQ .ESPERA_UN_S
tmp(126) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(127) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#armazena em unidade segundo
tmp(128) := STA & "01" & "01" & x"FF";	-- STA R1, .CK0 	#limpa k0
tmp(129) := LDI & "01" & "00" & x"02";	-- LDI R1, $2 	#carrega 2
tmp(130) := STA & "01" & "01" & x"00";	-- STA R1, .LEDS 	#ativa led1
tmp(131) := LDA & "10" & "01" & x"60";	-- LDA R2, .K0 	#carrega k0
tmp(132) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(133) := JEQ & "00" & "00" & x"83";	-- JEQ .ESPERA_D_S
tmp(134) := LDA & "10" & "01" & x"40";	-- LDA R2, .SWS 	#carrega chaves
tmp(135) := STA & "10" & "00" & x"01";	-- STA R2, @1 	#armazena em dezena segundo
tmp(136) := STA & "10" & "01" & x"FF";	-- STA R2, .CK0 	#limpa k0
tmp(137) := LDI & "10" & "00" & x"04";	-- LDI R2, $4 	#carrega 4
tmp(138) := STA & "10" & "01" & x"00";	-- STA R2, .LEDS 	#ativa led2
tmp(139) := LDA & "11" & "01" & x"60";	-- LDA R3, .K0 	#carrega k0
tmp(140) := CEQ & "11" & "00" & x"0F";	-- CEQ R3, @15 	#compara com zero para saber se esta pressionado
tmp(141) := JEQ & "00" & "00" & x"8B";	-- JEQ .ESPERA_UN_M
tmp(142) := LDA & "11" & "01" & x"40";	-- LDA R3, .SWS 	#carrega chaves
tmp(143) := STA & "11" & "00" & x"02";	-- STA R3, @2 	#armazena em unidade minuto
tmp(144) := STA & "11" & "01" & x"FF";	-- STA R3, .CK0 	#limpa k0
tmp(145) := LDI & "11" & "00" & x"08";	-- LDI R3, $8 	#carrega 8
tmp(146) := STA & "11" & "01" & x"00";	-- STA R3, .LEDS 	#ativa led3
tmp(147) := LDA & "00" & "01" & x"60";	-- LDA R0, .K0 	#carrega k0
tmp(148) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com zero para saber se esta pressionado
tmp(149) := JEQ & "00" & "00" & x"93";	-- JEQ .ESPERA_D_M
tmp(150) := LDA & "00" & "01" & x"40";	-- LDA R0, .SWS 	#carrega chaves
tmp(151) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#armazena em dezena minuto
tmp(152) := STA & "00" & "01" & x"FF";	-- STA R0, .CK0 	#limpa k0
tmp(153) := LDI & "00" & "00" & x"10";	-- LDI R0, $16 	#carrega 16
tmp(154) := STA & "00" & "01" & x"00";	-- STA R0, .LEDS 	#ativa led4
tmp(155) := LDA & "01" & "01" & x"60";	-- LDA R1, .K0 	#carrega k0
tmp(156) := CEQ & "01" & "00" & x"0F";	-- CEQ R1, @15 	#compara com zero para saber se esta pressionado
tmp(157) := JEQ & "00" & "00" & x"9B";	-- JEQ .ESPERA_UN_H
tmp(158) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(159) := STA & "01" & "00" & x"04";	-- STA R1, @4 	#armazena em unidade hora
tmp(160) := STA & "01" & "01" & x"FF";	-- STA R1, .CK0 	#limpa k0
tmp(161) := LDI & "01" & "00" & x"20";	-- LDI R1, $32 	#carrega 32
tmp(162) := STA & "01" & "01" & x"00";	-- STA R1, .LEDS 	#ativa led5
tmp(163) := LDA & "10" & "01" & x"60";	-- LDA R2, .K0 	#carrega k0
tmp(164) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(165) := JEQ & "00" & "00" & x"A3";	-- JEQ .ESPERA_D_H
tmp(166) := LDA & "10" & "01" & x"40";	-- LDA R2, .SWS 	#carrega chaves
tmp(167) := STA & "10" & "00" & x"05";	-- STA R2, @5 	#armazena em dezena hora
tmp(168) := STA & "10" & "01" & x"FF";	-- STA R2, .CK0 	#limpa k0
tmp(169) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega 0
tmp(170) := STA & "10" & "01" & x"00";	-- STA R2, .LEDS 	#desativa leds
tmp(171) := RET & "00" & "00" & x"00";	-- RET
tmp(172) := LDA & "00" & "00" & x"00";	-- LDA R0, @0 	#carrega unidade de segundo
tmp(173) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com 0
tmp(174) := JEQ & "00" & "00" & x"B0";	-- JEQ .DEPOIS_0_SEG 	#desvia se unidade for 0 seg ou retorna
tmp(175) := RET & "00" & "00" & x"00";	-- RET 
tmp(176) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena de segundo
tmp(177) := CEQ & "01" & "00" & x"10";	-- CEQ R1, @16 	#compara com 6
tmp(178) := JEQ & "00" & "00" & x"B4";	-- JEQ .MINUTO 	#desvia se dezena for 6 ou retorna
tmp(179) := RET & "00" & "00" & x"00";	-- RET
tmp(180) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(181) := STA & "00" & "00" & x"00";	-- STA R0, @0 	#zera unidade segundo
tmp(182) := STA & "00" & "00" & x"01";	-- STA R0, @1 	#zera dezena segundo
tmp(183) := JSR & "00" & "00" & x"54";	-- JSR .VERIFICA_ESTOURO_MINUTO 	#soma 1 no minuto e confere estouro
tmp(184) := LDA & "00" & "00" & x"02";	-- LDA R0, @2 	#carrega unidade minuto
tmp(185) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com 0
tmp(186) := JEQ & "00" & "00" & x"BC";	-- JEQ .DEPOIS_0_MIN 	#desvia se unidade for 0 min ou retorna
tmp(187) := RET & "00" & "00" & x"00";	-- RET 
tmp(188) := LDA & "01" & "00" & x"03";	-- LDA R1, @3 	#carrega dezena de minuto
tmp(189) := CEQ & "01" & "00" & x"10";	-- CEQ R1, @16 	#compara com 6
tmp(190) := JEQ & "00" & "00" & x"C0";	-- JEQ .HORA 	#desvia se dezena for 6 ou retorna
tmp(191) := RET & "00" & "00" & x"00";	-- RET
tmp(192) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(193) := STA & "00" & "00" & x"02";	-- STA R0, @2 	#zera unidade min
tmp(194) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#zera dezena min
tmp(195) := JSR & "00" & "00" & x"64";	-- JSR .VERIFICA_ESTOURO_HORA 	#soma 1 na hora e confere estouro
tmp(196) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega unidade de hora
tmp(197) := CEQ & "00" & "00" & x"12";	-- CEQ R0, @18 	#compara com 4
tmp(198) := JEQ & "00" & "00" & x"C8";	-- JEQ .DEPOIS_4_HOR 	#desvia se unidade for 4 horas ou retorna
tmp(199) := RET & "00" & "00" & x"00";	-- RET 
tmp(200) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega dezena de hora
tmp(201) := CEQ & "01" & "00" & x"11";	-- CEQ R1, @17 	#compara com 2
tmp(202) := JEQ & "00" & "00" & x"CC";	-- JEQ .ZERA_HORA 	#desvia se dezena for 6 ou retorna
tmp(203) := RET & "00" & "00" & x"00";	-- RET
tmp(204) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(205) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#zera unidade hora
tmp(206) := STA & "00" & "00" & x"05";	-- STA R0, @5 	#zera dezena hora
tmp(207) := RET & "00" & "00" & x"00";	-- RET
tmp(208) := STA & "01" & "01" & x"FE";	-- STA R1, .CK1 	#limpa k1
tmp(209) := LDA & "10" & "01" & x"61";	-- LDA R2, .K1 	#carrega k1
tmp(210) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(211) := JEQ & "00" & "00" & x"D1";	-- JEQ .ESPERA
tmp(212) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(213) := STA & "01" & "01" & x"03";	-- STA R1, .TIME_DIV 	#armazena o numero de vezes mais rapido que a base de tempo alternativa eh
tmp(214) := STA & "01" & "01" & x"FE";	-- STA R1, .CK1 	#limpa k1
tmp(215) := LDI & "01" & "00" & x"64";	-- LDI R1, $100 	#carrega 100
tmp(216) := RET & "00" & "00" & x"00";	-- RET















        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;