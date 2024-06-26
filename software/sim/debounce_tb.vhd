library ieee;
use ieee.std_logic_1164.all;

entity debounce_tb is
end debounce_tb;

architecture Behavioral of debounce_tb is

    component debounce is
        generic (
            clk_freq : integer := 50_000_000; --system clock frequency in Hz
            stable_time : integer := 10); --time button must remain stable in ms
        port (
            clk : in std_logic; --input clock
            rst : in std_logic; --asynchronous active low reset
            button : in std_logic; --input signal to be debounced
            result : out std_logic); --debounced signal
    end component debounce;

    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '0';
    signal button_tb : std_logic := '0';
    signal result_tb : std_logic := '0';

    constant CP : time := 10 ns;

begin

    uut : debounce generic map(clk_freq => 500, stable_time => 5)
    port map(clk => clk_tb, rst => rst_tb, button => button_tb, result => result_tb);

    clk_gen : process
    begin
        clk_tb <= '1';
        wait for CP/2;
        clk_tb <= '0';
        wait for CP/2;
    end process;

    input_gen : process
    begin
        rst_tb <= '1';
        wait for CP;
        rst_tb <= '0';
        wait for 10 * CP;

        button_tb <= '1';
        wait for CP;
        button_tb <= '0';
        wait for 5 * CP;
        button_tb <= '1';
        wait for CP;
        button_tb <= '0';
        wait for 9 * CP;
        button_tb <= '0';
        wait for 6 * CP;
        button_tb <= '1';
        wait for 20 * CP;
        button_tb <= '0';
    end process;

end Behavioral;