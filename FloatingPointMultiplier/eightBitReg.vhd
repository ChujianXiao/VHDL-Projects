LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY eightBitReg IS
    PORT(
        i_reset,i_load: IN STD_LOGIC;
        i_clock: IN STD_LOGIC;
        i_value: IN STD_LOGIC_VECTOR(7 downto 0);
        o_value: OUT STD_LOGIC_VECTOR(7 downto 0)
    );
END ENTITY eightBitReg;

ARCHITECTURE structural OF eightBitReg IS
    SIGNAL int_value, int_notValue: STD_LOGIC_VECTOR(7 downto 0);

    COMPONENT  enARdFF_2
        PORT(
            i_resetBar: IN STD_LOGIC;
            i_d: IN STD_LOGIC;
            i_enable: IN STD_LOGIC;
            i_clock : IN STD_LOGIC;
            o_q, o_qBar: OUT STD_LOGIC
        );
    END COMPONENT enARdFF_2;

BEGIN
    regGen: FOR i IN 7 DOWNTO 0 GENERATE
        bitX: enARdFF_2
        PORT MAP(
            i_resetBar => NOT(i_reset),
            i_d => i_value(i),
            i_enable => i_load,
            i_clock => i_clock,
            o_q => int_value(i),
            o_qBar => int_notValue(i)
        );
    END GENERATE;
    -- Output Driver
    o_value <= int_value;
    
END ARCHITECTURE structural;
