library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rr_priority_encoder is
    Port ( request   : in  STD_LOGIC_VECTOR (3 downto 0);
           last_user : in  STD_LOGIC_VECTOR (1 downto 0);
           valid     : out STD_LOGIC;
           user      : out STD_LOGIC_VECTOR (1 downto 0));
end rr_priority_encoder;

architecture behavior of rr_priority_encoder is
begin
  process (request, last_user) begin
    -- default
    valid <= '0';
    user <= "00";

    -- naive way
    if last_user="11" then
      if request(0)='1' then
        valid <= '1';
        user <= "00";
      elsif request(1)='1' then
        valid <= '1';
        user <= "01";
      elsif request(2)='1' then
        valid <= '1';
        user <= "10";
      elsif request(3)='1' then
        valid <= '1';
        user <= "11";
      end if;
    elsif last_user="00" then
      if request(1)='1' then
        valid <= '1';
        user <= "01";
      elsif request(2)='1' then
        valid <= '1';
        user <= "10";
      elsif request(3)='1' then
        valid <= '1';
        user <= "11";
      elsif request(0)='1' then
        valid <= '1';
        user <= "00";
      end if;
    elsif last_user="01" then
      if request(2)='1' then
        valid <= '1';
        user <= "10";
      elsif request(3)='1' then
        valid <= '1';
        user <= "11";
      elsif request(0)='1' then
        valid <= '1';
        user <= "00";
      elsif request(1)='1' then
        valid <= '1';
        user <= "01";
      end if;
    elsif last_user="10" then
      if request(3)='1' then
        valid <= '1';
        user <= "11";
      elsif request(0)='1' then
        valid <= '1';
        user <= "00";
      elsif request(1)='1' then
        valid <= '1';
        user <= "01";
      elsif request(2)='1' then
        valid <= '1';
        user <= "10";
      end if;
    end if;
  end process;
end behavior;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rr_arbiter is
    Port ( clock   : in  STD_LOGIC;
           reset   : in  STD_LOGIC;
           request : in  STD_LOGIC_VECTOR (3 downto 0);
           valid   : out STD_LOGIC;
           user    : out STD_LOGIC_VECTOR (1 downto 0));
end rr_arbiter;

architecture behavior of rr_arbiter is
signal user_reg : STD_LOGIC_VECTOR (1 downto 0);
signal valid_reg : STD_LOGIC;
signal priority_encoder_valid_comb : STD_LOGIC;
signal priority_encoder_user_comb : STD_LOGIC_VECTOR (1 downto 0);
begin
  -- rr_priority_encoder
  rr_priority_encoder_component : entity work.rr_priority_encoder
    port map(
      request => request,
      last_user => user_reg,
      valid => priority_encoder_valid_comb,
      user => priority_encoder_user_comb
    );

  -- sequential
  process (clock, reset) begin
    if clock='1' and clock'event then
      if reset='1' then
        user_reg <= "00";
        valid_reg <= '0';
      else
        valid_reg <= priority_encoder_valid_comb;
        if valid_reg='0' and priority_encoder_valid_comb='1' then
          -- case 1: non valid -> valid
          user_reg <= priority_encoder_user_comb;
        elsif valid_reg='1' and priority_encoder_valid_comb='1' and request(conv_integer(user_reg))='1' then
          -- case 2: persist
        elsif valid_reg='1' and priority_encoder_valid_comb='1' and request(conv_integer(user_reg))='0' then
          -- case 3: next user
          user_reg <= priority_encoder_user_comb;
        end if;
      end if;
    end if;
  end process;

  -- combinatorial
  process (valid_reg, priority_encoder_valid_comb, request, user_reg, priority_encoder_user_comb) begin
    -- default
    user <= "00";

    if valid_reg='0' and priority_encoder_valid_comb='1' then
      -- case 1: non valid -> valid
      user <= priority_encoder_user_comb;
    elsif valid_reg='1' and priority_encoder_valid_comb='1' and request(conv_integer(user_reg))='1' then
      -- case 2: persist
    elsif valid_reg='1' and priority_encoder_valid_comb='1' and request(conv_integer(user_reg))='0' then
      -- case 3: next user
      user <= priority_encoder_user_comb;
    end if;

    valid <= priority_encoder_valid_comb;
  end process;
end behavior;