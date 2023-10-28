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
  constant CLT : std_logic_vector(4 downto 0) := "01101";
  constant JLT : std_logic_vector(4 downto 0) := "01110";

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
tmp(31) := LDI & "11" & "00" & x"03";	-- LDI R3, $3
tmp(32) := STA & "11" & "00" & x"13";	-- STA R3, @19 	#cte 3 para verificar menor ou igual a 2
tmp(33) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(34) := CEQ & "00" & "01" & x"65";	-- CEQ R0, .TIME  	#ve se passou segundo
tmp(35) := JEQ & "00" & "00" & x"26";	-- JEQ .DEPOIS_DO_TIME 	#pula se estiver solto
tmp(36) := JSR & "00" & "00" & x"3D";	-- JSR .INC 	#incrementa contagem
tmp(37) := JSR & "00" & "00" & x"CD";	-- JSR .CHECA_60 	#checa por carry de horario 
tmp(38) := JSR & "00" & "00" & x"30";	-- JSR .ATUALIZA_DISPLAY 	#atualiza info da memoria no display
tmp(39) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(40) := CEQ & "01" & "01" & x"60";	-- CEQ R1, .K0 	#ve se k0 esta pressionado
tmp(41) := JEQ & "00" & "00" & x"2B";	-- JEQ .DEPOIS_DO_K0
tmp(42) := JSR & "00" & "00" & x"78";	-- JSR .CONFIGURA_TEMPO 	#configura horario atual
tmp(43) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(44) := CEQ & "10" & "01" & x"61";	-- CEQ R2, .K1 	#ve se k0 esta pressionado
tmp(45) := JEQ & "00" & "00" & x"2F";	-- JEQ .DEPOIS_DO_K1
tmp(46) := JSR & "00" & "00" & x"F1";	-- JSR .MUDA_BASE 	#muda base de tempo
tmp(47) := JMP & "00" & "00" & x"21";	-- JMP .MAIN 	#volta para o inicio do laco
tmp(48) := LDA & "00" & "00" & x"00";	-- LDA R0, @0 	#carrega unidade de segundo
tmp(49) := STA & "00" & "01" & x"20";	-- STA R0, .HEX0 	#armazena em hex0
tmp(50) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena de segundo
tmp(51) := STA & "01" & "01" & x"21";	-- STA R1, .HEX1 	#armazena em hex1
tmp(52) := LDA & "10" & "00" & x"02";	-- LDA R2, @2 	#carrega unidade de minuto
tmp(53) := STA & "10" & "01" & x"22";	-- STA R2, .HEX2 	#armazena em hex2
tmp(54) := LDA & "11" & "00" & x"03";	-- LDA R3, @3 	#carrega dezena de minuto
tmp(55) := STA & "11" & "01" & x"23";	-- STA R3, .HEX3 	#armazena em hex3
tmp(56) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega unidade de hora
tmp(57) := STA & "00" & "01" & x"24";	-- STA R0, .HEX4 	#armazena em hex4
tmp(58) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega dezena de hora
tmp(59) := STA & "01" & "01" & x"25";	-- STA R1, .HEX5 	#armazena em hex5
tmp(60) := RET & "00" & "00" & x"00";	-- RET
tmp(61) := STA & "00" & "01" & x"FD";	-- STA R0, .CTIME 	#limpa tempo
tmp(62) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(63) := CEQ & "00" & "00" & x"06";	-- CEQ R0, @6 	#compara com flag inibe contagem e retorna se for diferente de zero 
tmp(64) := JEQ & "00" & "00" & x"42";	-- JEQ .FAZ_CONTAGEM 
tmp(65) := RET & "00" & "00" & x"00";	-- RET
tmp(66) := LDA & "01" & "00" & x"00";	-- LDA R1, @0 	#carrega unidade
tmp(67) := SOMAI & "01" & "00" & x"01";	-- SOMAI R1, $1 	#soma com um
tmp(68) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#armazena unidade
tmp(69) := JSR & "00" & "00" & x"47";	-- JSR .VERIFICA_ESTOURO 	#verifica estouro
tmp(70) := RET & "00" & "00" & x"00";	-- RET
tmp(71) := LDA & "01" & "00" & x"00";	-- LDA R1, @0 	#carrega unidade
tmp(72) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(73) := JEQ & "00" & "00" & x"4B";	-- JEQ .CARRY_UN_S
tmp(74) := RET & "00" & "00" & x"00";	-- RET
tmp(75) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(76) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#zera unidade seg
tmp(77) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena seg
tmp(78) := SOMAI & "01" & "00" & x"01";	-- SOMAI R1, $1 	#incrementa
tmp(79) := STA & "01" & "00" & x"01";	-- STA R1, @1 	#armazena dezena seg
tmp(80) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(81) := JEQ & "00" & "00" & x"53";	-- JEQ .CARRY_D_S
tmp(82) := RET & "00" & "00" & x"00";	-- RET
tmp(83) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(84) := STA & "10" & "00" & x"01";	-- STA R2, @1 	#zera dezena seg
tmp(85) := LDA & "10" & "00" & x"02";	-- LDA R2, @2 	#carrega unidade min
tmp(86) := SOMAI & "10" & "00" & x"01";	-- SOMAI R2, $1 	#incrementa
tmp(87) := STA & "10" & "00" & x"02";	-- STA R2, @2 	#armazena unidade min
tmp(88) := CEQ & "10" & "00" & x"0E";	-- CEQ R2, @14 	#compara com 10 para verificar estouro
tmp(89) := JEQ & "00" & "00" & x"5B";	-- JEQ .CARRY_UN_M
tmp(90) := RET & "00" & "00" & x"00";	-- RET
tmp(91) := LDI & "11" & "00" & x"00";	-- LDI R3, $0 	#carrega zero
tmp(92) := STA & "11" & "00" & x"02";	-- STA R3, @2 	#zera unidade min
tmp(93) := LDA & "11" & "00" & x"03";	-- LDA R3, @3 	#carrega dezena min
tmp(94) := SOMAI & "11" & "00" & x"01";	-- SOMAI R3, $1 	#incrementa
tmp(95) := STA & "11" & "00" & x"03";	-- STA R3, @3 	#armazena dezena min
tmp(96) := CEQ & "11" & "00" & x"0E";	-- CEQ R3, @14 	#compara com 10 para verificar estouro
tmp(97) := JEQ & "00" & "00" & x"63";	-- JEQ .CARRY_D_M
tmp(98) := RET & "00" & "00" & x"00";	-- RET
tmp(99) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(100) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#zera dezena min
tmp(101) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega unidade hora
tmp(102) := SOMAI & "00" & "00" & x"01";	-- SOMAI R0, $1 	#incrementa
tmp(103) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#armazena unidade hora
tmp(104) := CEQ & "00" & "00" & x"0E";	-- CEQ R0, @14 	#compara com 10 para verificar estouro
tmp(105) := JEQ & "00" & "00" & x"6B";	-- JEQ .CARRY_UN_H
tmp(106) := RET & "00" & "00" & x"00";	-- RET
tmp(107) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(108) := STA & "01" & "00" & x"04";	-- STA R1, @4 	#zera unidade hora
tmp(109) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega dezena hora
tmp(110) := SOMAI & "01" & "00" & x"01";	-- SOMAI R1, $1 	#incrementa
tmp(111) := STA & "01" & "00" & x"05";	-- STA R1, @5 	#armazena dezena hora
tmp(112) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(113) := JEQ & "00" & "00" & x"73";	-- JEQ .CARRY_D_H
tmp(114) := RET & "00" & "00" & x"00";	-- RET
tmp(115) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(116) := STA & "10" & "00" & x"05";	-- STA R2, @5 	#zera dezena hora
tmp(117) := LDI & "10" & "00" & x"01";	-- LDI R2, $1 	#carrega um
tmp(118) := STA & "10" & "01" & x"02";	-- STA R2, .LED9 	#acende led de erro
tmp(119) := RET & "00" & "00" & x"00";	-- RET
tmp(120) := STA & "00" & "01" & x"FF";	-- STA R0, .CK0 	#limpa K0
tmp(121) := LDI & "00" & "00" & x"01";	-- LDI R0, $1 	#carrega um
tmp(122) := STA & "00" & "01" & x"00";	-- STA R0, .LEDS 	#ativa led0 pra indicar unidade segundo
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
tmp(171) := JSR & "00" & "00" & x"AE";	-- JSR .VERIFICA_CONSISTENCIA
tmp(172) := STA & "00" & "01" & x"FD";	-- STA R0, .CTIME 	#limpa tempo
tmp(173) := RET & "00" & "00" & x"00";	-- RET
tmp(174) := LDA & "00" & "00" & x"00";	-- LDA R0, @0 	#carrega unidade de segundo
tmp(175) := CLT & "00" & "00" & x"0E";	-- CLT R0, @14 	#verifica se menor 10
tmp(176) := JLT & "00" & "00" & x"B3";	-- JLT .PASSA_UN_S
tmp(177) := LDI & "00" & "00" & x"09";	-- LDI R0, $9 	#carrega 9
tmp(178) := STA & "00" & "00" & x"00";	-- STA R0, @0 	#limita para 9
tmp(179) := LDA & "00" & "00" & x"01";	-- LDA R0, @1 	#carrega dezena de segundo
tmp(180) := CLT & "00" & "00" & x"10";	-- CLT R0, @16 	#verifica se menor 6
tmp(181) := JLT & "00" & "00" & x"B8";	-- JLT .PASSA_D_S
tmp(182) := LDI & "00" & "00" & x"05";	-- LDI R0, $5 	#carrega 5
tmp(183) := STA & "00" & "00" & x"01";	-- STA R0, @1 	#limita para 5
tmp(184) := LDA & "00" & "00" & x"02";	-- LDA R0, @2 	#carrega unidade de minuto
tmp(185) := CLT & "00" & "00" & x"0E";	-- CLT R0, @14 	#verifica se menor 10
tmp(186) := JLT & "00" & "00" & x"BD";	-- JLT .PASSA_UN_M
tmp(187) := LDI & "00" & "00" & x"09";	-- LDI R0, $9 	#carrega 9
tmp(188) := STA & "00" & "00" & x"02";	-- STA R0, @2 	#limita para 9
tmp(189) := LDA & "00" & "00" & x"03";	-- LDA R0, @3 	#carrega dezena de minuto
tmp(190) := CLT & "00" & "00" & x"10";	-- CLT R0, @16 	#verifica se menor 6
tmp(191) := JLT & "00" & "00" & x"C2";	-- JLT .PASSA_D_M
tmp(192) := LDI & "00" & "00" & x"05";	-- LDI R0, $5 	#carrega 5
tmp(193) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#limita para 5
tmp(194) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega unidade de hora
tmp(195) := CLT & "00" & "00" & x"12";	-- CLT R0, @18 	#verifica se menor 4
tmp(196) := JLT & "00" & "00" & x"C7";	-- JLT .PASSA_UN_H
tmp(197) := LDI & "00" & "00" & x"03";	-- LDI R0, $3 	#carrega 3
tmp(198) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#limita para 3
tmp(199) := LDA & "00" & "00" & x"05";	-- LDA R0, @5 	#carrega dezena de hora
tmp(200) := CLT & "00" & "00" & x"13";	-- CLT R0, @19 	#verifica se menor 3
tmp(201) := JLT & "00" & "00" & x"CC";	-- JLT .PASSA_D_H
tmp(202) := LDI & "00" & "00" & x"02";	-- LDI R0, $2 	#carrega 2
tmp(203) := STA & "00" & "00" & x"05";	-- STA R0, @5 	#limita para 2
tmp(204) := RET & "00" & "00" & x"00";	-- RET
tmp(205) := LDA & "00" & "00" & x"00";	-- LDA R0, @0 	#carrega unidade de segundo
tmp(206) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com 0
tmp(207) := JEQ & "00" & "00" & x"D1";	-- JEQ .DEPOIS_0_SEG 	#desvia se unidade for 0 seg ou retorna
tmp(208) := RET & "00" & "00" & x"00";	-- RET 
tmp(209) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena de segundo
tmp(210) := CEQ & "01" & "00" & x"10";	-- CEQ R1, @16 	#compara com 6
tmp(211) := JEQ & "00" & "00" & x"D5";	-- JEQ .MINUTO 	#desvia se dezena for 6 ou retorna
tmp(212) := RET & "00" & "00" & x"00";	-- RET
tmp(213) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(214) := STA & "00" & "00" & x"00";	-- STA R0, @0 	#zera unidade segundo
tmp(215) := STA & "00" & "00" & x"01";	-- STA R0, @1 	#zera dezena segundo
tmp(216) := JSR & "00" & "00" & x"55";	-- JSR .VERIFICA_ESTOURO_MINUTO 	#soma 1 no minuto e confere estouro
tmp(217) := LDA & "00" & "00" & x"02";	-- LDA R0, @2 	#carrega unidade minuto
tmp(218) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com 0
tmp(219) := JEQ & "00" & "00" & x"DD";	-- JEQ .DEPOIS_0_MIN 	#desvia se unidade for 0 min ou retorna
tmp(220) := RET & "00" & "00" & x"00";	-- RET 
tmp(221) := LDA & "01" & "00" & x"03";	-- LDA R1, @3 	#carrega dezena de minuto
tmp(222) := CEQ & "01" & "00" & x"10";	-- CEQ R1, @16 	#compara com 6
tmp(223) := JEQ & "00" & "00" & x"E1";	-- JEQ .HORA 	#desvia se dezena for 6 ou retorna
tmp(224) := RET & "00" & "00" & x"00";	-- RET
tmp(225) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(226) := STA & "00" & "00" & x"02";	-- STA R0, @2 	#zera unidade min
tmp(227) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#zera dezena min
tmp(228) := JSR & "00" & "00" & x"65";	-- JSR .VERIFICA_ESTOURO_HORA 	#soma 1 na hora e confere estouro
tmp(229) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega unidade de hora
tmp(230) := CEQ & "00" & "00" & x"12";	-- CEQ R0, @18 	#compara com 4
tmp(231) := JEQ & "00" & "00" & x"E9";	-- JEQ .DEPOIS_4_HOR 	#desvia se unidade for 4 horas ou retorna
tmp(232) := RET & "00" & "00" & x"00";	-- RET 
tmp(233) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega dezena de hora
tmp(234) := CEQ & "01" & "00" & x"11";	-- CEQ R1, @17 	#compara com 2
tmp(235) := JEQ & "00" & "00" & x"ED";	-- JEQ .ZERA_HORA 	#desvia se dezena for 6 ou retorna
tmp(236) := RET & "00" & "00" & x"00";	-- RET
tmp(237) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(238) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#zera unidade hora
tmp(239) := STA & "00" & "00" & x"05";	-- STA R0, @5 	#zera dezena hora
tmp(240) := RET & "00" & "00" & x"00";	-- RET
tmp(241) := STA & "01" & "01" & x"FE";	-- STA R1, .CK1 	#limpa k1
tmp(242) := LDA & "10" & "01" & x"61";	-- LDA R2, .K1 	#carrega k1
tmp(243) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(244) := JEQ & "00" & "00" & x"F2";	-- JEQ .ESPERA
tmp(245) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(246) := STA & "01" & "01" & x"03";	-- STA R1, .TIME_DIV 	#armazena o numero de vezes mais rapido que a base de tempo alternativa eh
tmp(247) := STA & "01" & "01" & x"FE";	-- STA R1, .CK1 	#limpa k1
tmp(248) := LDI & "01" & "00" & x"64";	-- LDI R1, $100 	#carrega 100
tmp(249) := RET & "00" & "00" & x"00";	-- RET










        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;