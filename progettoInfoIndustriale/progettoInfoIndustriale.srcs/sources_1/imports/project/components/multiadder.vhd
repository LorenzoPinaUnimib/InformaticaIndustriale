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
        datain_fifo         : in  signed(Nb-1 downto 0);
        dataout_fifo        : in  signed(Nb-1 downto 0);
        dataout_accumulator : in  signed(Nb+log2NFIFO-1 downto 0);
        dataout             : out signed(Nb+log2NFIFO-1 downto 0)
    );
end multiadder;

architecture behavioral of multiadder is

    signal datain_fifo_large  : signed(Nb+log2NFIFO-1 downto 0);
    signal dataout_fifo_large : signed(Nb+log2NFIFO-1 downto 0);
    signal mask0              : signed(log2NFIFO-1 downto 0) := (others => '0');

begin

   datain_fifo_large  <=  (log2NFIFO-1 downto 0 => datain_fifo(Nb-1))  & datain_fifo;
   dataout_fifo_large <=  (log2NFIFO-1 downto 0 => dataout_fifo(Nb-1)) & dataout_fifo;
    -- Equazione ricorsiva del filtro a media mobile
    dataout <= dataout_accumulator + datain_fifo_large - dataout_fifo_large;
end behavioral;
