library ieee;
use ieee.std_logic_1164.all;

entity decoderInstru is
  port ( opcode : in std_logic_vector(4 downto 0);
         saida : out std_logic_vector(14 downto 0)
  );
end entity;

architecture comportamento of decoderInstru is

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

  begin
saida <= "000000000000000" when opcode = NOP else
         "000000001011010" when opcode = LDA else
         "000000001000010" when opcode = SOMA else
			"000000011000000" when opcode = SOMAI else
         "000000001001010" when opcode = SUB else
         "000000011011000" when opcode = LDI else
			"000000000011001" when opcode = STA else
			"000100000000000" when opcode = JMP else
			"000000100000000" when opcode = JEQ else
			"000000000001110" when opcode = CEQ else
			"001001000000000" when opcode = JSR else
			"000010000000000" when opcode = RET else
			"000000001110010" when opcode = OP_AND else
			"010000000001010" when opcode = CLT else
			"100000000000000" when opcode = JLT else
         "000000000000000";  -- NOP para os opcodes Indefinidos
end architecture;