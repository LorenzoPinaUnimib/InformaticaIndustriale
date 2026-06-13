%% Script Completo: Analisi Risposta in Frequenza (Media Mobile)
clear; clc; close all;

% 1. CARICAMENTO DATI
file_orig = 'mysignal.txt';
file_filt = 'output_results_mdm.txt';

% Leggi le stringhe dal file
mypath='D:\github\InformaticaIndustriale\progettoInfoIndustriale.sim\sim_1\behav\xsim\';
data_orig = importdata(strcat(mypath,file_orig));
data_filt = importdata(strcat(mypath,file_filt));
% Script MATLAB: Filtro a media mobile a 64 campioni e analisi in frequenza
% Data: 13 giugno 2026



% Leggere i dati dal file txt
signal = importdata(strcat(mypath,file_orig));  % Funziona per MATLAB 2019a
signal=bin2dec(num2str(signal));
% Alternative: signal = importdata(filename); o signal = textread(filename);

disp(["Segnale leggito: " + num2str(length(signal)) + " campioni"]);

%% 2. Applica filtro a media mobile a 64 campioni
N = 128;  % Numero di campioni per la media mobile

% Creare i coefficienti del filtro FIR (media mobile)
b = ones(N, 1)/N;  % Coefficienti normalizzati (1/N per ogni campione)
a = 1;                % Filtro FIR (denominator = 1)

% Applicare il filtro al segnale
signal_filtered = importdata(strcat(mypath,file_filt));
signal_filtered=bin2dec(num2str(signal_filtered));

disp(["Filtro a media mobile applicato con " + num2str(N) + " campioni"]);

%% 3. Analizza la risposta in frequenza del filtro
% Utilizzare freqz per calcolare la risposta in frequenza
num_freq_points = 2048;  % Numero di punti per la risposta

% Calcolare la risposta in frequenza
[h, w] = freqz(b, a, num_freq_points);

% Convertire frequenza da rad/sample a Hz
tclk = 20e-9;    % Periodo clock = 20 ns
Fs = 1/tclk;     % Fs = 50 MHz = 50,000,000 Hz
f = w * Fs / (2 * pi);  % Frequenza in Hz

%% 4. Visualizza i risultati
% Figura 1: Segnale originale e filtrato nel tempo
figure('Name', 'Segnale nel tempo', 'Position', [100, 100, 800, 400]);

subplot(2,1,1);
plot(signal, 'b', 'LineWidth', 0.5);
title("Segnale Rumoroso Original");
xlabel("Campioni");
ylabel("Amplitudine");
grid on;

subplot(2,1,2);
plot(signal_filtered, 'r', 'LineWidth', 1);
title("Segnale Filtrato con Media Mobile (64 campioni)");
xlabel("Campioni");
ylabel("Amplitudine");
grid on;

% Figura 2: Risposta in frequenza del filtro
figure('Name', 'Risposta in Frequenza del Filtro', 'Position', [100, 100, 800, 500]);

subplot(2,1,1);
plot(f, abs(h), 'b', 'LineWidth', 1.5);
title("Risposta in Magnitudine del Filtro a Media Mobile");
xlabel("Frequenza (Hz)");
ylabel("|H(f)|");
grid on;
xlim([0, Fs/2]);  % Solo frequenze positive (0 a Fs/2)

subplot(2,1,2);
plot(f, 20*log10(abs(h)), 'r', 'LineWidth', 1.5);
title("Risposta in Magnitudine (dB)");
xlabel("Frequenza (Hz)");
ylabel("|H(f)| (dB)");
grid on;
xlim([0, Fs/2]);

% Figura 3: Spettro di Fourier del segnale
figure('Name', 'Analisi Spettrale', 'Position', [100, 100, 800, 400]);

% Calcolare FFT
N_fft = length(signal);
Y_original = fft(signal, N_fft);
Y_filtered = fft(signal_filtered, N_fft);

% Frequenze positive
f_spectrum = (0:N_fft/2-1) * Fs / N_fft;

subplot(2,1,1);
plot(f_spectrum, abs(Y_original(1:N_fft/2)), 'b', 'LineWidth', 0.8);
title("Spettro - Segnale Original (Rumoroso)");
xlabel("Frequenza (Hz)");
ylabel("|Y(f)|");
grid on;
xlim([0, Fs/2]);

subplot(2,1,2);
plot(f_spectrum, abs(Y_filtered(1:N_fft/2)), 'r', 'LineWidth', 0.8);
title("Spettro - Segnale Filtrato");
xlabel("Frequenza (Hz)");
ylabel("|Y(f)|");
grid on;
xlim([0, Fs/2]);

%% 5. Informazioni sul filtro
disp("===== INFORMAZIONI SUL FILTRO =====");
disp(["Ordine del filtro: " + num2str(N-1)]);
disp(["Numero di coefficienti: " + num2str(N)]);
disp(["Frequenza di taglio approx: " + num2str(Fs/(2*N)) + " Hz (~7.8 Hz per Fs=1000Hz)"]);
disp("Filtro passa-basso FIR con risposta: H(f) = (1/N) * sum(exp(-j*2*pi*f*k/Fs)), k=0..N-1");
disp("===== FINE SCRIPT =====");