--5 bit synchronous fiveBitUpCounter
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fiveBitUpCounter IS
	PORT(
		i_reset: IN	STD_LOGIC;
		i_inc: IN	STD_LOGIC;
		o_value: OUT STD_LOGIC_VECTOR(4 downto 0));
END fiveBitUpCounter;

ARCHITECTURE rtl OF fiveBitUpCounter IS
	SIGNAL int_tOut: STD_LOGIC_VECTOR(4 downto 0);
    SIGNAL int_tIn: STD_LOGIC_VECTOR(4 downto 0);

	COMPONENT enARtFF IS
	PORT(
		i_resetBar	: IN	STD_LOGIC;
		i_t		: IN	STD_LOGIC;
		i_enable	: IN	STD_LOGIC;
		i_clock		: IN	STD_LOGIC;
		o_q, o_qBar	: OUT	STD_LOGIC);
    END COMPONENT;

BEGIN
int_tIn(0) <= '1';
int_tIn(1) <= int_tOut(0);
nextInputGen: FOR i in 2 to 4 GENERATE
int_tIn(i) <= int_tOut(i-1) AND int_tIn(i-1);
END GENERATE;

flipFlopGen: FOR i IN 0 TO 4 GENERATE
tFFX: enARtFF
	PORT MAP (i_resetBar => NOT(i_reset),
			  i_t => int_tIn(i),
			  i_enable => '1', 
			  i_clock => i_inc,
			  o_q => int_tOut(i));
END GENERATE;

	-- Output Driver
	o_value <= int_tOut;
END rtl;
