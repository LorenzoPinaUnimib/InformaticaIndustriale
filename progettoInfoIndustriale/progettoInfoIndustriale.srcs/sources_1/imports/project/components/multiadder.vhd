-- =============================================================
-- Componente: Multiadder (sommatore differenziale)
-- Puramente combinatorio: nessun registro, nessun clock.
-- Equazione: dataout = acc_old + nuovo_campione - campione_uscente
-- I segnali a Nb bit vengono estesi con segno a Nb+log2NFIFO bit
-- prima dell'addizione per evitare overflow.
-- Dipendenze: nessuna
-- =============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiadder is
    generic(
        Nb        : integer;
        log2NFIFO : integer
    );
    port(
        datain_fifo         : in  unsigned(Nb-1 downto 0);
        dataout_fifo        : in  unsigned(Nb-1 downto 0);
        dataout_accumulator : in  unsigned(Nb+log2NFIFO-1 downto 0);
        dataout             : out unsigned(Nb+log2NFIFO-1 downto 0)
    );
end multiadder;

architecture behavioral of multiadder is

    signal datain_fifo_large  : unsigned(Nb+log2NFIFO-1 downto 0);
    signal dataout_fifo_large : unsigned(Nb+log2NFIFO-1 downto 0);
    signal mask0              : unsigned(log2NFIFO-1 downto 0) := (others => '0');

begin
    datain_fifo_large  <=  mask0 & datain_fifo;
    dataout_fifo_large <=  mask0 & dataout_fifo;
    
    -- Equazione ricorsiva del filtro a media mobile
    dataout <= dataout_accumulator + datain_fifo_large - dataout_fifo_large;
end behavioral;
