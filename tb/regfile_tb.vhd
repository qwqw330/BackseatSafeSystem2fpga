----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/02/2022 03:43:43 AM
-- Design Name: 
-- Module Name: regfile_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use std.env.stop;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity regfile_tb is
--  Port ( );
end regfile_tb;

architecture behave of regfile_tb is
    signal clk, nrst : std_Logic := '0';
    signal r1a, r2a, wr1a, wr2a : std_logic_vector(4 downto 0) := (others => '0');
    signal r1d, r2d, wr1d, wr2d : std_logic_vector(31 downto 0) := (others => '0');
    signal wr1en, wr2en : std_logic;
begin

    nrst <= '0', '1' after 25 ns;
    clk <= not clk after 5 ns;

    process
    begin
        wr1en <= '0';
        wr2en <= '0';
        r1a <= (others => '0');
        r2a <= (others => '0');

        wait for 50 ns;
        for I in 0 to 15 loop
            wr1en <= '1';
            wr2en <= '1';
            -- wra <= std_logic_vector(to_unsigned(I, wra'length));
            wr1a <= '0' & std_logic_vector(to_unsigned(I, 4));
            wr2a <= '1' & std_logic_vector(to_unsigned(I, 4));
            wr1d <= std_logic_vector(to_unsigned(I, 32) + 1);
            wr2d <= std_logic_vector(to_unsigned(I, 32) + 3);
            wait until rising_edge(clk);
        end loop;

        wr1en <= '0';
        wr1a <= (others => '0');
        wr1d <= (others => '0');
        wr2en <= '0';
        wr2a <= (others => '0');
        wr2d <= (others => '0');
        wait until rising_edge(clk);

        for I in 0 to 15 loop
            r1a <= '0' & std_logic_vector(to_unsigned(I, 4));
            r2a <= '1' & std_logic_vector(to_unsigned(I, 4));
            wait until rising_edge(clk);
        end loop;

        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        report "Finished simulation" severity Error;
        stop;
    end process;

    inst_reg : entity work.regfile 
    generic map (
        STACKADDR => x"00008000"
    )
    port map (
        clk => clk,
        nrst => nrst,
        r1_addr => r1a,
        r2_addr => r2a,
        wr1_addr => wr1a,
        wr1_data => wr1d,
        wr1_en => wr1en,
        wr2_addr => wr2a,
        wr2_data => wr2d,
        wr2_en => wr2en,
        r1_data => r1d,
        r2_data => r2d
    );
end behave;
