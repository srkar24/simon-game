library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity single_pulse_detector is
    Generic(detect_type: std_logic_vector(1 downto 0) := "01");
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           input_signal : in  STD_LOGIC;
           output_pulse : out  STD_LOGIC);
end single_pulse_detector;

architecture Behavioral of single_pulse_detector is
signal ff0: std_logic;
signal ff1: std_logic;
begin

process(clk, rst)
begin
    if rst = '1' then
        ff0 <= '0';
        ff1 <= '0';
    elsif rising_edge(clk) then
        ff0 <= input_signal;
        ff1 <= ff0;
    end if;
end process;
        
    with detect_type select output_pulse <=
                            not ff1 and ff0 when "00",
                            not ff0 and ff1 when "01",
                            ff0 xor ff1 when "10",
                            '0' when others;	

end Behavioral;