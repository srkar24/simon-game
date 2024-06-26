library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity simon_game_top_tb is
--  Port ( );
end simon_game_top_tb;

architecture Behavioral of simon_game_top_tb is

component simon_game_top is
    generic ( seed : std_logic_vector(7 downto 0) := b"1001_0110");
    Port ( clk : in std_logic;
           btn : in std_logic_vector (3 downto 0);
           led : out std_logic_vector (3 downto 0) := (others=>'0');
           led_r : out std_logic := '0';
           led_g : out std_logic := '0';
           led_b : out std_logic := '0');
end component simon_game_top;

    signal clk_tb : std_logic := '0';
    signal btn_tb : std_logic_vector (3 downto 0) := (others=>'0');
    signal led_tb : std_logic_vector (3 downto 0):= (others=>'0');
    signal led_r_tb, led_g_tb, led_b_tb : std_logic := '0';
    constant CP : time := 100 ms;

begin

    uut : simon_game_top generic map(seed => b"1001_0110")
                         port map(clk => clk_tb, btn => btn_tb, led => led_tb, led_r => led_r_tb, led_g => led_g_tb, led_b => led_b_tb);

    clk_gen : process
    begin
        clk_tb <= '1';
        wait for CP/2;
        clk_tb <= '0';
        wait for CP/2;
    end process;

    input_gen : process
    begin
 
        wait for 20*CP;
        
        -- Simulate correct input sequence
        btn_tb <= "1111";
        wait for 50*CP;
        btn_tb <= "0010";
        wait for 50*CP;
        btn_tb <= "0001";
        wait for 50*CP;
        btn_tb <= "1001";
        wait for 50*CP;
        btn_tb <= "1100";
        wait for 50*CP;  
        btn_tb <= "1010";
        wait for 50*CP;
        btn_tb <= "0101";
        wait for 50*CP;
        btn_tb <= "0110";
        wait for 50*CP;
        btn_tb <= "0011";
        wait for 50*CP;
        btn_tb <= "1110";
        wait for 50*CP;  
        wait;
    end process;

end Behavioral;