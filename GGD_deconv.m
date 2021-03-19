clear
close all

fsResample = 16000;

[sig, fs] = audioread('./input/observedMixture.wav'); % signal x channel x source (source image)
sig_resample(:,1) = resample(sig(:,1), fsResample, fs, 100); % resampling for reducing computational cost
sig_resample(:,2) = resample(sig(:,2), fsResample, fs, 100); % resampling for reducing computational cost