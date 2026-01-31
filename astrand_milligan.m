% compare_vo2_predictions.m
% Compare VO2max predictions:
% 1) Astrand–Ryhming step test (20 cm, 24 spm)
% 2) Updated regression equation:
%    VO2max = 84.687 - 0.722*(HR/2) - 0.383*age

clear; clc;

% --- User age ---
age = 40;   % fixed age

% --- HR range ---
HR = 40:120;

% ---------------------------------------------------------
% 1) Astrand–Ryhming step-test prediction
% ---------------------------------------------------------

% Fixed VO2 at this workload (20 cm, 24 spm)
VO2_sub = 19.8;   % mL·kg^-1·min^-1

% Age-predicted HRmax
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

% Astrand VO2max estimate across HR range
VO2_astrand = VO2_sub .* (HR_max ./ HR) * cf;

% ---------------------------------------------------------
% 2) Updated regression equation prediction
% ---------------------------------------------------------

VO2_reg = 84.687 - 0.722 .* (HR/2) - 0.383 .* age;

% ---------------------------------------------------------
% Plot comparison
% ---------------------------------------------------------

figure;
plot(HR, VO2_astrand, 'LineWidth', 2); hold on;
plot(HR, VO2_reg, 'LineWidth', 2);
grid on;

xlabel('Steady-state HR (bpm)');
ylabel('Estimated VO2_{max} (mL·kg^{-1}·min^{-1})');
title('Comparison of VO2_{max} Prediction Methods (Age = 40)');

legend('Astrand–Ryhming Step Test', 'Updated Regression Equation', ...
       'Location', 'northeast');