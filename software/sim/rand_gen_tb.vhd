library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity rand_gen_tb is
    --  Port ( );
end rand_gen_tb;

architecture Behavioral of rand_gen_tb is

    component rand_gen is
        port (
            clk, rst : in std_logic;
            seed : in std_logic_vector(7 downto 0);
            output : out std_logic_vector (3 downto 0)
        );
    end component;

    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '0';
    signal seed_tb : std_logic_vector(7 downto 0) := (others => '0');
    signal output_tb : std_logic_vector(3 downto 0) := (others => '0');

    constant CP : time := 10 ns;

begin
    uut : rand_gen port map(clk => clk_tb, rst => rst_tb, seed => seed_tb, output => output_tb);

    process
    begin
        clk_tb <= '0';
        wait for CP/2;
        clk_tb <= '1';
        wait for CP/2;
    end process;

    process
    begin
        rst_tb <= '1';
        wait for CP;
        rst_tb <= '0';
        wait for CP * 2;

        seed_tb <= "00001111";
        wait for CP * 5;
        seed_tb <= "00001010";
        wait for CP * 5;
        seed_tb <= "00001110";
        wait for CP * 5;
        seed_tb <= "11000000";
        wait for CP * 5;
    end process;

end Behavioral;