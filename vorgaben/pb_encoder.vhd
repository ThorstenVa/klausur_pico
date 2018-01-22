library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pb_encoder is
  port (clk, reset  : in std_logic;
        a, b        : in std_logic;
        encoder_out : out std_logic_vector(9 downto 0);
        encoder_en  : in std_logic;
        int_en      : in std_logic;
        int_out     : out std_logic;
        int_ack     : in  std_logic);
end pb_encoder;

architecture behaviour of pb_encoder is
  signal s_counter : std_logic_vector(9 downto 0);
  signal rotary_in : std_logic_vector(1 downto 0);
  signal delayed_rotary_q1, rotary_q1, rotary_q2 : std_logic;
  signal rotary_event, rotary_left : std_logic;
begin

  filter: process(clk)
  begin
    if clk'event and clk='1' then
      rotary_in <= b & a;
      case rotary_in is
        when "00" =>
          rotary_q1 <= '0';
          rotary_q2 <= rotary_q2;
        when "01" =>
          rotary_q1 <= rotary_q1;
          rotary_q2 <= '0';
        when "10" =>
          rotary_q1 <= rotary_q1;
          rotary_q2 <= '1';
        when "11" =>
          rotary_q1 <= '1';
          rotary_q2 <= rotary_q2;
        when others =>
          rotary_q1 <= rotary_q1;
          rotary_q2 <= rotary_q2;
      end case;
    end if;   
  end process;

  direction: process(clk)
  begin
    if clk'event and clk='1' then
      delayed_rotary_q1 <= rotary_q1;
      if rotary_q1='1' and delayed_rotary_q1='0' then
        rotary_event <= '1';
        rotary_left <= rotary_q2;
       else
        rotary_event <= '0';
        rotary_left <= rotary_left;
      end if;
    end if;
  end process direction;

  counter : process (clk, reset)
  begin
    if reset = '1' then
      int_out <= '0';
      s_counter <= (others => '0');
    elsif clk'event and clk = '1' then
      if int_ack = '1' then
        int_out <= '0';
      end if;
      if encoder_en = '1' then
        if rotary_event = '1' then
          if rotary_left = '1' then
            s_counter <= s_counter + 1;
          else
            s_counter <= s_counter - 1;
          end if;
          if int_en = '1' then
            int_out <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;
  
  encoder_out <= s_counter;
end behaviour;
