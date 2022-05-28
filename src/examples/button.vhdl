library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity button is
    Port ( button : in  STD_LOGIC;
           light  : out STD_LOGIC);
end button;

architecture behavior of button is
signal light_reg : STD_LOGIC;
begin
  -- sequential
  process(button)
  begin
    if button='1' and button'event then
      light_reg <= not light_reg;
    end if;
  end process;

  -- combinatorial
  light <= light_reg;
end behavior;