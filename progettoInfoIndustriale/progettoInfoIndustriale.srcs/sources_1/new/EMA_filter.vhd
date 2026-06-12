library ieee;
use ieee.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.ALL;

entity EMA_filter is
    generic (
        WIDTH : integer := 8;  -- Larghezza del dato (es. 16 bit)
        K     : integer := 3    -- Forza del filtro (più alto = più lento/pulito)
    );
    port (
        clk    : in std_logic;
        rst    : in std_logic;
        data_in  : in signed(WIDTH-1 downto 0);
        data_out : out signed(WIDTH-1 downto 0)
    );
end EMA_filter;

architecture Behavioral of EMA_filter is
    signal acc : signed(WIDTH-1 downto 0) := (others => '0');
    signal diff : signed(WIDTH-1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rst = '0' then
                acc <= (others => '0');
        else
            if rising_edge(clk) then
                -- Calcola la differenza (x - y_prev)
                diff <= data_in - acc;
                if acc + resize(shift_right(diff, K), WIDTH) > 0 then
                    acc <= acc + resize(shift_right(diff, K), WIDTH);
                end if;
            end if;
        end if;
    end process;
    
    data_out <= acc;
end Behavioral;