-- =============================================================
-- Primitivo: Flip-Flop D
-- Unico punto del progetto con logica sequenziale esplicita.
-- Usato da: tff, accumulator, divide_by
-- =============================================================
library ieee;
use ieee.std_logic_1164.all;

entity dff is
    port(
        D   : in  std_logic;
        clk : in  std_logic;
        Q   : out std_logic;
        Qn  : out std_logic
    );
end dff;

architecture behavioral of dff is
    signal Q_int : std_logic := '0';
begin
    -- Assegnazione concorrente con condizione d'evento: nessun process
    Q_int <= D when rising_edge(clk);
    Q     <= Q_int;
    Qn    <= not Q_int;
end behavioral;
