clc;clear;
%% Lorenz
F=@(t,Y)[10*Y(2)-10*Y(1);...
         -Y(1).*Y(3)+28*Y(1)-Y(2);...
         Y(1).*Y(2)-8*Y(3)/3;...
         ];
         
opt = odeset( 'RelTol', 10.0^(-7), 'AbsTol' , 10.0^(-7));     
y0=rand(3,1);
[t,Y] = ode45(F, [0:0.01:200], y0, opt);
%fs = 200; % Sampling frequency in Hz
fs=1/0.01;
t = 0:1/fs:1-1/fs; % Time vector (1 second duration)
%signal = target_Out(1,1:end_train); % Composite signal
signal =Y(:,1);
% Option 2: Load your own sequence data
% Uncomment the following line and provide your data
% signal = load('your_data.mat'); % Replace with your data file

%% 2. Apply a window function
N = length(signal); % Length of the signal
window = hamming(N); % Hamming window
signal_windowed = signal .* window'; % Apply window to the signal

%% 3. Perform FFT
fft_result = fft(signal_windowed); % Compute FFT
P2 = abs(fft_result/N); % Two-sided spectrum
P1 = P2(1:N/2+1); % Single-sided spectrum
P1(2:end-1) = 2*P1(2:end-1); % Adjust for single-sided spectrum

frequencies = (0:(N/2))*fs/N; % Frequency vector



%% 6.83 Plot the frequency spectrum
figure;
plot(frequencies, P1);
title('Frequency Spectrum');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
xlim([-0.1 5]);
grid on;
