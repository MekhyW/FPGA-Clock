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
tmp(30) := STA & "10" & "01" & x"FD";	-- STA R2, .CTIME 	#limpa tempo
tmp(31) := LDI & "11" & "00" & x"06";	-- LDI R3, $6
tmp(32) := STA & "11" & "00" & x"10";	-- STA R3, @16 	#cte 6 para verificar 60
tmp(33) := LDI & "11" & "00" & x"02";	-- LDI R3, $2
tmp(34) := STA & "11" & "00" & x"11";	-- STA R3, @17 	#cte 2 para verificar 24
tmp(35) := LDI & "11" & "00" & x"04";	-- LDI R3, $4
tmp(36) := STA & "11" & "00" & x"12";	-- STA R3, @18 	#cte 6 para verificar 24
tmp(37) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(38) := CEQ & "00" & "01" & x"65";	-- CEQ R0, .TIME  	#ve se passou segundo
tmp(39) := JEQ & "00" & "00" & x"2A";	-- JEQ .DEPOIS_DO_TIME 	#pula se estiver solto
tmp(40) := JSR & "00" & "00" & x"3D";	-- JSR .INC 	#incrementa contagem
tmp(41) := JSR & "00" & "00" & x"AA";	-- JSR .CHECA_60 	#checa por carry de horario 
tmp(42) := JSR & "00" & "00" & x"30";	-- JSR .ATUALIZA_DISPLAY 	#atualiza info da memoria no display
tmp(43) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(44) := CEQ & "01" & "01" & x"60";	-- CEQ R1, .K0 	#ve se k0 esta pressionado
tmp(45) := JEQ & "00" & "00" & x"2F";	-- JEQ .DEPOIS_DO_K0
tmp(46) := JSR & "00" & "00" & x"75";	-- JSR .CONFIGURA_TEMPO 	#configura horario atual
tmp(47) := JMP & "00" & "00" & x"25";	-- JMP .MAIN 	#volta para o inicio do laco
tmp(48) := LDA & "00" & "00" & x"00";	-- LDA R0, @0 	#carrega unidade
tmp(49) := STA & "00" & "01" & x"20";	-- STA R0, .HEX0 	#armazena em hex0
tmp(50) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena
tmp(51) := STA & "01" & "01" & x"21";	-- STA R1, .HEX1 	#armazena em hex1
tmp(52) := LDA & "10" & "00" & x"02";	-- LDA R2, @2 	#carrega centena
tmp(53) := STA & "10" & "01" & x"22";	-- STA R2, .HEX2 	#armazena em hex2
tmp(54) := LDA & "11" & "00" & x"03";	-- LDA R3, @3 	#carrega unidade de milhar
tmp(55) := STA & "11" & "01" & x"23";	-- STA R3, .HEX3 	#armazena em hex3
tmp(56) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega dezena de milhar
tmp(57) := STA & "00" & "01" & x"24";	-- STA R0, .HEX4 	#armazena em hex4
tmp(58) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega centena de milhar
tmp(59) := STA & "01" & "01" & x"25";	-- STA R1, .HEX5 	#armazena em hex5
tmp(60) := RET & "00" & "00" & x"00";	-- RET
tmp(61) := STA & "00" & "01" & x"FD";	-- STA R0, .CTIME 	#limpa tempo
tmp(62) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(63) := CEQ & "00" & "00" & x"06";	-- CEQ R0, @6 	#compara com flag inibe contagem e retorna se for diferente de zero 
tmp(64) := JEQ & "00" & "00" & x"42";	-- JEQ .FAZ_CONTAGEM 
tmp(65) := RET & "00" & "00" & x"00";	-- RET
tmp(66) := LDA & "01" & "00" & x"00";	-- LDA R1, @0 	#carrega unidade
tmp(67) := SOMA & "01" & "00" & x"0D";	-- SOMA R1, @13 	#soma com um
tmp(68) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#armazena unidade
tmp(69) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(70) := JEQ & "00" & "00" & x"48";	-- JEQ .CARRY_UN
tmp(71) := RET & "00" & "00" & x"00";	-- RET
tmp(72) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(73) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#zera unidade
tmp(74) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena
tmp(75) := SOMA & "01" & "00" & x"0D";	-- SOMA R1, @13 	#incrementa
tmp(76) := STA & "01" & "00" & x"01";	-- STA R1, @1 	#armazena dezena
tmp(77) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(78) := JEQ & "00" & "00" & x"50";	-- JEQ .CARRY_D
tmp(79) := RET & "00" & "00" & x"00";	-- RET
tmp(80) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(81) := STA & "10" & "00" & x"01";	-- STA R2, @1 	#zera dezena
tmp(82) := LDA & "10" & "00" & x"02";	-- LDA R2, @2 	#carrega centena
tmp(83) := SOMA & "10" & "00" & x"0D";	-- SOMA R2, @13 	#incrementa
tmp(84) := STA & "10" & "00" & x"02";	-- STA R2, @2 	#armazena centena
tmp(85) := CEQ & "10" & "00" & x"0E";	-- CEQ R2, @14 	#compara com 10 para verificar estouro
tmp(86) := JEQ & "00" & "00" & x"58";	-- JEQ .CARRY_C
tmp(87) := RET & "00" & "00" & x"00";	-- RET
tmp(88) := LDI & "11" & "00" & x"00";	-- LDI R3, $0 	#carrega zero
tmp(89) := STA & "11" & "00" & x"02";	-- STA R3, @2 	#zera centena
tmp(90) := LDA & "11" & "00" & x"03";	-- LDA R3, @3 	#carrega unidade de milhar
tmp(91) := SOMA & "11" & "00" & x"0D";	-- SOMA R3, @13 	#incrementa
tmp(92) := STA & "11" & "00" & x"03";	-- STA R3, @3 	#armazena unidade de milhar
tmp(93) := CEQ & "11" & "00" & x"0E";	-- CEQ R3, @14 	#compara com 10 para verificar estouro
tmp(94) := JEQ & "00" & "00" & x"60";	-- JEQ .CARRY_U_MILHAR
tmp(95) := RET & "00" & "00" & x"00";	-- RET
tmp(96) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(97) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#zera unidade de milhar
tmp(98) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega dezena de milhar
tmp(99) := SOMA & "00" & "00" & x"0D";	-- SOMA R0, @13 	#incrementa
tmp(100) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#armazena dezena de milhar
tmp(101) := CEQ & "00" & "00" & x"0E";	-- CEQ R0, @14 	#compara com 10 para verificar estouro
tmp(102) := JEQ & "00" & "00" & x"68";	-- JEQ .CARRY_D_MILHAR
tmp(103) := RET & "00" & "00" & x"00";	-- RET
tmp(104) := LDI & "01" & "00" & x"00";	-- LDI R1, $0 	#carrega zero
tmp(105) := STA & "01" & "00" & x"04";	-- STA R1, @4 	#zera dezena de milhar
tmp(106) := LDA & "01" & "00" & x"05";	-- LDA R1, @5 	#carrega centena de milhar
tmp(107) := SOMA & "01" & "00" & x"0D";	-- SOMA R1, @13 	#incrementa
tmp(108) := STA & "01" & "00" & x"05";	-- STA R1, @5 	#armazena centena de milhar
tmp(109) := CEQ & "01" & "00" & x"0E";	-- CEQ R1, @14 	#compara com 10 para verificar estouro
tmp(110) := JEQ & "00" & "00" & x"70";	-- JEQ .CARRY_C_MILHAR
tmp(111) := RET & "00" & "00" & x"00";	-- RET
tmp(112) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega zero
tmp(113) := STA & "10" & "00" & x"05";	-- STA R2, @5 	#zera centena de milhar
tmp(114) := LDI & "10" & "00" & x"01";	-- LDI R2, $1 	#carrega um
tmp(115) := STA & "10" & "01" & x"02";	-- STA R2, .LED9 	#acende led de estouro
tmp(116) := RET & "00" & "00" & x"00";	-- RET
tmp(117) := LDI & "00" & "00" & x"01";	-- LDI R0, $1 	#carrega um
tmp(118) := STA & "00" & "01" & x"00";	-- STA R0, .LEDS 	#ativa led0 pra indicar unidade segundo
tmp(119) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero
tmp(120) := STA & "00" & "01" & x"FF";	-- STA R0, .CK0 	#limpa k0
tmp(121) := LDA & "01" & "01" & x"60";	-- LDA R1, .K0 	#carrega k0
tmp(122) := CEQ & "01" & "00" & x"0F";	-- CEQ R1, @15 	#compara com zero para saber se esta pressionado
tmp(123) := JEQ & "00" & "00" & x"79";	-- JEQ .ESPERA_UN_S
tmp(124) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(125) := STA & "01" & "00" & x"00";	-- STA R1, @0 	#armazena em unidade segundo
tmp(126) := STA & "01" & "01" & x"FF";	-- STA R1, .CK0 	#limpa k0
tmp(127) := LDI & "01" & "00" & x"02";	-- LDI R1, $2 	#carrega 2
tmp(128) := STA & "01" & "01" & x"00";	-- STA R1, .LEDS 	#ativa led1
tmp(129) := LDA & "10" & "01" & x"60";	-- LDA R2, .K0 	#carrega k0
tmp(130) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(131) := JEQ & "00" & "00" & x"81";	-- JEQ .ESPERA_D_S
tmp(132) := LDA & "10" & "01" & x"40";	-- LDA R2, .SWS 	#carrega chaves
tmp(133) := STA & "10" & "00" & x"01";	-- STA R2, @1 	#armazena em dezena segundo
tmp(134) := STA & "10" & "01" & x"FF";	-- STA R2, .CK0 	#limpa k0
tmp(135) := LDI & "10" & "00" & x"04";	-- LDI R2, $4 	#carrega 4
tmp(136) := STA & "10" & "01" & x"00";	-- STA R2, .LEDS 	#ativa led2
tmp(137) := LDA & "11" & "01" & x"60";	-- LDA R3, .K0 	#carrega k0
tmp(138) := CEQ & "11" & "00" & x"0F";	-- CEQ R3, @15 	#compara com zero para saber se esta pressionado
tmp(139) := JEQ & "00" & "00" & x"89";	-- JEQ .ESPERA_UN_M
tmp(140) := LDA & "11" & "01" & x"40";	-- LDA R3, .SWS 	#carrega chaves
tmp(141) := STA & "11" & "00" & x"02";	-- STA R3, @2 	#armazena em unidade minuto
tmp(142) := STA & "11" & "01" & x"FF";	-- STA R3, .CK0 	#limpa k0
tmp(143) := LDI & "11" & "00" & x"08";	-- LDI R3, $8 	#carrega 8
tmp(144) := STA & "11" & "01" & x"00";	-- STA R3, .LEDS 	#ativa led3
tmp(145) := LDA & "00" & "01" & x"60";	-- LDA R0, .K0 	#carrega k0
tmp(146) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com zero para saber se esta pressionado
tmp(147) := JEQ & "00" & "00" & x"91";	-- JEQ .ESPERA_D_M
tmp(148) := LDA & "00" & "01" & x"40";	-- LDA R0, .SWS 	#carrega chaves
tmp(149) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#armazena em dezena minuto
tmp(150) := STA & "00" & "01" & x"FF";	-- STA R0, .CK0 	#limpa k0
tmp(151) := LDI & "00" & "00" & x"10";	-- LDI R0, $16 	#carrega 16
tmp(152) := STA & "00" & "01" & x"00";	-- STA R0, .LEDS 	#ativa led4
tmp(153) := LDA & "01" & "01" & x"60";	-- LDA R1, .K0 	#carrega k0
tmp(154) := CEQ & "01" & "00" & x"0F";	-- CEQ R1, @15 	#compara com zero para saber se esta pressionado
tmp(155) := JEQ & "00" & "00" & x"99";	-- JEQ .ESPERA_UN_H
tmp(156) := LDA & "01" & "01" & x"40";	-- LDA R1, .SWS 	#carrega chaves
tmp(157) := STA & "01" & "00" & x"04";	-- STA R1, @4 	#armazena em unidade hora
tmp(158) := STA & "01" & "01" & x"FF";	-- STA R1, .CK0 	#limpa k0
tmp(159) := LDI & "01" & "00" & x"20";	-- LDI R1, $32 	#carrega 32
tmp(160) := STA & "01" & "01" & x"00";	-- STA R1, .LEDS 	#ativa led5
tmp(161) := LDA & "10" & "01" & x"60";	-- LDA R2, .K0 	#carrega k0
tmp(162) := CEQ & "10" & "00" & x"0F";	-- CEQ R2, @15 	#compara com zero para saber se esta pressionado
tmp(163) := JEQ & "00" & "00" & x"A1";	-- JEQ .ESPERA_D_H
tmp(164) := LDA & "10" & "01" & x"40";	-- LDA R2, .SWS 	#carrega chaves
tmp(165) := STA & "10" & "00" & x"05";	-- STA R2, @5 	#armazena em dezena hora
tmp(166) := STA & "10" & "01" & x"FF";	-- STA R2, .CK0 	#limpa k0
tmp(167) := LDI & "10" & "00" & x"00";	-- LDI R2, $0 	#carrega 0
tmp(168) := STA & "10" & "01" & x"00";	-- STA R2, .LEDS 	#desativa leds
tmp(169) := RET & "00" & "00" & x"00";	-- RET
tmp(170) := LDA & "00" & "00" & x"00";	-- LDA R0, @0 	#carrega unidade de segundo
tmp(171) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com 0
tmp(172) := JEQ & "00" & "00" & x"AE";	-- JEQ .DEPOIS_0_SEG 	#desvia se unidade for 0 seg ou retorna
tmp(173) := RET & "00" & "00" & x"00";	-- RET 
tmp(174) := LDA & "01" & "00" & x"01";	-- LDA R1, @1 	#carrega dezena de segundo
tmp(175) := CEQ & "01" & "00" & x"10";	-- CEQ R1, @16 	#compara com 6
tmp(176) := JEQ & "00" & "00" & x"B2";	-- JEQ .MINUTO 	#desvia se dezena for 6 ou retorna
tmp(177) := RET & "00" & "00" & x"00";	-- RET
tmp(178) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(179) := STA & "00" & "00" & x"00";	-- STA R0, @0 	#zera unidade segundo
tmp(180) := STA & "00" & "00" & x"01";	-- STA R0, @1 	#zera dezena segundo
tmp(181) := LDA & "00" & "00" & x"02";	-- LDA R0, @2 	#carrega unidade de minuto
tmp(182) := SOMA & "00" & "00" & x"0D";	-- SOMA R0, @13 	#incrementa unidade de minuto
tmp(183) := STA & "00" & "00" & x"02";	-- STA R0, @2 	#salva resultado da soma
tmp(184) := CEQ & "00" & "00" & x"0F";	-- CEQ R0, @15 	#compara com 0
tmp(185) := JEQ & "00" & "00" & x"BB";	-- JEQ .DEPOIS_0_MIN 	#desvia se unidade for 0 min ou retorna
tmp(186) := RET & "00" & "00" & x"00";	-- RET 
tmp(187) := LDA & "01" & "00" & x"03";	-- LDA R1, @3 	#carrega dezena de minuto
tmp(188) := CEQ & "01" & "00" & x"10";	-- CEQ R1, @16 	#compara com 6
tmp(189) := JEQ & "00" & "00" & x"BF";	-- JEQ .HORA 	#desvia se dezena for 6 ou retorna
tmp(190) := RET & "00" & "00" & x"00";	-- RET
tmp(191) := LDI & "00" & "00" & x"00";	-- LDI R0, $0 	#carrega zero 
tmp(192) := STA & "00" & "00" & x"02";	-- STA R0, @2 	#zera unidade min
tmp(193) := STA & "00" & "00" & x"03";	-- STA R0, @3 	#zera dezena min
tmp(194) := LDA & "00" & "00" & x"04";	-- LDA R0, @4 	#carrega unidade de hora
tmp(195) := SOMA & "00" & "00" & x"0D";	-- SOMA R0, @13 	#incrementa unidade de hora
tmp(196) := STA & "00" & "00" & x"04";	-- STA R0, @4 	#salva resultado da soma
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









        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;