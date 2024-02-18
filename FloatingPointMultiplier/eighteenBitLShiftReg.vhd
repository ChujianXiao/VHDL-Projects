LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY eighteenBitLShiftReg IS
    PORT(
        i_reset,i_load: IN STD_LOGIC;
        i_shift: IN STD_LOGIC;
        i_clock: IN STD_LOGIC;
        i_value: IN STD_LOGIC_VECTOR(17 downto 0);
        o_value: OUT STD_LOGIC_VECTOR(17 downto 0)
    );
END ENTITY eighteenBitLShiftReg;

ARCHITECTURE LeftShift OF eighteenBitLShiftReg IS
    SIGNAL int_value, int_notValue: STD_LOGIC_VECTOR(17 downto 0);
    SIGNAL int_dOut: STD_LOGIC_VECTOR(17 downto 0);
    SIGNAL int_loadDatabit0, int_loadDataRest: STD_LOGIC;
	 SIGNAL muxChoseOut: STD_LOGIC;

    COMPONENT  enARdFF_2
        PORT(
            i_resetBar: IN STD_LOGIC;
            i_d: IN STD_LOGIC;
            i_enable: IN STD_LOGIC;
            i_clock : IN STD_LOGIC;
            o_q, o_qBar: OUT STD_LOGIC
        );
    END COMPONENT enARdFF_2;

    COMPONENT mux1 IS
	PORT(
        i_input: IN STD_LOGIC_VECTOR(1 downto 0);
        i_select: IN STD_LOGIC;
        o_output: OUT STD_LOGIC);
    END COMPONENT mux1;

BEGIN
    int_loadDataBit0 <= i_load or i_shift;
    int_loadDataRest <= i_load or i_shift;
	 
	 --This mux chooses whether to output '0' when shifting or load in the input value.
    mux0: mux1
    PORT MAP(
        i_input(0) => i_value(0),
        i_input(1) => '0', 
        i_select => not(i_load),
        o_output => int_value(0)
    );

    bit0: enARdFF_2
        PORT MAP(
            i_resetBar => not(i_reset),
            i_d => int_value(0),
            i_enable => int_loadDataBit0,
            i_clock => i_clock,
            o_q => int_dOut(0),
            o_qBar => int_notValue(0)
        );
   
    dFFGen: FOR i IN 1 TO 17 GENERATE
        bitX: enARdFF_2
        PORT MAP(
            i_resetBar => not(i_reset),
            i_d => int_value(i),
            i_enable => int_loadDataRest,
            i_clock => i_clock,
            o_q => int_dOut(i),
            o_qBar => int_notValue(i)
        );
    END GENERATE;

    muxGen: FOR i IN 1 TO 17 GENERATE
        muxX: mux1
        PORT MAP(
            i_input(0) => i_value(i),
            i_input(1) => int_dOut(i-1),
            i_select => not(i_load),
            o_output => int_value(i)
        );
    END GENERATE;
    -- Output Driver
    o_value <= int_dOut;
    
END ARCHITECTURE LeftShift;