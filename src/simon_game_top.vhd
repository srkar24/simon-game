library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity simon_game_top is
    generic ( seed : std_logic_vector(7 downto 0) := b"1001_0110");
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (3 downto 0);
           led : out STD_LOGIC_VECTOR (3 downto 0);
           led_r : out STD_LOGIC;
           led_g : out STD_LOGIC;
           led_b : out STD_LOGIC);
end simon_game_top;

architecture Behavioral of simon_game_top is

-- Default values specified for constants is important
constant ADDR_WIDTH : integer := 4;
constant DATA_WIDTH : integer := 4;
constant MAX_LEVEL : integer := 2**ADDR_WIDTH; --max level / values we can store in the main array
constant INPUT_FREQ : integer := 125_000_000;

--Default values specified for signals - doesn't matter
signal rst : std_logic;
signal btn_db : std_logic_vector(3 downto 0);
signal btn_pulse : std_logic_vector(3 downto 0);
signal rgb_reg : std_logic_vector(2 downto 0); -- To control the rgb leds
signal pattern : std_logic_vector(DATA_WIDTH-1 downto 0);
signal level : integer := 0; -- This signal will be our index for main_array_reg, giving default value of 0, it doesn't matter
signal led_reg : std_logic_vector(3 downto 0); -- This signal will turn on the leds (0-3) to show the board pattern generation
signal mem_index : integer := 0; -- This signal will keep track of user input and score
signal disp_counter : integer := 0;
signal r_data_reg : std_logic_vector(3 downto 0); -- Reads the pattern data / data register

type state_type is (IDLE, SEQ_GEN, SEQ_DISP, USER_INP, CHECK_INP, CORR_INP, INCORR_INP, GAME_OVER);
signal current_state : state_type;
-- If user won, then flash green led for number of times the user won
-- If user lost, then flash red led for number of times the user lost

type mem_2d_type is array (0 to 2**ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
signal main_array_reg : mem_2d_type; -- main array that stores the generated sequences of board
signal user_array_reg : mem_2d_type; -- user arrau to store user input 

component debounce is
    generic
    (
        clk_freq    : integer := 125_000_000;
        stable_time : integer := 10
        );
    port
    (
        clk    : in std_logic;
        rst    : in std_logic;
        button : in std_logic;
        result : out std_logic);
end component debounce;

component single_pulse_detector is
    Generic(detect_type: std_logic_vector(1 downto 0) := "00");
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           input_signal : in  STD_LOGIC;
           output_pulse : out  STD_LOGIC);
end component single_pulse_detector;

component rand_gen is
    generic(
        input_size: integer := 8;
        output_size: integer := 4
    );
    port
    (
        clk, rst : in std_logic;
        seed     : in std_logic_vector(input_size-1 downto 0);
        output   : out std_logic_vector (output_size-1 downto 0)
    );
end component rand_gen;

begin

rst <= btn(0) AND btn(3);

rand_gen_inst: rand_gen generic map(output_size=>DATA_WIDTH)
                        port map(clk=>clk, rst=>rst, seed=>seed, output=>pattern);

debounce_inst_0: debounce port map(clk=>clk, rst=>rst, button=>btn(0), result=>btn_db(0));
debounce_inst_1: debounce port map(clk=>clk, rst=>rst, button=>btn(1), result=>btn_db(1));
debounce_inst_2: debounce port map(clk=>clk, rst=>rst, button=>btn(2), result=>btn_db(2));
debounce_inst_3: debounce port map(clk=>clk, rst=>rst, button=>btn(3), result=>btn_db(3));

pulse_inst_0: single_pulse_detector generic map(detect_type=>"01")
                                    port map(clk=>clk, rst=>rst, input_signal=>btn_db(0) , output_pulse=>btn_pulse(0));
pulse_inst_1: single_pulse_detector generic map(detect_type=>"01")
                                    port map(clk=>clk, rst=>rst, input_signal=>btn_db(1) , output_pulse=>btn_pulse(1));
pulse_inst_2: single_pulse_detector generic map(detect_type=>"01")
                                    port map(clk=>clk, rst=>rst, input_signal=>btn_db(2) , output_pulse=>btn_pulse(2));                                    
pulse_inst_3: single_pulse_detector generic map(detect_type=>"01")
                                    port map(clk=>clk, rst=>rst, input_signal=>btn_db(3) , output_pulse=>btn_pulse(3));                                    

process(clk, rst)
begin
    if (rst = '1') then
        -- reset everything
        current_state <= IDLE;
        rgb_reg <= (others => '0'); --putting this under a clock to make rgb_reg a register, else it won't be a register
        level <= 0;
        main_array_reg <= (others=>(others=>'0')); -- since it's a 2d array
        user_array_reg <= (others=>(others=>'0'));
        led_reg <= (others=> '0');
        mem_index <= 0; -- Always recommended to have registers mentioned part of reset
        disp_counter <= 0;
        r_data_reg <= (others=>'0');
        --------------------------------------
    elsif rising_edge(clk) then
    
        -- Sequence generation
        if current_state = IDLE then
            current_state <= SEQ_GEN;
            -----------------------------------
        elsif current_state = SEQ_GEN then
            
            main_array_reg(level) <= pattern; -- each time we record a pattern, it would be a new level
            if level < MAX_LEVEL - 1 then
                level <= level + 1; -- increment the level for next pattern generation storing in main_array_reg
            else
                level <= MAX_LEVEL - 1;
            end if;
            current_state <= SEQ_DISP;
            ----------------------------------
        elsif current_state = SEQ_DISP then
          
            rgb_reg <= (others=>'1');
            
            if disp_counter = 0 then
                r_data_reg <= main_array_reg(mem_index); -- this will turn on the led to show the pattern generated by board which user needs to follow
                mem_index <= mem_index + 1;
                led_reg <= (others=>'0'); -- turning leds off
            elsif disp_counter = 1 then -- updates led_reg in next clock cycle
                led_reg <= r_data_reg; -- turning leds on in this next clock cycle for half of 125_000_000
            elsif disp_counter = (INPUT_FREQ/2)-1 then -- creates delay for human eye to see 
                led_reg <= (others=>'0'); -- turning leds off for next/last half of 125_000_000
            elsif disp_counter = INPUT_FREQ-1 then -- if we get to max value of freq and resets back to 0
                -- we come to this condition when we have iterated through all the elements in the array of seq_gen 
                if mem_index = level then -- if user input for sequence  
                    user_array_reg <= (others=>(others=>'0')); -- to clear user array every time we go to user_input state, we need to have clear/clean state user array 
                    current_state <= USER_INP; -- current state to change to user input
                    led_reg <= (others=>'0');
                    mem_index <= 0; -- reset the mem_index to use it again for pattern generation
                end if;
            end if;
            
            if disp_counter < INPUT_FREQ-1 then -- counter counts till INPUT_FREQ = 125_000_000 Mhz and goes to next LED
                disp_counter <= disp_counter + 1;
            else 
                disp_counter <= 0; 
            end if;       
            -------------------------------------
        elsif current_state = USER_INP then
            
            rgb_reg <= "100"; -- turn on blue led indicating you're ready for user input
            
            if mem_index = level then -- this condition will help with moving on to the next state (check_inp)
                current_state <= CHECK_INP;
                led_reg <= (others=>'0');
                mem_index <= 0;
            end if;    
            
            if btn_pulse(0) = '1' then
                led_reg <= "0001"; -- shows the user the btn pressed (which is 1st btn)
                user_array_reg(mem_index) <= "0001"; -- user array stores this value in the index based on btn pressed
                mem_index <= mem_index +1;
            elsif btn_pulse(1) = '1' then
                led_reg <= "0010";
                user_array_reg(mem_index) <= "0010";
                mem_index <= mem_index +1;
            elsif btn_pulse(2) = '1' then
                led_reg <= "0100";
                user_array_reg(mem_index) <= "0100";
                mem_index <= mem_index +1;
            elsif btn_pulse(3) = '1' then
                led_reg <= "1000";
                user_array_reg(mem_index) <= "1000";
                mem_index <= mem_index +1;
            end if;
            ------------------------------------
        elsif current_state = CHECK_INP then
            
            -- note thay we have already set our mem_index <= 0; in user_inp state so we can directly jump to next steps here
            if main_array_reg(mem_index) /= user_array_reg(mem_index) then -- if user didn't input the correct pattern as generated by board
                current_state <= INCORR_INP;
                mem_index <= 0;
                disp_counter <= 0; -- resetting display counters to blink the leds
            else -- user_inp is correct then
                if mem_index = level - 1 then
                    current_state <= CORR_INP;
                    mem_index <= 0;
                    disp_counter <= 0;
                else
                    mem_index <= mem_index + 1; 
                end if;
            end if;
            -------------------------------------
        elsif current_state = CORR_INP then
            
            rgb_reg <= "010"; -- turn on the green rgb to confirm the correct inp was entered
            -- need to use a delay to stay here for a while to show the green rgb for user's eye using a counter (disp_counter)
            if disp_counter < INPUT_FREQ-1 then -- counter counts till INPUT_FREQ = 125_000_000 Mhz and goes to next LED
                disp_counter <= disp_counter + 1;
            else 
                disp_counter <= 0; 
            end if;    
            
            -- once counter reaches max freq, then go to next state
            if disp_counter = INPUT_FREQ-1 then
                current_state <= SEQ_GEN;
            end if;
            --------------------------------------
        elsif current_state = INCORR_INP then
             
             -- this is to blink the number of score user won
             if disp_counter = 0 then
                rgb_reg <= "001"; -- turn on red rgb to show incorrect inp by user
                mem_index <= mem_index + 1;
             elsif disp_counter = (INPUT_FREQ/2)-1 then
                rgb_reg <= "000"; -- turn off the red rgb halfway
             elsif disp_counter = INPUT_FREQ-1 then -- end of the counter
                if mem_index = level - 1 then -- check if you're at mem level
                    current_state <= GAME_OVER;
                    mem_index <= 0;
                end if;   
             end if;
             
             if disp_counter < INPUT_FREQ-1 then -- display counter is already 0 here. It's coming from CHECK_INP state as 0. Counter counts till INPUT_FREQ = 125_000_000 Mhz and goes to next LED
                disp_counter <= disp_counter + 1;
            else 
                disp_counter <= 0; 
            end if;  
        
            --------------------------------------
        elsif current_state = GAME_OVER then
            
            current_state <= GAME_OVER;
            --------------------------------------
        else
        
            current_state <= GAME_OVER; 
            ---------------------------------------
        end if;
    end if; 
end process;

led <= led_reg;
led_r <= rgb_reg(0);
led_g <= rgb_reg(1);
led_b <= rgb_reg(2);

end Behavioral;