library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
    
entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component datapath is
   port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        r1_load: in std_logic;
        r2_load: in std_logic;
        r2_sel: in std_logic;
        r3_load: in std_logic;
        r4_load: in std_logic;
        r5_load: in std_logic;
        r5_sel: in std_logic;
        r6_load: in std_logic;
        r6_sel: in std_logic;
        write_sel: in std_logic;
        pix_is_zero: out std_logic;
        less_than_pix: out std_logic;
        o_address : out std_logic_vector(15 downto 0);
        i_address : in std_logic_vector(15 downto 0);
        o_data : out std_logic_vector (7 downto 0)        
    );
end component;
signal r1_load: std_logic;
signal r2_load: std_logic;
signal r2_sel: std_logic;
signal r3_load: std_logic;
signal r4_load: std_logic;
signal r5_load: std_logic;
signal r5_sel: std_logic;
signal r6_load: std_logic;
signal r6_sel: std_logic;
signal write_sel: std_logic;
signal pix_is_zero: std_logic;
signal less_than_pix: std_logic;
signal reset_sig: std_logic;
signal i_address : std_logic_vector(15 downto 0);
type S is (INIT,RESET,WAIT_START,ENABLE_READ,READ_FIRST,READ_SECOND,MOVE_TO_FIRST_PIX,
READ_LOOP,END_READ_0,END_READ_1,WL_0,WL_1,WL_2,WL_3,DONE);

signal nextState,currentState: S; 

begin    
    DATAPATH0: datapath port map(
        i_clk=>i_clk, 
        i_rst=>reset_sig, 
        i_data=>i_data,
        r1_load=>r1_load, 
        r2_load=>r2_load, 
        r2_sel=>r2_sel,
        r3_load=>r3_load, 
        r4_load=>r4_load, 
        r5_load=>r5_load, 
        r5_sel=>r5_sel, 
        r6_load=>r6_load, 
        r6_sel=>r6_sel, 
        write_sel=>write_sel, 
        pix_is_zero=>pix_is_zero, 
        less_than_pix=>less_than_pix,
        o_address=>o_address,
        i_address=>i_address,
        o_data=>o_data
    );
                           
    state_reg: process(i_clk, i_rst)
    begin
        if i_rst='1' then
          currentState <= RESET;
        elsif rising_edge(i_clk) then
          currentState <= nextState;
        end if;
     end process;
                     
    lambda: process(currentState,i_rst,i_start,less_than_pix,pix_is_zero)
    begin 
        nextState<=currentState;
        case currentState is
            when INIT=>
                nextState<=INIT;
            when RESET=>
                if i_rst='0' then
                    nextState <= WAIT_START;
                end if;
            when WAIT_START=>
                if i_start='1' then
                    nextState <= ENABLE_READ;
                end if;
            when ENABLE_READ=>
                nextState<=READ_FIRST;
            when READ_FIRST=>
                if pix_is_zero='0' then
                    nextState <= READ_SECOND;
                else
                    nextState <= DONE;
                end if;
            when READ_SECOND=>
                if pix_is_zero='0' then
                    nextState <= MOVE_TO_FIRST_PIX;
                else
                    nextState <= DONE;
                end if;
            when MOVE_TO_FIRST_PIX=>
                nextState<=READ_LOOP;
            when READ_LOOP=>
                if less_than_pix='0' then
                    nextState <= END_READ_0;
                end if;
            when END_READ_0=>
                nextState<=END_READ_1;
            when END_READ_1=>
                nextState<=WL_0;
            when WL_0=>
                nextState <= WL_1;
            when WL_1=>
                nextState<=WL_2;
            when WL_2=>
                if less_than_pix='1' then
                    nextState <= WL_3;
                elsif less_than_pix='0' then
                    nextState <= DONE;
                end if;
            when WL_3=>
                nextState<=WL_0;
            when DONE=>
                if i_start='1' then
                    nextState <= WAIT_START;
                end if;
                          
        end case;
    end process;
    
    lambda2: process(currentState,i_rst)
    begin
        reset_sig<=i_rst;
        r1_load<='0';
        r2_load<='0';
        r3_load<='0';
        r4_load<='0';
        r5_load<='0';
        r6_load<='0';
        r2_sel<='0';
        r5_sel<='0';
        r6_sel<='0';
        write_sel<='0';
        o_en<='0';
        o_we<='0';
        o_done<='0';
        i_address<="0000000000000000";
        
        
        case currentState is
            when INIT =>
            when RESET =>
            when WAIT_START =>
            when ENABLE_READ =>
                o_en<='1';
                r2_sel<='1';
                r2_load<='1';
            when READ_FIRST =>
                o_en<='1';
                r2_sel<='1';
                r3_load<='1';
                r2_load<='1';
            when READ_SECOND =>
                o_en<='1';
                r2_load<='1';
                r2_sel<='1';
                r4_load<='1';
            when MOVE_TO_FIRST_PIX =>
                o_en<='1';
                r1_load<='1';
                r2_sel<='1';
                r2_load<='1';
            when READ_LOOP =>
                o_en<='1';
                r1_load<='1';
                r2_sel<='1';
                r2_load<='1';
                r5_sel<='1';
                r5_load<='1';
                r6_sel<='1';
                r6_load<='1';
            when END_READ_0 =>
                --o_en<='1';
                r2_sel<='1';
                i_address<="0000000000000010";
                r2_sel<='0';
                r2_load<='1';
                r1_load<='1';
                r5_sel<='1';
                r5_load<='1';
                r6_sel<='1';
                r6_load<='1';
            when END_READ_1 =>               
                r5_sel<='1';
                r2_sel<='1';
                r5_load<='1';
                r6_sel<='1';
                r6_load<='1';
                o_en<='1';
            when WL_0 =>
                --Reads data
                o_en<='1';
                r2_sel<='1';
                r1_load<='1';
                --o_we<='1';
            when WL_1 =>
                -- Set address to write address
                write_sel<='1';
                r2_sel<='1';
                o_en<='1';
            when WL_2 =>
                -- Writes data
                -- Adds 1 to address
                write_sel<='1';
                r2_sel<='1';
                o_en<='1';
                o_we<='1';
                r2_load<='1';
            when WL_3 =>
                o_en<='1';
                r2_sel<='1';
            when DONE =>
                o_done<='1';
                reset_sig<='1';
        end case;
    end process;

end Behavioral;

----------------------------------------------------------------------------------
-- Datapath
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity datapath is
   port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        r1_load: in std_logic;
        r2_load: in std_logic;
        r2_sel: in std_logic;
        r3_load: in std_logic;
        r4_load: in std_logic;
        r5_load: in std_logic;
        r5_sel: in std_logic;
        r6_load: in std_logic;
        r6_sel: in std_logic;
        write_sel: in std_logic;
        pix_is_zero: out std_logic;
        less_than_pix: out std_logic;
        o_address : out std_logic_vector(15 downto 0);
        i_address : in std_logic_vector(15 downto 0);
        o_data : out std_logic_vector (7 downto 0)        
    );
end datapath;

architecture Behavioral of datapath is
signal o_r1: std_logic_vector(7 downto 0);
signal o_r2: std_logic_vector(15 downto 0);
signal o_r3: std_logic_vector(7 downto 0);
signal o_r4: std_logic_vector(7 downto 0);
signal o_r5: std_logic_vector(7 downto 0);
signal o_r6: std_logic_vector(7 downto 0);
signal mux2_r2: std_logic_vector(15 downto 0);
signal mux5_r5: std_logic_vector(7 downto 0);
signal mux6_r6: std_logic_vector(7 downto 0);
signal pro4_sum4: std_logic_vector(15 downto 0);
signal sum4_greater4: std_logic_vector(15 downto 0);
signal sum5: std_logic_vector(15 downto 0);
signal sum2_mux2: std_logic_vector(15 downto 0);
signal mux5: std_logic_vector(7 downto 0);
signal mux6: std_logic_vector(7 downto 0);
signal greater5,lesser6: std_logic;
signal greater: std_logic;
signal delta_value,sub2: std_logic_vector(7 downto 0);
signal temp_pixel: std_logic_vector(15 downto 0);

signal shift_level: std_logic_vector(3 downto 0);       

begin

    r1: process(i_clk, i_rst)
    begin
        if i_rst='1' then
          o_r1 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r1_load='1') then
                o_r1 <= i_data;
            end if;
        end if;
    end process;
    
    sum2_mux2 <= o_r2 + "0000000000000001";
    
    with r2_sel select mux2_r2 <= 
        i_address when '0',
        sum2_mux2 when '1',
        "XXXXXXXXXXXXXXXX" when others;
        
    
    r2: process(i_clk, i_rst)
    begin
        if i_rst='1' then
          o_r2 <= "0000000000000000";
        elsif rising_edge(i_clk) then
            if(r2_load='1') then
                o_r2 <= mux2_r2;
            end if;
        end if;
     end process;
     
    r3: process(i_clk, i_rst)
    begin
        if i_rst='1' then
          o_r3 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r3_load='1') then
                o_r3 <= i_data;
            end if;
        end if;
    end process;
     
    r4: process(i_clk, i_rst)
    begin
        if i_rst='1' then
          o_r4 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r4_load='1') then
                o_r4 <= i_data;
            end if;
        end if;
    end process;
     
    pro4_sum4<=o_r3*o_r4;
    sum4_greater4<= pro4_sum4 + "0000000000000010";
    less_than_pix <= '1' when (sum4_greater4>mux2_r2) else '0';
    pix_is_zero<= '1' when (i_data="00000000") else '0';
    
    sum5<=pro4_sum4+o_r2;
    
    with write_sel select o_address <= 
        sum5 when '1',
        o_r2 when '0',
        "XXXXXXXXXXXXXXXX" when others;
    
    greater5<='1' when (o_r5>o_r1) else '0';

    with greater5 select mux5 <= 
        o_r5 when '0',
        o_r1  when '1',
        "XXXXXXXX" when others;
            
    with r5_sel select mux5_r5 <= 
        "11111111" when '0',
        mux5 when '1',
        "XXXXXXXX" when others;
        
    r5: process(i_clk, i_rst)
    begin
        if i_rst='1' then
          o_r5 <= "11111111";
        elsif rising_edge(i_clk) then
            if(r5_load='1') then
                o_r5 <= mux5_r5;
            end if;
        end if;
    end process;
    
    lesser6<='1' when (o_r6<o_r1) else '0';
    
    with lesser6 select mux6 <= 
        o_r6 when '0',
        o_r1  when '1',
        "XXXXXXXX" when others;

    with r6_sel select mux6_r6 <= 
        "00000000" when '0',
        mux6 when '1',
        "XXXXXXXX" when others;

     
    r6: process(i_clk, i_rst)
    begin
        if i_rst='1' then
          o_r6 <= "00000000";
        elsif rising_edge(i_clk) then
            if(r6_load='1') then
                o_r6 <= mux6_r6;
            end if;
        end if;
    end process;
     
     delta_value<=o_r6-o_r5;
     
     shift_level<= 
        "1000" when delta_value=0 else
        "0111" when delta_value>=1 and delta_value<=2 else
        "0110" when delta_value>=3 and delta_value<=6 else
        "0101" when delta_value>=7 and delta_value<=14 else
        "0100" when delta_value>=15 and delta_value<=30 else
        "0011" when delta_value>=31 and delta_value<=62 else
        "0010" when delta_value>=63 and delta_value<=126 else
        "0001" when delta_value>=127 and delta_value<=254 else
        "0000" when delta_value=255 else
        "XXXX";
         
     sub2<=o_r1-o_r5;
     greater<='1' when (temp_pixel>"0000000011111111") else '0';

     with shift_level select temp_pixel <=                           
        "00000000"&sub2 when "0000",
        "0000000"&sub2&"0" when "0001",
        "000000"&sub2&"00" when "0010",
        "00000"&sub2&"000" when "0011",
        "0000"&sub2&"0000" when "0100",
        "000"&sub2&"00000" when "0101",
        "00"&sub2&"000000" when "0110",
        "0"&sub2&"0000000" when "0111",
        sub2&"00000000" when "1000",        
        "XXXXXXXXXXXXXXXX" when others;

    with greater select o_data <= 
        temp_pixel(7 downto 0) when '0',
        "11111111" when '1',
        "XXXXXXXX" when others;
        
end Behavioral;
