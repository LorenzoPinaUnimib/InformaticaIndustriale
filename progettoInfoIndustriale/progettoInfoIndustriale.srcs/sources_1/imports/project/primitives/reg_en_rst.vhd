-- =============================================================
-- Componente: Registro generico con Enable e Reset sincrono
-- Parametri: Nbit = larghezza in bit
-- Logica per ogni bit:
--   rst='0'            -> D_next = '0'       (reset attivo basso)
--   rst='1', en='1'    -> D_next = datain(i) (carica)
--   rst='1', en='0'    -> D_next = Q(i)      (mantiene)
-- Usato da: accumulator, divide_by
-- =============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_en_rst is
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
end reg_en_rst;

architecture structural of reg_en_rst is

    component dff is
        port(
            D   : in  std_logic;
            clk : in  std_logic;
            Q   : out std_logic;
            Qn  : out std_logic
        );
    end component;

    signal Q_int  : std_logic_vector(Nbit-1 downto 0);
    signal D_next : std_logic_vector(Nbit-1 downto 0);

begin
    -- Mux combinatorio 3:1 per ogni bit: nessun process
    gen_mux: for i in 0 to Nbit-1 generate
        D_next(i) <= '0'         when rst = '0' else
                     datain(i)   when en  = '1' else
                     Q_int(i);
    end generate;

    -- Nbit flip-flop D in parallelo
    gen_ff: for i in 0 to Nbit-1 generate
        ff_i: dff port map(
            D   => D_next(i),
            clk => clk,
            Q   => Q_int(i),
            Qn  => open
        );
    end generate;

    dataout <= Q_int;
end structural;
