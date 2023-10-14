library ieee;
use ieee.std_logic_1164.all;

entity decoderInstru is
  port ( opcode : in std_logic_vector(4 downto 0);
         saida : out std_logic_vector(12 downto 0)
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

  begin
saida <= "0000000000000" when opcode = NOP else
         "0000001011010" when opcode = LDA else
         "0000001000010" when opcode = SOMA else
         "0000001001010" when opcode = SUB else
         "0000011011000" when opcode = LDI else
			"0000000011001" when opcode = STA else
			"0100000000000" when opcode = JMP else
			"0000100000000" when opcode = JEQ else
			"0000000001110" when opcode = CEQ else
			"1001000000000" when opcode = JSR else
			"0010000000000" when opcode = RET else
			"0000001110010" when opcode = OP_AND else
         "0000000000000";  -- NOP para os opcodes Indefinidos
end architecture;