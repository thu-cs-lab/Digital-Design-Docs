library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity priority_encoder is
    Port ( request : in  STD_LOGIC_VECTOR (3 downto 0);
           valid   : out STD_LOGIC;
           user    : out STD_LOGIC_VECTOR (1 downto 0));
end priority_encoder;

architecture behavior of priority_encoder is
begin
  process (request) begin
    -- default
    valid <= '0';
    user <= "00";

    -- cases
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
  end process;
end behavior;