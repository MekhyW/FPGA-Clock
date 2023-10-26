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
  constant SOMAI : std_logic_vector(4 downto 0) := "01100";

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
tmp(19) := STA & "01" & "01" & x"03";	-- STA R1, .TIME_DIV 	#base de tempo por padrao 1 seg
tmp(20) := LDI & "10" & "00" & x"0A";	-- LDI R2, $10
tmp(21) := STA & "10" & "00" & x"0E";	-- STA R2, @14 	#cte 10 para verificar estouro
tmp(22) := STA & "10" & "01" & x"FF";	-- STA R2, .CK0 	#limpa k0
tmp(23) := STA & "10" & "01" & x"FE";	-- STA R2, .CK1 	#limpa k1
tmp(24) := STA & "10" & "01" & x"FD";	-- STA R2, .CTIME 	#limpa tempo
tmp(25) := LDI & "11" & "00" & x"06";	-- LDI R3, $6
tmp(26) := STA & "11" & "00" & x"10";	-- STA R3, @16 	#cte 6 para verificar 60
tmp(27) := LDI & "11" & "00" & x"02";	-- LDI R3, $2
tmp(28) := STA & "11" & "00" & x"11";	-- STA R3, @17 	#cte 2 para verificar 24
tmp(29) := LDI & "11" & "00" & x"04";	-- LDI R3, $4
tmp(30) := STA & "11" & "00" & x"12";	-- STA R3, @18 	#cte 6 para verificar 24
tmp(31) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(32) := CEQ & "00" & "01" & x"65";	-- CEQ R0, .TIME  	#ve se passou segundo
tmp(33) := JEQ & "00" & "00" & x"24";	-- JEQ .DEPOIS_DO_TIME 	#pula se estiver solto
tmp(34) := JSR & "00" & "00" & x"3B";	-- JSR .INC 	#incrementa contagem
tmp(35) := JSR & "00" & "00" & x"AD";	-- JSR .CHECA_60 	#checa por carry de horario 
tmp(36) := JSR & "00" & "00" & x"2E";	-- JSR .ATUALIZA_DISPLAY 	#atualiza info da memoria no display
tmp(37) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(38) := CEQ & "01" & "01" & x"60";	-- CEQ R1, .K0 	#ve se k0 esta pressionado
tmp(39) := JEQ & "00" & "00" & x"29";	-- JEQ .DEPOIS_DO_K0
tmp(40) := JSR & "00" & "00" & x"76";	-- JSR .CONFIGURA_TEMPO 	#configura horario atual
tmp(41) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(42) := CEQ & "10" & "01" & x"61";	-- CEQ R2, .K1 	#ve se k0 esta pressionado
tmp(43) := JEQ & "00" & "00" & x"2D";	-- JEQ .DEPOIS_DO_K1
tmp(44) := JSR & "00" & "00" & x"D1";	-- JSR .MUDA_BASE 	#muda base de tempo
tmp(45) := JMP & "00" & "00" & x"1F";	-- JMP .MAIN 	#volta para o inicio do laco
tmp(46) := LDA & "00" & "00" & x"00";	-- LDA R0, @0 	#carrega unidade de segundo
tmp(47) := STA & "00" & "01" & x"20";	-- STA R0, .HEX0 	#armazena em hex0
tmp(48) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena de segundo
tmp(49) := STA & "01" & "01" & x"21";	-- STA R1, .HEX1 	#armazena em hex1
tmp(50) := LDA & "10" & "00" & x"02";	-- LDA R2, @2 	#carrega unidade de minuto
tmp(51) := STA & "10" & "01" & x"22";	-- STA R2, .HEX2 	#armazena em hex2
tmp(52) := LDA & "11" & "00" & x"03";	-- LDA R3, @3 	#carrega dezena de minuto
tmp(53) := STA & "11" & "01" & x"23";	-- STA R3, .HEX3 	#armazena em hex3
tmp(54) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega unidade de hora
tmp(55) := STA & "00" & "01" & x"24";	-- STA R0, .HEX4 	#armazena em hex4
tmp(56) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega dezena de hora
tmp(57) := STA & "01" & "01" & x"25";	-- STA R1, .HEX5 	#armazena em hex5
tmp(58) := RET & "00" & "00" & x"00";	-- RET
tmp(59) := STA & "00" & "01" & x"FD";	-- STA R0, .CTIME 	#limpa tempo
tmp(60) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(61) := CEQ & "00" & "00" & x"06";	-- CEQ R0, @6 	#compara com flag inibe contagem e retorna se for diferente de zero 
tmp(62) := JEQ & "00" & "00" & x"40";	-- JEQ .FAZ_CONTAGEM 
tmp(63) := RET & "00" & "00" & x"00";	-- RET
tmp(64) := LDA & "01" & "00" & x"00";	-- LDA R1, @0 	#carrega unidade
tmp(65) := SOMAI & "01" & "00" & x"01";	-- SOMAI R1, $1 	#soma com um
tmp(66) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#armazena unidade
tmp(67) := JSR & "00" & "00" & x"45";	-- JSR .VERIFICA_ESTOURO 	#verifica estouro
tmp(68) := RET & "00" & "00" & x"00";	-- RET
tmp(69) := LDA & "01" & "00" & x"00";	-- LDA R1, @0 	#carrega unidade
tmp(70) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(71) := JEQ & "00" & "00" & x"49";	-- JEQ .CARRY_UN_S
tmp(72) := RET & "00" & "00" & x"00";	-- RET
tmp(73) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(74) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#zera unidade seg
tmp(75) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena seg
tmp(76) := SOMAI & "01" & "00" & x"01";	-- SOMAI R1, $1 	#incrementa
tmp(77) := STA & "01" & "00" & x"01";	-- STA R1, @1 	#armazena dezena seg
tmp(78) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(79) := JEQ & "00" & "00" & x"51";	-- JEQ .CARRY_D_S
tmp(80) := RET & "00" & "00" & x"00";	-- RET
tmp(81) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(82) := STA & "10" & "00" & x"01";	-- STA R2, @1 	#zera dezena seg
tmp(83) := LDA & "10" & "00" & x"02";	-- LDA R2, @2 	#carrega unidade min
tmp(84) := SOMAI & "10" & "00" & x"01";	-- SOMAI R2, $1 	#incrementa
tmp(85) := STA & "10" & "00" & x"02";	-- STA R2, @2 	#armazena unidade min
tmp(86) := CEQ & "10" & "00" & x"0E";	-- CEQ R2, @14 	#compara com 10 para verificar estouro
tmp(87) := JEQ & "00" & "00" & x"59";	-- JEQ .CARRY_UN_M
tmp(88) := RET & "00" & "00" & x"00";	-- RET
tmp(89) := LDI & "11" & "00" & x"00";	-- LDI R3, $0 	#carrega zero
tmp(90) := STA & "11" & "00" & x"02";	-- STA R3, @2 	#zera unidade min
tmp(91) := LDA & "11" & "00" & x"03";	-- LDA R3, @3 	#carrega dezena min
tmp(92) := SOMAI & "11" & "00" & x"01";	-- SOMAI R3, $1 	#incrementa
tmp(93) := STA & "11" & "00" & x"03";	-- STA R3, @3 	#armazena dezena min
tmp(94) := CEQ & "11" & "00" & x"0E";	-- CEQ R3, @14 	#compara com 10 para verificar estouro
tmp(95) := JEQ & "00" & "00" & x"61";	-- JEQ .CARRY_D_M
tmp(96) := RET & "00" & "00" & x"00";	-- RET
tmp(97) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(98) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#zera dezena min
tmp(99) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega unidade hora
tmp(100) := SOMAI & "00" & "00" & x"01";	-- SOMAI R0, $1 	#incrementa
tmp(101) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#armazena unidade hora
tmp(102) := CEQ & "00" & "00" & x"0E";	-- CEQ R0, @14 	#compara com 10 para verificar estouro
tmp(103) := JEQ & "00" & "00" & x"69";	-- JEQ .CARRY_UN_H
tmp(104) := RET & "00" & "00" & x"00";	-- RET
tmp(105) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(106) := STA & "01" & "00" & x"04";	-- STA R1, @4 	#zera unidade hora
tmp(107) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega dezena hora
tmp(108) := SOMAI & "01" & "00" & x"01";	-- SOMAI R1, $1 	#incrementa
tmp(109) := STA & "01" & "00" & x"05";	-- STA R1, @5 	#armazena dezena hora
tmp(110) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(111) := JEQ & "00" & "00" & x"71";	-- JEQ .CARRY_D_H
tmp(112) := RET & "00" & "00" & x"00";	-- RET
tmp(113) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(114) := STA & "10" & "00" & x"05";	-- STA R2, @5 	#zera dezena hora
tmp(115) := LDI & "10" & "00" & x"01";	-- LDI R2, $1 	#carrega um
tmp(116) := STA & "10" & "01" & x"02";	-- STA R2, .LED9 	#acende led de erro
tmp(117) := RET & "00" & "00" & x"00";	-- RET
tmp(118) := STA & "00" & "01" & x"FF";	-- STA R0, .CK0 	#limpa K0
tmp(119) := STA & "00" & "01" & x"FD";	-- STA R0, .CTIME 	#limpa tempo
tmp(120) := LDI & "00" & "00" & x"01";	-- LDI R0, $1 	#carrega um
tmp(121) := STA & "00" & "01" & x"00";	-- STA R0, .LEDS 	#ativa led0 pra indicar unidade segundo
tmp(122) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(123) := STA & "00" & "01" & x"FF";	-- STA R0, .CK0 	#limpa k0
tmp(124) := LDA & "01" & "01" & x"60";	-- LDA R1, .K0 	#carrega k0
tmp(125) := CEQ & "01" & "00" & x"0F";	-- CEQ R1, @15 	#compara com zero para saber se esta pressionado
tmp(126) := JEQ & "00" & "00" & x"7C";	-- JEQ .ESPERA_UN_S
tmp(127) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(128) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#armazena em unidade segundo
tmp(129) := STA & "01" & "01" & x"FF";	-- STA R1, .CK0 	#limpa k0
tmp(130) := LDI & "01" & "00" & x"02";	-- LDI R1, $2 	#carrega 2
tmp(131) := STA & "01" & "01" & x"00";	-- STA R1, .LEDS 	#ativa led1
tmp(132) := LDA & "10" & "01" & x"60";	-- LDA R2, .K0 	#carrega k0
tmp(133) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(134) := JEQ & "00" & "00" & x"84";	-- JEQ .ESPERA_D_S
tmp(135) := LDA & "10" & "01" & x"40";	-- LDA R2, .SWS 	#carrega chaves
tmp(136) := STA & "10" & "00" & x"01";	-- STA R2, @1 	#armazena em dezena segundo
tmp(137) := STA & "10" & "01" & x"FF";	-- STA R2, .CK0 	#limpa k0
tmp(138) := LDI & "10" & "00" & x"04";	-- LDI R2, $4 	#carrega 4
tmp(139) := STA & "10" & "01" & x"00";	-- STA R2, .LEDS 	#ativa led2
tmp(140) := LDA & "11" & "01" & x"60";	-- LDA R3, .K0 	#carrega k0
tmp(141) := CEQ & "11" & "00" & x"0F";	-- CEQ R3, @15 	#compara com zero para saber se esta pressionado
tmp(142) := JEQ & "00" & "00" & x"8C";	-- JEQ .ESPERA_UN_M
tmp(143) := LDA & "11" & "01" & x"40";	-- LDA R3, .SWS 	#carrega chaves
tmp(144) := STA & "11" & "00" & x"02";	-- STA R3, @2 	#armazena em unidade minuto
tmp(145) := STA & "11" & "01" & x"FF";	-- STA R3, .CK0 	#limpa k0
tmp(146) := LDI & "11" & "00" & x"08";	-- LDI R3, $8 	#carrega 8
tmp(147) := STA & "11" & "01" & x"00";	-- STA R3, .LEDS 	#ativa led3
tmp(148) := LDA & "00" & "01" & x"60";	-- LDA R0, .K0 	#carrega k0
tmp(149) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com zero para saber se esta pressionado
tmp(150) := JEQ & "00" & "00" & x"94";	-- JEQ .ESPERA_D_M
tmp(151) := LDA & "00" & "01" & x"40";	-- LDA R0, .SWS 	#carrega chaves
tmp(152) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#armazena em dezena minuto
tmp(153) := STA & "00" & "01" & x"FF";	-- STA R0, .CK0 	#limpa k0
tmp(154) := LDI & "00" & "00" & x"10";	-- LDI R0, $16 	#carrega 16
tmp(155) := STA & "00" & "01" & x"00";	-- STA R0, .LEDS 	#ativa led4
tmp(156) := LDA & "01" & "01" & x"60";	-- LDA R1, .K0 	#carrega k0
tmp(157) := CEQ & "01" & "00" & x"0F";	-- CEQ R1, @15 	#compara com zero para saber se esta pressionado
tmp(158) := JEQ & "00" & "00" & x"9C";	-- JEQ .ESPERA_UN_H
tmp(159) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(160) := STA & "01" & "00" & x"04";	-- STA R1, @4 	#armazena em unidade hora
tmp(161) := STA & "01" & "01" & x"FF";	-- STA R1, .CK0 	#limpa k0
tmp(162) := LDI & "01" & "00" & x"20";	-- LDI R1, $32 	#carrega 32
tmp(163) := STA & "01" & "01" & x"00";	-- STA R1, .LEDS 	#ativa led5
tmp(164) := LDA & "10" & "01" & x"60";	-- LDA R2, .K0 	#carrega k0
tmp(165) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(166) := JEQ & "00" & "00" & x"A4";	-- JEQ .ESPERA_D_H
tmp(167) := LDA & "10" & "01" & x"40";	-- LDA R2, .SWS 	#carrega chaves
tmp(168) := STA & "10" & "00" & x"05";	-- STA R2, @5 	#armazena em dezena hora
tmp(169) := STA & "10" & "01" & x"FF";	-- STA R2, .CK0 	#limpa k0
tmp(170) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega 0
tmp(171) := STA & "10" & "01" & x"00";	-- STA R2, .LEDS 	#desativa leds
tmp(172) := RET & "00" & "00" & x"00";	-- RET
tmp(173) := LDA & "00" & "00" & x"00";	-- LDA R0, @0 	#carrega unidade de segundo
tmp(174) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com 0
tmp(175) := JEQ & "00" & "00" & x"B1";	-- JEQ .DEPOIS_0_SEG 	#desvia se unidade for 0 seg ou retorna
tmp(176) := RET & "00" & "00" & x"00";	-- RET 
tmp(177) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena de segundo
tmp(178) := CEQ & "01" & "00" & x"10";	-- CEQ R1, @16 	#compara com 6
tmp(179) := JEQ & "00" & "00" & x"B5";	-- JEQ .MINUTO 	#desvia se dezena for 6 ou retorna
tmp(180) := RET & "00" & "00" & x"00";	-- RET
tmp(181) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(182) := STA & "00" & "00" & x"00";	-- STA R0, @0 	#zera unidade segundo
tmp(183) := STA & "00" & "00" & x"01";	-- STA R0, @1 	#zera dezena segundo
tmp(184) := JSR & "00" & "00" & x"53";	-- JSR .VERIFICA_ESTOURO_MINUTO 	#soma 1 no minuto e confere estouro
tmp(185) := LDA & "00" & "00" & x"02";	-- LDA R0, @2 	#carrega unidade minuto
tmp(186) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com 0
tmp(187) := JEQ & "00" & "00" & x"BD";	-- JEQ .DEPOIS_0_MIN 	#desvia se unidade for 0 min ou retorna
tmp(188) := RET & "00" & "00" & x"00";	-- RET 
tmp(189) := LDA & "01" & "00" & x"03";	-- LDA R1, @3 	#carrega dezena de minuto
tmp(190) := CEQ & "01" & "00" & x"10";	-- CEQ R1, @16 	#compara com 6
tmp(191) := JEQ & "00" & "00" & x"C1";	-- JEQ .HORA 	#desvia se dezena for 6 ou retorna
tmp(192) := RET & "00" & "00" & x"00";	-- RET
tmp(193) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(194) := STA & "00" & "00" & x"02";	-- STA R0, @2 	#zera unidade min
tmp(195) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#zera dezena min
tmp(196) := JSR & "00" & "00" & x"63";	-- JSR .VERIFICA_ESTOURO_HORA 	#soma 1 na hora e confere estouro
tmp(197) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega unidade de hora
tmp(198) := CEQ & "00" & "00" & x"12";	-- CEQ R0, @18 	#compara com 4
tmp(199) := JEQ & "00" & "00" & x"C9";	-- JEQ .DEPOIS_4_HOR 	#desvia se unidade for 4 horas ou retorna
tmp(200) := RET & "00" & "00" & x"00";	-- RET 
tmp(201) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega dezena de hora
tmp(202) := CEQ & "01" & "00" & x"11";	-- CEQ R1, @17 	#compara com 2
tmp(203) := JEQ & "00" & "00" & x"CD";	-- JEQ .ZERA_HORA 	#desvia se dezena for 6 ou retorna
tmp(204) := RET & "00" & "00" & x"00";	-- RET
tmp(205) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(206) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#zera unidade hora
tmp(207) := STA & "00" & "00" & x"05";	-- STA R0, @5 	#zera dezena hora
tmp(208) := RET & "00" & "00" & x"00";	-- RET
tmp(209) := STA & "01" & "01" & x"FE";	-- STA R1, .CK1 	#limpa k1
tmp(210) := LDA & "10" & "01" & x"61";	-- LDA R2, .K1 	#carrega k1
tmp(211) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(212) := JEQ & "00" & "00" & x"D2";	-- JEQ .ESPERA
tmp(213) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(214) := STA & "01" & "01" & x"03";	-- STA R1, .TIME_DIV 	#armazena o numero de vezes mais rapido que a base de tempo alternativa eh
tmp(215) := STA & "01" & "01" & x"FE";	-- STA R1, .CK1 	#limpa k1
tmp(216) := LDI & "01" & "00" & x"64";	-- LDI R1, $100 	#carrega 100
tmp(217) := RET & "00" & "00" & x"00";	-- RET











        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;