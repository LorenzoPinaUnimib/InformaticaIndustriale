-- =============================================================
-- Top-level: Filtro a Media Mobile (Moving Average Filter)
-- Parametri: Nbf bit di ingresso, finestra = 2^log2NFIFOf campioni
-- Struttura:
--   datain --> [FIFO] --> dout_old \
--          \                        --> [MULTIADDER] --> [ACCUMULATOR] --> [DIVIDE_BY] --> dataout
--           \--> din_new -----------/        ^                |
--                                            |________________|  (feedback)
-- Dipendenze: fifo, multiadder, accumulator, divide_by
-- =============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter_ma is
    generic(
        Nbf        : integer;
        log2NFIFOf : integer
    );
    port(
        clk     : in  std_logic;
        en      : in  std_logic;
        rst     : in  std_logic;
        datain  : in  signed(Nbf-1 downto 0);
        dataout : out signed(Nbf+log2NFIFOf-1 downto 0)
    );
end filter_ma;

architecture structural of filter_ma is

    component fifo is
        generic(Nb: integer; log2NFIFO: integer);
        port(clk: in std_logic; en: in std_logic; rst: in std_logic;
             din: in signed(Nb-1 downto 0); dout: out signed(Nb-1 downto 0));
    end component;

    component multiadder is
        generic(Nb: integer; log2NFIFO: integer);
        port(datain_fifo: in signed(Nb-1 downto 0);
             dataout_fifo: in signed(Nb-1 downto 0);
             dataout_accumulator: in signed(Nb+log2NFIFO-1 downto 0);
             dataout: out signed(Nb+log2NFIFO-1 downto 0));
    end component;

    component accumulator is
        generic(Nb: integer; log2NFIFO: integer);
        port(clk: in std_logic; en: in std_logic; rst: in std_logic;
             datain: in signed(Nb+log2NFIFO-1 downto 0);
             dataout: out signed(Nb+log2NFIFO-1 downto 0));
    end component;

    component divide_by is
        generic(Nb: integer; log2NFIFO: integer);
        port(clk: in std_logic; en: in std_logic; rst: in std_logic;
             datain: in signed(Nb+log2NFIFO-1 downto 0);
             dataout: out signed(Nb+log2NFIFO-1 downto 0));
    end component;

    -- Segnali di collegamento interni
    signal dout_fifo        : signed(Nbf-1 downto 0);
    signal dout_multiadder  : signed(Nbf+log2NFIFOf-1 downto 0);
    signal dout_accumulator : signed(Nbf+log2NFIFOf-1 downto 0);

begin

    u_fifo: fifo
        generic map(Nb => Nbf, log2NFIFO => log2NFIFOf)
        port map(clk => clk, en => en, rst => rst,
                 din => datain, dout => dout_fifo);

    u_multiadder: multiadder
        generic map(Nb => Nbf, log2NFIFO => log2NFIFOf)
        port map(datain_fifo         => datain,
                 dataout_fifo        => dout_fifo,
                 dataout_accumulator => dout_accumulator,
                 dataout             => dout_multiadder);

    u_accumulator: accumulator
        generic map(Nb => Nbf, log2NFIFO => log2NFIFOf)
        port map(clk => clk, en => en, rst => rst,
                 datain  => dout_multiadder,
                 dataout => dout_accumulator);

    u_divide_by: divide_by
        generic map(Nb => Nbf, log2NFIFO => log2NFIFOf)
        port map(clk => clk, en => en, rst => rst,
                 datain  => dout_accumulator,
                 dataout => dataout);

end structural;
