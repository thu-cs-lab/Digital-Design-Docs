library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity initial_reg is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           d     : in  STD_LOGIC;
           q     : out STD_LOGIC);
end initial_reg;

architecture behavior of initial_reg is
signal r : STD_LOGIC := '0';
begin
  -- sequential
  process(clock)
  begin
    if rising_edge(clock) then
      if reset='1' then
        r <= '0';
      else
        r <= d;
      end if;
    end if;
  end process;

  -- combinatorial
  q <= r;
end behavior;