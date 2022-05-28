library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity timer is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
	         timer : out STD_LOGIC_VECTOR (3 downto 0));
end timer;

architecture behavior of timer is
signal timer_reg : STD_LOGIC_VECTOR (3 downto 0);
signal counter_reg : STD_LOGIC_VECTOR (19 downto 0);
begin
  -- sequential
  process(clock, reset)
  begin
    if clock='1' and clock'event then
      if reset='1' then
        timer_reg <= X"0";
        counter_reg <= X"00000";
      else
        -- 999999 = 0xF423F
        if counter_reg=X"F423F" then
          timer_reg <= timer_reg + X"1";
          counter_reg <= X"00000";
        else
          counter_reg <= counter_reg + X"00001";
        end if;
      end if;
    end if;
  end process;

  -- combinatorial
  timer <= timer_reg;
end behavior;