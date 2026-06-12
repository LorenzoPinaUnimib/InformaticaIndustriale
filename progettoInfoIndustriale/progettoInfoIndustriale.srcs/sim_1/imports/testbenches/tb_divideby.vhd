-- =============================================================
-- Testbench: divide_by
-- Con log2NFIFO=6 divide per 64.
-- Usa il counter come sorgente: quando datain=64 -> dataout=1,
-- quando datain=128 -> dataout=2, ecc.
-- =============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_divide_by is
end tb_divide_by;

architecture behavioral of tb_divide_by is

    constant Nb        : integer := 8;
    constant log2NFIFO : integer := 6;  -- divide per 2^6 = 64
    constant Nacc      : integer := Nb + log2NFIFO;

    component divide_by is
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

    clk_process: process
    begin
        clks <= '1'; wait for 10 ns;
        clks <= '0'; wait for 10 ns;
    end process;

    rst_process: process
    begin
        rsts <= '0'; wait for 30 ns;
        rsts <= '1'; wait;
    end process;

    en_process: process
    begin
        ens <= '0'; wait for 30 ns;
        ens <= '1'; wait;
    end process;

    dut_counter: counter
        generic map(Nb => Nacc)
        port map(T => '1', clk => clks, OUT_COUNT => cnt_out);

    datain <= unsigned(cnt_out);

    -- DUT: dataout = datain >> log2NFIFO (shift aritmetico)
    -- Quando datain raggiunge 64 (0x40), dataout deve valere 1
    dut_div: divide_by
        generic map(Nb => Nb, log2NFIFO => log2NFIFO)
        port map(clk => clks, en => ens, rst => rsts,
                 datain => datain, dataout => dataout);

end behavioral;
