library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use std.env.stop;

entity cpu_tb is
end cpu_tb;

architecture Behave of cpu_tb is
    signal clk, nrst : std_logic := '0';
    signal mem_addr : std_logic_vector(31 downto 0);
    signal mem_wdata, mem_rdata : std_logic_vector(31 downto 0);
    signal mem_wen : std_logic;
    signal mem_strb, mem_ack : std_logic;

    type ram_t is array(0 to 4095) of std_logic_vector(31 downto 0);
    signal ram_data : ram_t;
    file file_INPUT : text;

begin
    clk <= not clk after 5 ns;

    process
        variable v_ILINE : line;
        variable v_INST : std_logic_vector(63 downto 0);
        variable i : integer;
    begin        
        nrst <= '0';
        file_open(file_INPUT, "hello_world.hex", read_mode);
 
        i := 0;
        -- read file
        while not endfile(file_INPUT) loop
            -- Daten aus der Textdatei lesen und vorbereiten.
            readline(file_INPUT, v_ILINE);
            hread(v_ILINE, v_INST);
            ram_data(i) <= v_INST(63 downto 32);
            i := i + 1;
            ram_data(i) <= v_INST(31 downto 0);
            i := i + 1;
            wait for 1 ns;
        end loop;
        file_close(file_INPUT);
        wait for 50 ns;
        nrst <= '1';
        wait for 2000 ns;
        stop;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            mem_ack <= '0';

            if mem_strb = '1' then
                if mem_wen = '1' then
                    ram_data(to_integer(unsigned(mem_addr(31 downto 3)))) <= mem_wdata;
                end if;
                -- report "Mem address: mem_addr=" & to_hstring(mem_addr);
                mem_rdata <= ram_data(to_integer(unsigned(mem_addr(31 downto 2))));
                mem_ack <= '1';
            end if;

            if nrst = '0' then
                mem_ack <= '0';
            end if;
        end if;
    end process;

    inst_cpu : entity work.cpu
    port map (
        clk => clk,
        nreset => nrst,
        mem_addr => mem_addr,
        mem_wdata => mem_wdata,
        mem_rdata => mem_rdata,
        mem_wen => mem_wen,
        mem_strb => mem_strb,
        mem_ack => mem_ack
    );

end Behave;
