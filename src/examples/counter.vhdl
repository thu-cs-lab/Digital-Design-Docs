library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity debouncer is
    Port ( clock            : in  STD_LOGIC;
           reset            : in  STD_LOGIC;
           button           : in  STD_LOGIC;
           button_debounced : out STD_LOGIC);
end debouncer;

architecture behavior of debouncer is
signal last_button_reg : STD_LOGIC;
signal counter_reg : STD_LOGIC_VECTOR (15 downto 0);
signal button_debounced_reg : STD_LOGIC;
begin
  -- sequential
  process(clock, reset, button) begin
    if rising_edge(clock) then
      if reset='1' then
        last_button_reg <= '0';
        counter_reg <= X"0000";
        button_debounced_reg <= '0';
      else
        last_button_reg <= button;

        if button=last_button_reg then
          if counter_reg=10000 then
            button_debounced_reg <= last_button_reg;
          else
            counter_reg <= counter_reg + 1;
          end if;
        else
          counter_reg <= X"0000";
        end if;
      end if;
    end if;
  end process;

  -- combinatorial
  button_debounced <= button_debounced_reg;
end behavior;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter is
    Port ( clock            : in  STD_LOGIC;
           reset            : in  STD_LOGIC;
           button_debounced : in  STD_LOGIC;
           ones             : out STD_LOGIC_VECTOR (3 downto 0);
           tens             : out STD_LOGIC_VECTOR (3 downto 0));
end counter;

architecture behavior of counter is
signal ones_reg : STD_LOGIC_VECTOR (3 downto 0);
signal tens_reg : STD_LOGIC_VECTOR (3 downto 0);
signal button_debounced_reg : STD_LOGIC;
begin
  -- sequential
  process(clock, reset, button_debounced) begin
    if rising_edge(clock) then
      if reset='1' then
        ones_reg <= X"0";
        tens_reg <= X"0";
        button_debounced_reg <= '0';
      else
        button_debounced_reg <= button_debounced;

        if button_debounced='1' and button_debounced_reg='0' then
          if ones_reg=X"9" then
            ones_reg <= X"0";
            tens_reg <= tens_reg + 1;
          else
            ones_reg <= ones_reg + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  -- combinatorial
  ones <= ones_reg;
  tens <= tens_reg;
end behavior;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter_top is
    Port ( clock            : in  STD_LOGIC;
           reset            : in  STD_LOGIC;
           button           : in  STD_LOGIC;
           ones             : out STD_LOGIC_VECTOR (3 downto 0);
           tens             : out STD_LOGIC_VECTOR (3 downto 0));
end counter_top;

architecture behavior of counter_top is
signal button_debounced : STD_LOGIC;
begin
  -- debouncer
  debouncer_component : entity work.debouncer
    port map(
      clock => clock,
      reset => reset,
      button => button,
      button_debounced => button_debounced
    );

  -- counter
  counter_component : entity work.counter
    port map(
      clock => clock,
      reset => reset,
      button_debounced => button_debounced,
      ones => ones,
      tens => tens
    );
end behavior;