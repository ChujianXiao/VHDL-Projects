--An eight bit adder/subtracter.
library IEEE;
use IEEE.std_logic_1164.all;

entity eightBitAdder is
	port(A,B: in std_logic_vector(7 downto 0);
	sum : out std_logic_vector(7 downto 0);
    addSubPrime : in std_logic;
	carry_out,overflow: out std_logic);
end eightBitAdder;

architecture struct of eightBitAdder is
	component FA  is
		port(A,B,carry_in : in std_logic;         
		sum,carry_out : out std_logic);
	end component;
	
	signal int_carry: std_logic_vector(8 downto 0);
	signal int_inB: std_logic_vector(7 downto 0);
	signal int_sum: std_logic_vector(7 downto 0);
	
	begin
	int_carry(0) <= not (addSubPrime);
	
	adder_gen: for i in 0 to 7 generate
		full_adderi: FA port map(A(i),int_inB(i),int_carry(i),int_sum(i),int_carry(i+1));
	end generate;
	
	B_gen: for i in 0 to 7 generate
		int_inB(i) <= B(i) xor (not addSubPrime);
	end generate;
	
	--output driver
	sum <= int_sum;
	carry_out <= int_carry(8);
	overflow <= (int_carry(8) xor int_carry(7));
	
end struct;