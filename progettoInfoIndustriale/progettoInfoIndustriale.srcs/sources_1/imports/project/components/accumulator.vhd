-- =============================================================
-- Componente: Accumulatore (registro con enable e reset)
-- Cattura l'uscita del multiadder a ogni clock con en='1'.
-- Dipendenze: reg_en_rst.vhd -> dff.vhd
-- =============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator is
    generic(
        Nb        : integer;
        log2NFIFO : integer
    );
    port(
        clk     : in  std_logic;
        en      : in  std_logic;
        rst     : in  std_logic;
        datain  : in  signed(Nb+log2NFIFO-1 downto 0);
        dataout : out signed(Nb+log2NFIFO-1 downto 0)
    );
end accumulator;

architecture structural of accumulator is

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

    signal reg_out : std_logic_vector(Nacc-1 downto 0);

begin
    reg: reg_en_rst
        generic map(Nbit => Nacc)
        port map(
            clk     => clk,
            en      => en,
            rst     => rst,
            datain  => std_logic_vector(datain),
            dataout => reg_out
        );

    dataout <= signed(reg_out);
end structural;
