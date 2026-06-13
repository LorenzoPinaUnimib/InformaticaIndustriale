close all;
clear all;

Nb=8;
tclk=20e-9;
N=Nb;
NFIFO=128;


% 1. CARICAMENTO DATI
% Assicurati che i file siano nella cartella di lavoro di MATLAB
file_orig = 'mysignal.txt';
file_filt = 'output_results_mdm.txt';

% Leggi le stringhe dal file
mypath='D:\github\InformaticaIndustriale\progettoInfoIndustriale.sim\sim_1\behav\xsim\';
data_orig_bin = importdata(strcat(mypath,file_orig));
data_filt_bin = importdata(strcat(mypath,file_filt));

% 2. CONVERSIONE BINARIO -> DECIMALE
% Supponendo che il formato sia '01010101'
signal_orig=bin2dec(num2str(data_orig_bin));
%signal_orig=signal_orig/(2^Nb);
signal_filt_mat=movmean(signal_orig,128);

signal_filt = bin2dec(num2str(data_filt_bin));
%signal_filt=signal_filt/(2^Nb);
%signal_filt=movmean(signal_filt,64);

% Se i dati sono in complemento a due (a 8 o 16 bit), 
% potresti aver bisogno di una conversione personalizzata:
% Esempio per 8 bit:
% signal_orig = typecast(uint8(bin2dec(data_orig_bin)), 'int8');

% 3. ALLINEAMENTO (Opzionale)
% Se il filtro introduce un ritardo (es. group delay), dobbiamo rimuoverlo
% per un confronto corretto (ritaglio dei campioni)
min_len = min(length(signal_orig), length(signal_filt));
signal_orig = signal_orig(1:min_len);
signal_filt = signal_filt(1:min_len);
signal_filt_mat=signal_filt_mat(1:min_len);

% 4. CALCOLO SNR
% Segnale puro = Media (o riferimento)
% Rumore = Differenza tra segnale originale e filtrato
noise = signal_orig - signal_filt;

% Calcolo della potenza (RMS)
rms_signal = rms(signal_orig);
rms_noise = rms(noise);

% SNR in dB
snr_db = 20 * log10(rms_signal / rms_noise);

fprintf('Il valore di Signal-to-Noise Ratio (SNR) calcolato e'': %.2f dB\n', snr_db);

% 5. GRAFICI DI CONFRONTO
figure('Color', 'w', 'Name', 'Analisi Segnale');

% Plot Temporale
subplot(2,1,1);
plot(signal_orig, 'Color', [0.7 0.7 0.7], 'LineWidth', 1); hold on;
plot(signal_filt, 'r', 'LineWidth', 1.5);
title('Confronto: Segnale Originale vs Filtrato');
legend('Originale', 'Filtrato');
grid on; xlabel('Campioni'); ylabel('Ampiezza');

% Plot Errore (Rumore rimosso)
subplot(2,1,2);
plot(noise, 'k');
title(['Errore di Filtro (Rumore residuo) - SNR: ' num2str(snr_db, '%.2f') ' dB']);
grid on; xlabel('Campioni'); ylabel('Differenza');

%%% SINUSOIDAL SIGNAL and NOISE to fit FS
SNRdB=0;
FS=256;
SNR=10^(SNRdB/20);
pnoise=FS/(2*SNR*sqrt(2) + 3);
A0=pnoise*SNR*sqrt(2);
A0off=A0;

%%% Signal Period(s)/freq., OVR and Time Axis
T0=(2^Nb)*tclk;
f0=1/T0;
fs=1/tclk;
fcutoff=0.5*fs/NFIFO;
OVR=fs/(2*f0);
Mperiods=20;
Nsamples_tot=Mperiods*2^Nb;

t=1:1:Mperiods*(2^Nb);
t=t/length(t);
t=t*T0*Mperiods;

%%% ysignal is the pure signal
%%% ynoise is the noise signal
%%% yns=ysignal+ynoise
signal_pure=1*(A0off+A0*sin(2*pi*f0*t));
ysignal=1*(A0off+A0*sin(2*pi*f0*t));
ynoise=pnoise*(1+randn(1,length(t)));
yns=ysignal+ynoise;

% --- Visualizzazione ---
figure('Color', 'w', 'Name', 'Analisi Confronto Pura');

% Grafico 1: Originale vs Filtrata (Come prima)
subplot(3,1,1);
plot(signal_orig, 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5); hold on;
plot(signal_filt, 'r', 'LineWidth', 1.2);
title('Originale vs Filtrato');
legend('Originale (Rumoroso)', 'Filtrato (Output MDM)');
grid on;

% Grafico 2: Errore (Rumore Residuo)
subplot(3,1,2);
plot(noise, 'k');
title(['Rumore Tolto Totale (SNR: ' num2str(snr_db, '%.2f') ' dB)']);
grid on;

% Grafico 3: Confronto Filtro vs Sinusoide Pura
subplot(3,1,3);
plot(signal_filt_mat, 'g', 'LineWidth', 1); hold on;
plot(signal_filt, 'r', 'LineWidth', 1); 
title('Confronto Filtrato Matlab vs Sinusoide Pura');
legend('Output Filtro', 'Riferimento Ideale');
xlabel('Campioni'); ylabel('Ampiezza');
grid on;

% Calcolo errore rispetto al puro per metriche extra
%residual_pure = signal_filt - signal_pure;
%fprintf('Errore RMS rispetto alla sinusoide ideale: %.2f\n', rms(residual_pure));