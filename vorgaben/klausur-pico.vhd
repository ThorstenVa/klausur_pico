library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity klausur_pico is
  Port ( a, b    : in  std_logic;
         led     : out std_logic;
         reset   : in std_logic;			
         clk     : in  std_logic);
end klausur_pico;

architecture behavioral of klausur_pico is

  component kcpsm3
    port (address       : out std_logic_vector(9 downto 0);
          instruction   : in std_logic_vector(17 downto 0);
          port_id       : out std_logic_vector(7 downto 0);
          write_strobe  : out std_logic;
          out_port      : out std_logic_vector(7 downto 0);
          read_strobe   : out std_logic;
          in_port       : in std_logic_vector(7 downto 0);
          interrupt     : in std_logic;
          interrupt_ack : out std_logic;
          reset         : in std_logic;
          clk           : in std_logic);
  end component;
  
  component programm
     port (address     : in std_logic_vector(9 downto 0);
           instruction : out std_logic_vector(17 downto 0);
           clk         : in std_logic);
  end component;
    
  component pb_encoder 
  port (clk, reset  : in std_logic;
        a, b        : in std_logic;
        encoder_out : out std_logic_vector(9 downto 0);
        encoder_en  : in std_logic;
        int_en      : in std_logic;
        int_out     : out std_logic;
        int_ack     : in  std_logic);
  end component;
  
  component pb_pwm
    port (clk, reset  : in std_logic;
          pwm_in      : in std_logic_vector(9 downto 0);
          pwm_out     : out std_logic;
          pwm_en      : in std_logic);
  end component;
  
  -- Signale zwischen PicoBlaze und Umwelt

  signal address              : std_logic_vector(9 downto 0);
  signal instruction          : std_logic_vector(17 downto 0);
  signal port_id_signal       : std_logic_vector(7 downto 0);
  signal out_port_signal      : std_logic_vector(7 downto 0);
  signal in_port_signal       : std_logic_vector(7 downto 0);
  signal write_strobe_signal  : std_logic;
  signal read_strobe_signal   : std_logic;
  signal interrupt_signal     : std_logic;
  signal interrupt_ack_signal : std_logic;

     
  -- Signale des Drehenkoders
	  
  signal encoder_out_signal : std_logic_vector(9 downto 0);
  signal encoder_en_signal : std_logic;
  signal int_en_signal : std_logic;
	  

  -- Signale der PWM Einheit
	  
  signal pwm_en_signal : std_logic;
  signal pwm_in_signal : std_logic_vector(9 downto 0);

  signal test : std_logic_vector(9 downto 0);  
  
  -- Hier fangen Ihre Deklarationen an
  
  signal s_reg0, s_reg1, s_reg2 : std_logic_vector(7 downto 0);
    
 
begin

  i_processor : kcpsm3 port map (address => address,
                              instruction => instruction,   
                              port_id => port_id_signal,
                              write_strobe => write_strobe_signal,
                              out_port => out_port_signal,
                              read_strobe => read_strobe_signal,
                              in_port => in_port_signal,
                              interrupt => interrupt_signal,
                              interrupt_ack => interrupt_ack_signal,
                              reset => reset,
										clk => clk);

  i_program: programm port map( address => address,
                          instruction => instruction,
                          clk => clk);
								  
  i_encoder: pb_encoder port map(clk => clk,
                          reset => reset,
                          a => a,
								  b => b,
								  encoder_out => encoder_out_signal,
								  encoder_en  => encoder_en_signal,
								  int_en      => int_en_signal,
								  int_out     => interrupt_signal,
								  int_ack     => interrupt_ack_signal);	

  i_pwm : pb_pwm port map (clk => clk, 
                           reset => reset,
 									pwm_in => pwm_in_signal,
                           pwm_out => led,
                           pwm_en => pwm_en_signal);
 
 
 
   -- Loeschen Sie folgende Testverdrahtung und ersetze Sie ihn durch Ihre Implementierung der Register
	
	
	-- Schreiben
	process(clk)
	begin
		if clk'event and clk = '1' then
			if write_strobe_signal = '1' then
			
				-- schreiben in PWm einheit
				if port_id_signal = x"00" then 
					pwm_in_signal(7 downto 0) <= out_port_signal;
				elsif port_id_signal = x"01" then
					pwm_in_signal(9 downto 8) <= out_port_signal(1 downto 0);
				
				-- enable signale schreiben				
				elsif port_id_signal = x"02" then 
					pwm_en_signal 		<= out_port_signal(2);
					int_en_signal 		<= out_port_signal(1);
					encoder_en_signal <= out_port_signal(0);		
				end if;
			end if;	
		end if;
	end process;


	-- lesen
	process(port_id_signal)
	begin 
		if clk'event and clk = '1' then
			
			if port_id_signal = x"00" then
				in_port_signal <= encoder_out_signal(7 downto 0);
				
			elsif port_id_signal = x"01" then
				in_port_signal <= "000000" & encoder_out_signal(9 downto 8);
				
			elsif port_id_signal = x"02" then
				in_port_signal <= "00000" & pwm_en_signal & int_en_signal & encoder_en_signal;
			end if;
			
		end if;
	end process;
	
	

  
end behavioral;
