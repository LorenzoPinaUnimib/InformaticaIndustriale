-- =============================================================
-- Testbench: filter_ma (top-level)
-- Legge 4096 campioni da "mysignal.txt" (8 bit per riga, binario),
-- li passa al filtro e scrive l'uscita su "filtered_output.txt".
-- =============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_filter_ma is
end tb_filter_ma;

architecture behavioral of tb_filter_ma is

    constant Nbf          : integer := 8;
    constant log2NFIFOf   : integer := 7;   -- finestra = 128 campioni
    constant N_SAMPLES    : integer := 4096;

    component filter_ma is
        generic(Nbf: integer; log2NFIFOf: integer);
        port(clk: in std_logic; en: in std_logic; rst: in std_logic;
             datain: in unsigned(Nbf-1 downto 0);
             dataout: out unsigned(Nbf+log2NFIFOf-1 downto 0));
    end component;

    file file_in  : text;
    file file_out : text;

    signal clks       : std_logic;
    signal rsts       : std_logic;
    signal ens        : std_logic;
    signal din        : unsigned(Nbf-1 downto 0);
    signal dout       : unsigned(Nbf+log2NFIFOf-1 downto 0);

begin
    -- Clock: periodo 20 ns
    clk_proc: process
    begin
        clks <= '1'; wait for 10 ns;
        clks <= '0'; wait for 10 ns;
    end process;

    -- Reset: attivo per i primi 20 ns
    rst_proc: process
    begin
        rsts <= '0'; wait for 20 ns;
        rsts <= '1'; wait;
    end process;

    -- Enable: attivo dopo il reset
    en_proc: process
    begin
        ens <= '0'; wait for 20 ns;
        ens <= '1'; wait;
    end process;

    -- DUT
    dut: filter_ma
        generic map(Nbf => Nbf, log2NFIFOf => log2NFIFOf)
        port map(clk => clks, en => ens, rst => rsts,
                 datain => din, dataout => dout);

    -- Lettura campioni da file: un campione ogni periodo di clock
    read_proc: process
        variable vline : line;
        variable vdata : std_logic_vector(Nbf-1 downto 0);
        variable n     : integer := 0;
    begin
        file_open(file_in, "mysignal.txt", read_mode);
        while n < N_SAMPLES loop
            readline(file_in, vline);
            read(vline, vdata);
            din <= unsigned(vdata);
            wait for 20 ns;
            n := n + 1;
        end loop;
        file_close(file_in);
        wait;
    end process;

    -- Scrittura uscita filtrata su file (allineata al ritardo del filtro)
    write_proc: process
        variable vline : line;
        variable n     : integer := 0;
    begin
        file_open(file_out, "output_results_mdm.txt", write_mode);
        wait for 40 ns;  -- attende fine reset + primo campione valido
        while n < N_SAMPLES loop
            wait for 20 ns;
            write(vline, std_logic_vector(dout), right, Nbf+log2NFIFOf);
            writeline(file_out, vline);
            n := n + 1;
        end loop;
        file_close(file_out);
        wait;
    end process;
end behavioral;
