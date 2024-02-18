LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY floatingPointMultiplier IS
    PORT(
        i_clock, i_globalReset: IN STD_LOGIC;
        i_inA,i_inB: IN STD_LOGIC_VECTOR(15 downto 0);

		  o_overflow: OUT STD_LOGIC;
        o_output: OUT STD_LOGIC_VECTOR(15 downto 0);
        o_partialProduct: OUT STD_LOGIC_VECTOR(17 downto 0);
        o_state: OUT STD_LOGIC_VECTOR(7 downto 0)
    );
END ENTITY floatingPointMultiplier;

ARCHITECTURE rtl OF floatingPointMultiplier IS

COMPONENT multiplicationDatapath IS
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
END COMPONENT;

COMPONENT multiplicationControlPath IS
    PORT(
        i_clock, i_globalReset: IN STD_LOGIC;
        i_multiplierLSB,i_productMSB: IN STD_LOGIC;

        o_loadInA,o_loadInB,o_loadexponentA,o_loadexponentB,o_loadFinalExponent,o_loadMantissaA,o_loadMantissaB,o_loadProduct,o_loadOutput: OUT STD_LOGIC;
        o_shiftMantissaA,o_shiftMantissaB,o_shiftProduct: OUT STD_LOGIC;
        o_selectIncrement: OUT STD_LOGIC;
        o_state: OUT STD_LOGIC_VECTOR(7 downto 0)
    );
END COMPONENT;

SIGNAL int_state: STD_LOGIC_VECTOR(7 downto 0);
SIGNAL int_product: STD_LOGIC_VECTOR(15 downto 0);
SIGNAL int_loadInA,int_loadInB,int_loadexponentA,int_loadexponentB,int_loadFinalExponent,int_loadMantissaA,int_loadMantissaB,int_loadProduct,int_loadOutput: STD_LOGIC;
SIGNAL int_shiftMantissaA,int_shiftMantissaB,int_shiftProduct: STD_LOGIC;
SIGNAL int_selectIncrement: STD_LOGIC;
SIGNAL int_multiplierLSB,int_productMSB,int_overflow: STD_LOGIC;
SIGNAL int_partialProduct: STD_LOGIC_VECTOR(17 downto 0);
SIGNAL int_output: STD_LOGIC_VECTOR(15 downto 0);

BEGIN
datapath: multiplicationDatapath
    PORT MAP(i_globalReset,i_clock,
        i_inA,i_inB,
        int_loadInA,int_loadInB,int_loadexponentA,int_loadexponentB,int_loadFinalExponent,int_loadMantissaA,int_loadMantissaB,int_loadProduct,int_loadOutput,
        int_shiftMantissaA,int_shiftMantissaB,int_shiftProduct,
        int_selectIncrement,
        int_multiplierLSB,int_productMSB,int_overflow,
        int_partialProduct,
        int_output
    );

controlpath: multiplicationControlPath
    PORT MAP(
        i_clock, i_globalReset,
        int_multiplierLSB,int_productMSB,

        int_loadInA,int_loadInB,int_loadexponentA,int_loadexponentB,int_loadFinalExponent,int_loadMantissaA,int_loadMantissaB,int_loadProduct,int_loadOutput,
        int_shiftMantissaA,int_shiftMantissaB,int_shiftProduct,
        int_selectIncrement,
        int_state
    );

--Outputs
o_output <= int_output;
o_state <= int_state;
o_partialProduct <= int_partialProduct;
o_overflow <= int_overflow;

END rtl;