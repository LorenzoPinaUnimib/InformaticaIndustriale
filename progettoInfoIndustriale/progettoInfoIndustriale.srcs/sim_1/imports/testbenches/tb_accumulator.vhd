-- =============================================================
-- Testbench: accumulator
-- Usa il counter come sorgente dati incrementale.
-- Verifica che dataout segua datain con un ciclo di ritardo
-- e si azzeri correttamente con il reset.
-- =============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_accumulator is
end tb_accumulator;

architecture behavioral of tb_accumulator is

    constant Nb        : integer := 8;
    constant log2NFIFO : integer := 6;
    constant Nacc      : integer := Nb + log2NFIFO;

    component accumulator is
        generic(Nb: integer; log2NFIFO: integer);
        port(clk: in std_logic; en: in std_logic; rst: in std_logic;
             datain: in unsigned(Nb+log2NFIFO-1 downto 0);
             dataout: out unsigned(Nb+log2NFIFO-1 downto 0));
    end component;

    component counter is
        generic(Nb: integer);
        port(T: in std_logic; clk: in std_logic;
             OUT_COUNT: out std_logic_vector(Nb-1 downto 0));
    end component;

    signal clks    : std_logic;
    signal rsts    : std_logic;
    signal ens     : std_logic;
    signal cnt_out : std_logic_vector(Nacc-1 downto 0);
    signal datain  : unsigned(Nacc-1 downto 0);
    signal dataout : unsigned(Nacc-1 downto 0);

begin

    -- Clock: periodo 20 ns
    clk_process: process
    begin
        clks <= '1'; wait for 10 ns;
        clks <= '0'; wait for 10 ns;
    end process;

    -- Reset attivo per i primi 30 ns
    rst_process: process
    begin
        rsts <= '0'; wait for 30 ns;
        rsts <= '1'; wait;
    end process;

    -- Enable attivo dopo il reset
    en_process: process
    begin
        ens <= '0'; wait for 30 ns;
        ens <= '1'; wait;
    end process;

    -- Counter: genera 0,1,2,3,... -> datain cresce a ogni clock
    dut_counter: counter
        generic map(Nb => Nacc)
        port map(T => '1', clk => clks, OUT_COUNT => cnt_out);

    datain <= unsigned(cnt_out);

    -- DUT: dataout deve essere uguale a datain del ciclo precedente
    dut_acc: accumulator
        generic map(Nb => Nb, log2NFIFO => log2NFIFO)
        port map(clk => clks, en => ens, rst => rsts,
                 datain => datain, dataout => dataout);

end behavioral;
