-- =============================================================
-- Componente: Contatore binario up a Nb bit
-- Strutturale: Nb flip-flop T in cascata (ripple carry)
-- Dipendenze: tff.vhd -> dff.vhd
-- =============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity counter is
    generic(
        Nb : integer
    );
    port(
        T         : in  std_logic;
        clk       : in  std_logic;
        OUT_COUNT : out std_logic_vector(Nb-1 downto 0)
    );
end counter;

architecture counter_behavior of counter is

    component tff is
        port(
            T   : in  std_logic;
            clk : in  std_logic;
            Q   : out std_logic;
            Qn  : out std_logic
        );
    end component;

    signal Q  : std_logic_vector(Nb-1 downto 0);  -- uscite dei FF
    signal en : std_logic_vector(Nb-1 downto 0);  -- carry/enable per ogni bit

begin
    -- Bit 0: toglla ogni volta che T='1'
    en(0) <= T;

    -- Bit i: toglla solo quando tutti i bit precedenti sono '1' e T='1'
    gen_en: for i in 1 to Nb-1 generate
        en(i) <= T and Q(i-1) and en(i-1);
    end generate;

    -- Nb flip-flop T pilotati dal proprio enable
    gen_ff: for i in 0 to Nb-1 generate
        ff_i: tff port map(
            T   => en(i),
            clk => clk,
            Q   => Q(i),
            Qn  => open
        );
    end generate;

    OUT_COUNT <= Q;
end counter_behavior;
