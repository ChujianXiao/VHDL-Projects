LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY multiplicationDatapath IS
    PORT(
		  i_reset,i_clock: IN STD_LOGIC;
        i_inA,i_inB: IN STD_LOGIC_VECTOR(15 downto 0);
        i_loadInA,i_loadInB,i_loadexponentA,i_loadexponentB,i_loadFinalExponent,i_loadMantissaA,i_loadMantissaB,i_loadProduct,i_loadOutput: IN STD_LOGIC;
        i_shiftMantissaA,i_shiftMantissaB,i_shiftProduct: IN STD_LOGIC;
        i_selectIncrement: IN STD_LOGIC;
        o_multiplierLSB,o_productMSB,o_overflow: OUT STD_LOGIC;
        o_partialProduct: OUT STD_LOGIC_VECTOR(17 downto 0);
        o_output: OUT STD_LOGIC_VECTOR(15 downto 0)
    );
END ENTITY multiplicationDatapath;

ARCHITECTURE structural OF multiplicationDatapath IS

COMPONENT eighteenBitAdder IS
	port(A,B: in std_logic_vector(17 downto 0);
	sum : out std_logic_vector(17 downto 0);
    addSubPrime : in std_logic;
	carry_out,overflow: out std_logic);
END COMPONENT;

COMPONENT eighteenBitRShiftReg IS
    PORT(
        i_reset,i_load: IN STD_LOGIC;
        i_shift: IN STD_LOGIC;
        i_clock: IN STD_LOGIC;
        i_value: IN STD_LOGIC_VECTOR(17 downto 0);
        o_value: OUT STD_LOGIC_VECTOR(17 downto 0)
    );
END COMPONENT eighteenBitRShiftReg;

COMPONENT eighteenBitLShiftReg IS
    PORT(
        i_reset,i_load: IN STD_LOGIC;
        i_shift: IN STD_LOGIC;
        i_clock: IN STD_LOGIC;
        i_value: IN STD_LOGIC_VECTOR(17 downto 0);
        o_value: OUT STD_LOGIC_VECTOR(17 downto 0)
    );
END COMPONENT eighteenBitLShiftReg;

component eightBitAdder is
	port(A,B: in std_logic_vector(7 downto 0);
	sum : out std_logic_vector(7 downto 0);
    addSubPrime : in std_logic;
	carry_out,overflow: out std_logic);
end component;

COMPONENT eightBitReg IS
    PORT(
        i_reset,i_load: IN STD_LOGIC;
        i_clock: IN STD_LOGIC;
        i_value: IN STD_LOGIC_VECTOR(7 downto 0);
        o_value: OUT STD_LOGIC_VECTOR(7 downto 0)
    );
END COMPONENT eightBitReg;

COMPONENT sixteenBitReg IS
    PORT(
        i_reset,i_load: IN STD_LOGIC;
        i_clock: IN STD_LOGIC;
        i_value: IN STD_LOGIC_VECTOR(15 downto 0);
        o_value: OUT STD_LOGIC_VECTOR(15 downto 0)
    );
END COMPONENT sixteenBitReg;

COMPONENT eightBitMUX2to1 IS
    PORT(i_input0,i_input1: IN STD_LOGIC_VECTOR(7 downto 0);
    i_select: IN STD_LOGIC;
    o_output: OUT STD_LOGIC_VECTOR(7 downto 0));
END COMPONENT eightBitMUX2to1;

SIGNAL int_A,int_B,int_output: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL int_sign: STD_LOGIC;
SIGNAL int_exponentA,int_exponentB,int_biasedSum,int_exponentSum,int_eightBitMuxOut,int_incrementedSum,int_finalExponent: STD_LOGIC_VECTOR(7 downto 0);
SIGNAL int_mantissaA,int_mantissaB,int_multAdder,int_product: STD_LOGIC_VECTOR(17 downto 0);
SIGNAL int_multiplierLSB: STD_LOGIC;

BEGIN

inA: sixteenBitReg
PORT MAP(
    i_reset => i_reset,
    i_load => i_loadInA,
    i_clock => i_clock,
    i_value => i_InA,
    o_value => int_A
);

inB: sixteenBitReg
PORT MAP(
    i_reset => i_reset,
    i_load => i_loadInB,
    i_clock => i_clock,
    i_value => i_InB,
    o_value => int_B
);

--First compute the final sign
int_sign <= int_A(15) XOR int_B(15);

exponentA: eightBitReg
PORT MAP(
    i_reset => i_reset,
    i_load => i_loadexponentA,
    i_clock => i_clock,
    i_value(7) => '0',
    i_value(6 downto 0) => int_A(14 downto 8),
    o_value => int_exponentA
);

exponentB: eightBitReg
PORT MAP(
    i_reset => i_reset,
    i_load => i_loadexponentB,
    i_clock => i_clock,
    i_value(7) => '0',
    i_value(6 downto 0) => int_B(14 downto 8),
    o_value => int_exponentB
);

--Add the two exponents together
exponentAdder: eightBitAdder
PORT MAP(
    A => int_exponentA,
    B => int_exponentB,
	sum => int_biasedSum,
    addSubPrime => '1'
);

--Then subtract the bias
biasSubtracter: eightBitAdder
PORT MAP(
    A => int_biasedSum,
    B => "00111111",
	sum => int_exponentSum,
    addSubPrime => '0'
);

--If the mantissa needs to be normalized, the exponent needs to be incremented
incrementChooser: eightBitMUX2to1
    PORT MAP(i_input0 => int_exponentSum,
    i_input1 => int_incrementedSum,
    i_select => i_selectIncrement,
    o_output => int_eightBitMuxOut);

finalExponent: eightBitReg
    PORT MAP(
        i_reset => i_reset,
        i_load => i_loadFinalExponent,
        i_clock => i_clock,
        i_value => int_eightBitMuxOut,
        o_value => int_finalExponent
    );

incrementer: eightBitAdder
    PORT MAP(
        A => int_finalExponent,
        B => "00000001",
        sum => int_incrementedSum,
        addSubPrime => '1'
    );

--Now the datapath for the mantissa
Multiplicand: eighteenBitLShiftReg
    PORT MAP(
        i_reset => i_reset,
        i_load => i_loadMantissaA,
        i_shift => i_shiftMantissaA,
        i_clock => i_clock,
        i_value(17 downto 9) => "000000000",
        i_value(8) => '1',
        i_value(7 downto 0) => int_A(7 downto 0),
        o_value => int_mantissaA
    );

Multiplier: eighteenBitRShiftReg
    PORT MAP(
        i_reset => i_reset,
        i_load => i_loadMantissaB,
        i_shift => i_shiftMantissaB,
        i_clock => i_clock,
        i_value(17 downto 9) => "000000000",
        i_value(8) => '1',
        i_value(7 downto 0) => int_B(7 downto 0),
        o_value => int_mantissaB
    );

MultAdder: eighteenBitAdder
    PORT MAP(
        A => int_mantissaA,
        B => int_product,
        sum => int_multAdder,
        addSubPrime => '1'
    );

Product: eighteenBitRShiftReg
    PORT MAP(
        i_reset => i_reset,
        i_load => i_loadProduct,
        i_shift => i_shiftProduct,
        i_clock => i_clock,
        i_value => int_multAdder,
        o_value => int_product
    );

finalOutput: sixteenBitReg
    PORT MAP(
        i_reset => i_reset,
        i_load => i_loadOutput,
        i_clock => i_clock,
        i_value(15) => int_sign,
        i_value(14 downto 8) => int_finalExponent(6 downto 0),
        i_value(7 downto 0) => int_product(15 downto 8),
        o_value => int_output
    );

--OUTPUTS  
o_partialProduct <= int_product;
o_output <= int_output;
o_multiplierLSB <= int_mantissaB(0);
o_productMSB <= int_product(17);
o_overflow <= int_finalExponent(7);

END structural;