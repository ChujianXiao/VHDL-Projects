library IEEE;
use IEEE.std_logic_1164.all;

entity HA is
	port(A,B: in std_logic;          
	sum,carryout: out std_logic); 
end HA;

architecture flow of HA is
begin
	sum<= A xor B;
	carryout<=A and B;
end flow;