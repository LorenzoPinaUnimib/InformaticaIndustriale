-- =============================================================
-- Primitivo: Flip-Flop T (Toggle)
-- Costruito su dff con retroazione XOR.
-- D = T XOR Q  ->  inverte se T='1', mantiene se T='0'
-- Usato da: counter
-- =============================================================
library ieee;
use ieee.std_logic_1164.all;

entity tff is
    port(
        T   : in  std_logic;
        clk : in  std_logic;
        Q   : out std_logic;
        Qn  : out std_logic
    );
end tff;

architecture structural of tff is

    component dff is
        port(
            D   : in  std_logic;
            clk : in  std_logic;
            Q   : out std_logic;
            Qn  : out std_logic
        );
    end component;

    signal Q_int : std_logic;
    signal D_int : std_logic;

begin
    D_int <= T xor Q_int;   -- logica di toggle: combinatoria, no process

    ff: dff port map(
        D   => D_int,
        clk => clk,
        Q   => Q_int,
        Qn  => Qn
    );

    Q <= Q_int;
end structural;
