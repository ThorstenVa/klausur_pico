library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pb_pwm is
  port (clk, reset  : in std_logic;
        pwm_in      : in std_logic_vector(9 downto 0);
        pwm_out     : out std_logic;
        pwm_en      : in std_logic);
end pb_pwm;

architecture behaviour of pb_pwm is
  signal s_counter : std_logic_vector(9 downto 0);
begin

  process (clk, reset)
  begin
    if reset = '1' then
      s_counter <= (others => '0');
      pwm_out <= '0';
    elsif clk'event and clk = '1' then
      pwm_out <= '0';
      if pwm_en = '1' then
		  s_counter <= s_counter + 1;
        if s_counter <= pwm_in then
          pwm_out <= '1';
        else
          pwm_out <= '0';
        end if;
      end if;
    end if;
  end process;
  
 end behaviour;