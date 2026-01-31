% compare_vo2_predictions.m
% Compare VO2max predictions:
% 1) Astrand–Ryhming step test (20 cm, 24 spm)
% 2) Updated regression equation
% 3) Sharkey equation

clear; clc;

% --- User parameters ---
age = 40;        % fixed age
weight = 75;     % kg (change if needed)

% --- HR range ---
HR = 40:120;

% ---------------------------------------------------------
% 1) Astrand–Ryhming step-test prediction
% ---------------------------------------------------------

VO2_sub = 19.8;   % mL·kg^-1·min^-1 for 20 cm, 24 spm
HR_max = 220 - age;

% Age correction factor
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

VO2_astrand = VO2_sub .* (HR_max ./ HR) * cf;

% ---------------------------------------------------------
% 2) Updated regression equation
% ---------------------------------------------------------

VO2_reg = 84.687 - 0.722 .* (HR/2) - 0.383 .* age;

% ---------------------------------------------------------
% 3) Sharkey equation
% ---------------------------------------------------------

maxpulse = 64.83 + 0.0662 .* HR;
VO2_sharkey = 3.744 .* ((weight + 5) ./ (maxpulse - 62));

% ---------------------------------------------------------
% Plot comparison
% ---------------------------------------------------------

figure;
plot(HR, VO2_astrand, 'LineWidth', 2); hold on;
plot(HR, VO2_reg, 'LineWidth', 2);
plot(HR, VO2_sharkey, 'LineWidth', 2);

grid on;
xlabel('Steady-state HR (bpm)');
ylabel('Estimated VO2_{max} (mL·kg^{-1}·min^{-1})');
title('Comparison of VO2_{max} Prediction Methods (Age = 40)');

legend('Astrand–Ryhming Step Test', ...
       'Milligan Equation', ...
       'Sharkey Equation', ...
       'Location', 'northeast');