library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity add2 is
    Port ( a : in  STD_LOGIC_VECTOR (1 downto 0);
           b : in  STD_LOGIC_VECTOR (1 downto 0);
           c : out STD_LOGIC_VECTOR (1 downto 0));
end add2;

architecture behavior of add2 is
begin
  c <= a + b;
end behavior;