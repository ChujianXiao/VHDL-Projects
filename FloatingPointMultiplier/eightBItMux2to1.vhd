LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY eightBitMUX2to1 IS
    PORT(i_input0,i_input1: IN STD_LOGIC_VECTOR(7 downto 0);
    i_select: IN STD_LOGIC;
    o_output: OUT STD_LOGIC_VECTOR(7 downto 0));
END eightBitMUX2to1;

architecture design of eightBitMUX2to1 IS

COMPONENT mux1
	PORT(
        i_input: IN STD_LOGIC_VECTOR(1 downto 0);
        i_select: IN STD_LOGIC;
        o_output: OUT STD_LOGIC);
END COMPONENT;

BEGIN
    muxGen: FOR i IN 7 DOWNTO 0 GENERATE
	    bitX: mux1 PORT MAP(
		 i_input(0) => i_input0(i),
		 i_input(1) => i_input1(i),
		 i_select => i_select,
		 o_output => o_output(i));
    END GENERATE;
END design;