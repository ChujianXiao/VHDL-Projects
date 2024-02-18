LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY multiplicationControlPath IS
    PORT(
        i_clock, i_globalReset: IN STD_LOGIC;
        i_multiplierLSB,i_productMSB: IN STD_LOGIC;

        o_loadInA,o_loadInB,o_loadexponentA,o_loadexponentB,o_loadFinalExponent,o_loadMantissaA,o_loadMantissaB,o_loadProduct,o_loadOutput: OUT STD_LOGIC;
        o_shiftMantissaA,o_shiftMantissaB,o_shiftProduct: OUT STD_LOGIC;
        o_selectIncrement: OUT STD_LOGIC;
        o_state: OUT STD_LOGIC_VECTOR(7 downto 0)
    );
END ENTITY multiplicationControlPath;

ARCHITECTURE structural OF multiplicationControlPath IS

    COMPONENT enASdFF
        PORT(
            i_setBar	: IN	STD_LOGIC;
            i_d		: IN	STD_LOGIC;
            i_enable	: IN	STD_LOGIC;
            i_clock		: IN	STD_LOGIC;
            o_q, o_qBar	: OUT	STD_LOGIC);
    END COMPONENT;

    COMPONENT  enARdFF_2
        PORT(
            i_resetBar: IN STD_LOGIC;
            i_d: IN STD_LOGIC;
            i_enable: IN STD_LOGIC;
            i_clock : IN STD_LOGIC;
            o_q, o_qBar: OUT STD_LOGIC
        );
    END COMPONENT enARdFF_2;

    COMPONENT fiveBitComparator IS
	PORT(
		i_Ai, i_Bi			: IN	STD_LOGIC_VECTOR(4 downto 0);
		o_GT, o_LT, o_EQ		: OUT	STD_LOGIC);
    END COMPONENT;

    COMPONENT fiveBitUpCounter IS
	PORT(
		i_reset: IN	STD_LOGIC;
		i_inc: IN	STD_LOGIC;
		o_value: OUT STD_LOGIC_VECTOR(4 downto 0));
    END COMPONENT;

    SIGNAL int_s0,int_s1,int_s2,int_s3,int_loop,int_addMult,int_notAddMult,int_s4,int_s5,int_branchLoop,int_exitLoop,
    int_shiftProduct,int_notShiftProduct,int_s6,int_s7: STD_LOGIC;
    SIGNAL int_incCounter,int_resetCounter,int_compEq: STD_LOGIC;
    SIGNAL int_counterOut: STD_LOGIC_VECTOR(4 downto 0);
BEGIN
	 
    --Each register represents one state of the datapath.
    --The initial state after each reset
    state0: enASdFF
    PORT MAP(
        i_setBar => NOT(i_globalReset),
        i_d => '0',
        i_enable => '1',
        i_clock => i_clock,
        o_q => int_s0
    );

    --Load the input registers
    state1: enARdFF_2
    PORT MAP(
        i_resetBar => NOT i_globalReset,
        i_d => int_s0,
        i_enable => '1',
        i_clock => i_clock,
        o_q => int_s1
    );

    --Load the output of the input registers into the exponent and mantissa registers
    state2: enARdFF_2
    PORT MAP(
        i_resetBar => NOT i_globalReset,
        i_d => int_s1,
        i_enable => '1',
        i_clock => i_clock,
        o_q => int_s2
    );

    --After adding the two exponents and subtracting the bias, load the final exponent;
    state3: enARdFF_2
    PORT MAP(
        i_resetBar => NOT i_globalReset,
        i_d => int_s2,
        i_enable => '1',
        i_clock => i_clock,
        o_q => int_s3
    );

    int_incCounter <= int_s5;
    int_resetCounter <= int_s3;

   loopCounter: fiveBitUpCounter
	PORT MAP(
		i_reset => int_resetCounter OR i_globalReset,
		i_inc => int_incCounter,
		o_value => int_counterOut
    );

    comp: fiveBitComparator
	PORT MAP(
		i_Ai => int_counterOut,
        i_Bi => "01001",
        o_EQ =>	int_compEq
    );
    
    --Enter the loop, 
    loop1: enARdFF_2
    PORT MAP(
        i_resetBar => NOT i_globalReset,
        i_d => int_s3 OR int_branchLoop,
        i_enable => '1',
        i_clock => i_clock,
        o_q => int_loop
    );
    --If the LSB of the multiplier is 1, add the multiplicand to the product, otherwise skip.
    int_addMult <= int_loop AND i_multiplierLSB;
    int_notAddMult <= int_loop AND NOT i_multiplierLSB;

    --State for loading sum into product
    state4: enARdFF_2
    PORT MAP(
        i_resetBar => NOT i_globalReset,
        i_d => int_addMult,
        i_enable => '1',
        i_clock => i_clock,
        o_q => int_s4
    );

    --Shift multiplicand left, shift multiplier right, increment loop counter
    state5: enARdFF_2
    PORT MAP(
        i_resetBar => NOT i_globalReset,
        i_d => int_s4 OR int_notAddMult,
        i_enable => '1',
        i_clock => i_clock,
        o_q => int_s5
    );
    
    --If looped 9 times, exit loop. Otherwise branch back to loop start.
    int_branchLoop <= int_s5 AND NOT(int_compEq);
    int_exitLoop <= int_s5 AND int_compEq;
    
    --If the product MSB is 1, the mantissa is 1X.XXXXXXX, so we shift the product right and increment the exponent.  
    int_shiftProduct <= int_exitLoop AND i_productMSB;
    int_notShiftProduct <= int_exitLoop AND NOT i_productMSB;

    state6: enARdFF_2
    PORT MAP(
        i_resetBar => NOT i_globalReset,
        i_d => int_shiftProduct,
        i_enable => '1',
        i_clock => i_clock,
        o_q => int_s6
    );

    --Load the output register.
    state7: enARdFF_2
    PORT MAP(
        i_resetBar => NOT i_globalReset,
        i_d => int_notShiftProduct OR int_s6,
        i_enable => '1',
        i_clock => i_clock,
        o_q => int_s7
    );

    --output driver
    o_loadInA <= int_s1;
    o_loadInB <= int_s1;
    o_loadexponentA <= int_s2;
    o_loadexponentB <= int_s2;
    o_loadFinalExponent <= int_s3 OR int_s6;
    o_loadMantissaA <= int_s2;
    o_loadMantissaB <= int_s2;
    o_loadProduct <= int_s4;
    o_loadOutput <= int_s7;
    o_shiftMantissaA <= int_s5;
    o_shiftMantissaB <= int_s5;
    o_shiftProduct <= int_s6;
    o_selectIncrement <= int_s6;

    o_state(7) <= int_s7;
    o_state(6) <= int_s6;
    o_state(5) <= int_s5;
    o_state(4) <= int_s4;
    o_state(3) <= int_s3;
    o_state(2) <= int_s2;
    o_state(1) <= int_s1;
    o_state(0) <= int_s0;

END ARCHITECTURE structural;
