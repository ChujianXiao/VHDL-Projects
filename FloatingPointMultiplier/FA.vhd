library IEEE;
use IEEE.std_logic_1164.all;

entity FA  is
	port(A,B,carry_in: in std_logic;
	sum,carry_out : out std_logic);
end FA ;

architecture flow of FA  is
	component HA  is
		port(A,B : in std_logic;         
		sum,carryout : out std_logic);
	end component;
	
signal s1,c1,c2:std_logic;

begin
	half_adder1: HA  port map (A=>A,B=>B,sum=>s1,carryout=>c1);
	half_adder2: HA  port map(A=>carry_in,B=>s1,sum=>sum,carryout=>c2);
	carry_out <= c1 or c2;
end flow;