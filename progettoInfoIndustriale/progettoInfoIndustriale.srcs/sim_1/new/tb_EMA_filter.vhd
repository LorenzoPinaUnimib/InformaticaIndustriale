library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_ema_cascade is
end tb_ema_cascade;

architecture behavioral of tb_ema_cascade is

    constant WIDTH      : integer := 8; -- Larghezza dati interna
    constant INPUT_W    : integer := 8;  -- Larghezza segnale ingresso da file
    constant K          : integer := 3;  -- Forza dello shift
    constant N_SAMPLES  : integer := 4096;

    -- Componente EMA (quello definito nel messaggio precedente)
    component EMA_filter is
        generic (WIDTH : integer; K : integer);
        port (clk, rst : in std_logic;
              data_in  : in signed(WIDTH-1 downto 0);
              data_out : out signed(WIDTH-1 downto 0));
    end component;

    -- Segnali
    signal clks, rsts : std_logic := '0';
    signal din_raw    : signed(WIDTH-1 downto 0) := (others => '0');
    signal sig_mid    : signed(WIDTH-1 downto 0);
    signal sig_mid2    : signed(WIDTH-1 downto 0);

    signal dout_final : signed(WIDTH-1 downto 0);
    
    file file_in, file_out : text;

begin

    -- Clock: periodo 20 ns
    clks <= not clks after 10 ns;
    
-- Reset: attivo per i primi 20 ns
    rst_proc: process
    begin
        rsts <= '0'; wait for 20 ns;
        rsts <= '1'; wait;
    end process;

    -- Istanza Filtro 1
    ema1: EMA_filter generic map(WIDTH => WIDTH, K => K)
                    port map(clk => clks, rst => rsts, data_in => din_raw, data_out => sig_mid);

    -- Istanza Filtro 2
    ema2: EMA_filter generic map(WIDTH => WIDTH, K => K)
                    port map(clk => clks, rst => rsts, data_in => sig_mid, data_out => sig_mid2);
    ema3: EMA_filter generic map(WIDTH => WIDTH, K => K)
                    port map(clk => clks, rst => rsts, data_in => sig_mid, data_out => dout_final);

    -- Lettura file
    read_proc: process
        variable vline : line;
        variable vdata : std_logic_vector(INPUT_W-1 downto 0);
        variable n     : integer := 0;
    begin
        file_open(file_in, "mysignal.txt", read_mode);
        while n < N_SAMPLES loop
            readline(file_in, vline);
            read(vline, vdata);
            -- Estendiamo il dato a 16 bit per mantenere precisione interna
            din_raw <= resize(signed(vdata), WIDTH);
            wait for 20 ns;
            n := n + 1;
        end loop;
        file_close(file_in);
        wait;
    end process;

    -- Scrittura uscita filtrata su file (allineata al ritardo del filtro)
    write_proc: process
        variable vline : line;
        variable n     : integer := 0;
    begin
        file_open(file_out, "output_results_mdm.txt", write_mode);
        wait for 40 ns;  -- attende fine reset + primo campione valido
        while n < N_SAMPLES loop
            wait for 20 ns;
            write(vline,  std_logic_vector(dout_final), right, INPUT_W-1);
            writeline(file_out, vline);
            n := n + 1;
        end loop;
        file_close(file_out);
        wait;
    end process;

end behavioral;