-- =============================================================
-- Testbench: multiadder
-- Il DUT e' puramente combinatorio: nessun clock necessario.
-- Si applicano valori fissi e si verifica l'uscita immediatamente.
-- =============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_multiadder is
end tb_multiadder;

architecture behavioral of tb_multiadder is

    constant Nb        : integer := 8;
    constant log2NFIFO : integer := 6;

    component multiadder is
        generic(Nb: integer; log2NFIFO: integer);
        port(datain_fifo: in unsigned(Nb-1 downto 0);
             dataout_fifo: in unsigned(Nb-1 downto 0);
             dataout_accumulator: in unsigned(Nb+log2NFIFO-1 downto 0);
             dataout: out unsigned(Nb+log2NFIFO-1 downto 0));
    end component;

    signal s_din_fifo  : unsigned(Nb-1 downto 0)            := (others => '0');
    signal s_dout_fifo : unsigned(Nb-1 downto 0)            := (others => '0');
    signal s_acc       : unsigned(Nb+log2NFIFO-1 downto 0)  := (others => '0');
    signal s_out       : unsigned(Nb+log2NFIFO-1 downto 0);

begin

    dut: multiadder
        generic map(Nb => Nb, log2NFIFO => log2NFIFO)
        port map(datain_fifo         => s_din_fifo,
                 dataout_fifo        => s_dout_fifo,
                 dataout_accumulator => s_acc,
                 dataout             => s_out);

    stim: process
    begin
        -- Test 1: 0 + 10 - 0 = 10
        s_acc       <= to_unsigned(0,   Nb+log2NFIFO);
        s_din_fifo  <= to_unsigned(10,  Nb);
        s_dout_fifo <= to_unsigned(0,   Nb);
        wait for 20 ns;

        -- Test 2: 100 + 5 - 3 = 102
        s_acc       <= to_unsigned(100, Nb+log2NFIFO);
        s_din_fifo  <= to_unsigned(5,   Nb);
        s_dout_fifo <= to_unsigned(3,   Nb);
        wait for 20 ns;

        -- Test 3: 50 + 254 - 8 = 296
        s_acc       <= to_unsigned(50,  Nb+log2NFIFO);
        s_din_fifo  <= to_unsigned(254,  Nb);
        s_dout_fifo <= to_unsigned(8,   Nb);
        wait for 20 ns;

        -- Test 4: 60 + 1 - 15 = 46
        s_acc       <= to_unsigned(60, Nb+log2NFIFO);
        s_din_fifo  <= to_unsigned(1,   Nb);
        s_dout_fifo <= to_unsigned(15,   Nb);
        wait for 20 ns;
    end process;
end behavioral;
