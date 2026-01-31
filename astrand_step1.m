%% plot_astrand_step.m
% Plot VO2max estimates for 20 cm, 24 spm step test
% over HR range 40–120 bpm
%% 
clear; clc;

% --- Fixed submaximal VO2 for this protocol ---
VO2_sub = 19.8;   % mL·kg^-1·min^-1

% --- User age ---
age = 30;   % change this if needed

% --- Age correction factor (Astrand) ---
if age < 25
    cf = 1.10;
elseif age < 35
    cf = 1.00;
elseif age < 45
    cf = 0.87;
elseif age < 55
    cf = 0.83;
elseif age < 65
    cf = 0.78;
else
    cf = 0.75;
end

% --- HR range ---
HR = 40:120;

% --- Age‑predicted HRmax ---
HR_max = 220 - age;

% --- VO2max estimate across HR range ---
VO2max = VO2_sub .* (HR_max ./ HR) * cf;

% --- Plot ---
figure;
plot(HR, VO2max, 'LineWidth', 2);
grid on;
xlabel('Steady-state HR (bpm)');
ylabel('Estimated VO2_{max} (mL·kg^{-1}·min^{-1})');
title('Astrand–Ryhming Step Test VO2_{max} Estimate (20 cm, 24 spm)');
