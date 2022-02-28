library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ###############################################################################################
-- ######################## REGISTER FILE DESCRIPTION ############################################
-- ###############################################################################################

entity regfile is
    Generic (
        STACKADDR : std_logic_vector(31 downto 0)
    );
    Port (
        clk                 : in std_logic;
        nrst                : in std_logic;
        r1_addr, r2_addr    : in std_logic_vector(7 downto 0);
        r1_data, r2_data    : out std_logic_vector(31 downto 0);

        wr1_addr             : in std_logic_vector(7 downto 0);
        wr1_data             : in std_logic_vector(31 downto 0);
        wr1_en               : in std_Logic;

        wr2_addr             : in std_logic_vector(7 downto 0);
        wr2_data             : in std_logic_vector(31 downto 0);
        wr2_en               : in std_Logic
    );
end regfile;

architecture behave of regfile is
    type regfile_t is array(0 to 255) of std_logic_vector(31 downto 0);
    signal regfile_dat : regfile_t;
begin
    -- register file has asynchronous read
    r1_data <= regfile_dat(to_integer(unsigned(r1_addr)));
    r2_data <= regfile_dat(to_integer(unsigned(r2_addr)));

    process(clk)
    begin
        if rising_edge(clk) then
            if wr1_en = '1' then
                regfile_dat(to_integer(unsigned(wr1_addr))) <= wr1_data;
            end if;
            if wr2_en = '1' then
                regfile_dat(to_integer(unsigned(wr2_addr))) <= wr2_data;
            end if;
            regfile_dat(0) <= (others => '0');
            
            if nrst = '0' then
                for I in 0 to 31 loop
                    regfile_dat(I) <= (others => '0');
                end loop;
                regfile_dat(2) <= STACKADDR;
            end if;
        end if;
    end process;
end behave;
