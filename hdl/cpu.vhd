library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- synthesis translate off
use std.env.stop;
-- synthesis translate on


-- ###############################################################################################
-- ####################### PROCESSOR DESCRIPTION #################################################
-- ###############################################################################################

entity cpu is
    Generic (
        STACKADDR : std_logic_vector(31 downto 0) := x"00008000"
    );
    Port (
        clk : in std_logic;
        nreset : in std_logic;
        mem_addr : out std_logic_vector(31 downto 0);
        mem_wdata : out std_logic_vector(31 downto 0);
        mem_wen : out std_logic;
        mem_rdata : in std_logic_vector(31 downto 0);
        mem_strb : out std_logic;
        mem_ack : in std_logic
    );
end cpu;

architecture Behave of cpu is
    signal pc, next_pc : std_logic_vector(31 downto 0) := (others => '0');

    signal instr : std_logic_vector(63 downto 0);
    signal opc : std_logic_vector(15 downto 0);
    signal reg0, reg1, reg2, reg3 : std_logic_vector(7 downto 0);
    signal immediate, ldst_addr : std_logic_vector(31 downto 0);

    -- regfile signals
    signal rf_r1a, rf_r2a, rf_wr1a, rf_wr2a : std_logic_vector(7 downto 0); -- port address
    signal rf_r1d, rf_r2d, rf_wr1d, rf_wr2d : std_logic_vector(31 downto 0); -- port data
    signal rf_wr1en, rf_wr2en : std_logic;
    signal tmp_mem_addr : std_logic_vector(31 downto 0);
    signal tmp_mem_wen, tmp_wr1en, tmp_wr2en : std_logic;

    -- state machine signals, one-hot encoded
    signal curr_state : std_logic_vector(5 downto 0) := "000001";
    constant ST_IF  : std_logic_vector(5 downto 0) := "000001";
    constant ST_ID  : std_logic_vector(5 downto 0) := "000010";
    constant ST_EX  : std_logic_vector(5 downto 0) := "000100";
    constant ST_MEM : std_logic_vector(5 downto 0) := "001000";
    constant ST_WB  : std_logic_vector(5 downto 0) := "010000";
    constant ST_HLT : std_logic_vector(5 downto 0) := "100000";
begin

    inst_regfile : entity work.regfile
    generic map (
        STACKADDR => x"00008000"
    )
    port map (
        clk => clk,
        nrst => nreset,
        r1_addr => rf_r1a,
        r2_addr => rf_r2a,
        r1_data => rf_r1d,
        r2_data => rf_r2d,

        wr1_addr => rf_wr1a,
        wr1_data => rf_wr1d,
        wr1_en   => rf_wr1en,

        wr2_addr => rf_wr2a,
        wr2_data => rf_wr2d,
        wr2_en   => rf_wr2en
    );

    opc <= instr(63 downto 48);
    reg0 <= instr(47 downto 40);
    reg1 <= instr(39 downto 32);
    reg2 <= instr(31 downto 24);
    reg3 <= instr(23 downto 16);
    immediate <= instr(31 downto 0);
    ldst_addr <= instr(31 downto 0);

    process(reg0, reg1, reg2, reg3, immediate, ldst_addr)
    begin
        tmp_mem_addr <= (others => '0');

        case opc is
            when x"0000" =>
                rf_wr1a <= reg0;
                rf_wr1d <= immediate;
            -- when "0001" =>
            -- when "0002" =>
            when x"0003" =>
                rf_r1a <= reg0;
                tmp_mem_addr <= ldst_addr;
            -- when "0004" =>
            -- when "0005" =>
            -- when "0006" =>
            -- when "0007" =>
            -- when "0008" =>
            -- when "0009" =>
            -- when "000a" =>
            -- when "000b" =>
            -- when "000c" =>
            -- when "000d" =>
            -- when "000e" =>
            -- when "000f" =>
            -- when "0010" =>
            -- when "0011" =>
            -- when "0012" =>
            -- when "0013" =>
            -- when "0014" =>
            when others =>
                null;
        end case;
    end process;

    -- CPU state machine
    process(clk)
    begin
        if rising_edge(clk) then
            mem_wdata <= (others => '0');
            mem_wen <= '0';
            mem_strb <= '0';

            rf_wr1en <= '0';
            rf_wr2en <= '0';

            case curr_state is
                when ST_IF => -- fetch upper half
                    mem_addr <= pc;
                    -- mem_strb <= '1';

                    if mem_ack = '1' then
                        instr(63 downto 32) <= mem_rdata;
                        mem_strb <= '1';
                        mem_addr <= std_logic_vector(unsigned(pc) + 4);
                        curr_state <= ST_ID;
                    end if;
                -- ST_IF

                when ST_ID =>
                    if mem_ack = '1' then
                        instr(31 downto 0) <= mem_rdata;
                        mem_strb <= '0';
                        curr_state <= ST_ID;
                        next_pc <= std_logic_vector(unsigned(pc) + 8);
                        curr_state <= ST_EX;
                    end if;
                -- ST_ID

                when ST_EX =>
                    -- report "current instruction: instr=" & to_hstring(instr);
                    pc <= next_pc;
                    -- curr_state <= ST_IF; -- for testing
                    
                    case opc is
                        when x"0000" => -- LDI
                            rf_wr1en <= '1';
                            curr_state <= ST_WB;
                        when x"0003" => -- STM
                            mem_addr <= tmp_mem_addr;
                            mem_strb <= '1';
                            mem_wen <= '1';
                            mem_wdata <= rf_r1d;
                            curr_state <= ST_MEM;
                        when x"0006" =>
                            curr_state <= ST_HLT;

                        when others => 
                            report "UNKNOWN OPCODE" severity error;
                            report "Got opcode: opc=" & to_hstring(opc);
                            -- synthesis translate off
                            stop;
                            -- synthesis translate on
                    end case; -- execution case
                -- ST_EX

                when ST_MEM =>
                    mem_strb <= '1';
                    if mem_ack = '1' then
                        mem_strb <= '0';
                        curr_state <= ST_WB;
                    end if;
                -- ST_MEM

                when ST_WB =>
                    rf_wr1en <= '0';
                    rf_wr2en <= '0';
                    mem_addr <= pc;
                    mem_strb <= '1';
                    curr_state <= ST_IF;
                -- ST_WB

                when ST_HLT =>
                    -- synthesis translate off
                    report "State halt. Stopping Machine." severity error;
                    stop;
                    -- synthesis translate on
                    curr_state <= ST_HLT;

                when others =>
                    curr_state <= ST_IF;
                    pc <= (others => '0');
                    next_pc <= (others => '0');
            end case;
            
            if nreset = '0' then
                mem_strb <= '1';
                curr_state <= ST_IF;
                pc <= (others => '0');
                next_pc <= (others => '0');
            end if;
        end if;
    end process;

end Behave;
