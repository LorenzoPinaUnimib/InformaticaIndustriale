library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity EMA_filter is
    generic (
        WIDTH : integer := 8;
        K     : integer := 3
    );
    port (
        clk      : in std_logic;
        rst      : in std_logic; -- Assumiamo rst = '1' per resettare
        data_in  : in unsigned(WIDTH-1 downto 0);
        data_out : out unsigned(WIDTH-1 downto 0)
    );
end EMA_filter;

architecture Behavioral of EMA_filter is
    signal acc : unsigned(WIDTH-1 downto 0) := (others => '0');
begin
    process(clk)
        variable diff : unsigned(WIDTH-1 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '0' then
                acc <= (others => '0');
            else
                if data_in > acc then
                    -- Se l'input è maggiore, la differenza è positiva
                    diff := data_in - acc;
                    acc <= acc + resize(shift_right(diff, K), WIDTH);
                elsif data_in < acc then
                    -- Se l'input è minore, la differenza è negativa
                    -- Sottraiamo la parte frazionaria per scendere verso il valore
                    diff := acc - data_in;
                    acc <= acc - resize(shift_right(diff, K), WIDTH);
                end if;
                -- Se data_in = acc, non facciamo nulla (acc rimane invariato)
            end if;
        end if;
    end process;
    
    data_out <= acc;
end Behavioral;