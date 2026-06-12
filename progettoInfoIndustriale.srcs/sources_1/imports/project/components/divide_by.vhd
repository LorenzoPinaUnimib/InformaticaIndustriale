-- =============================================================
-- Componente: Divisore per NFIFO = 2^log2NFIFO
-- Poiche' NFIFO e' potenza di 2, la divisione e' uno shift
-- aritmetico a destra di log2NFIFO posizioni (cablaggio puro,
-- zero logica attiva). Il risultato viene poi registrato.
-- Dipendenze: reg_en_rst.vhd -> dff.vhd
-- =============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity divide_by is
    generic(
        Nb        : integer;
        log2NFIFO : integer
    );
    port(
        clk     : in  std_logic;
        en      : in  std_logic;
        rst     : in  std_logic;
        datain  : in  unsigned(Nb+log2NFIFO-1 downto 0);
        dataout : out unsigned(Nb+log2NFIFO-1 downto 0)
    );
end divide_by;

architecture structural of divide_by is

    constant Nacc : integer := Nb + log2NFIFO;

    component reg_en_rst is
        generic(
            Nbit : integer
        );
        port(
            clk     : in  std_logic;
            en      : in  std_logic;
            rst     : in  std_logic;
            datain  : in  std_logic_vector(Nbit-1 downto 0);
            dataout : out std_logic_vector(Nbit-1 downto 0)
        );
    end component;

    -- Shift aritmetico combinatorio: divide per 2^log2NFIFO
    -- shift_right propaga il bit di segno (MSB) sui bit liberati
    signal datain_shifted : unsigned(Nacc-1 downto 0);
    signal reg_out        : std_logic_vector(Nacc-1 downto 0);

begin
    -- Shift puramente combinatorio: nessun processo, solo cablaggio
    datain_shifted <= shift_right(datain, log2NFIFO);

    reg: reg_en_rst
        generic map(Nbit => Nacc)
        port map(
            clk     => clk,
            en      => en,
            rst     => rst,
            datain  => std_logic_vector(datain_shifted),
            dataout => reg_out
        );

    dataout <= unsigned(reg_out);
end structural;
