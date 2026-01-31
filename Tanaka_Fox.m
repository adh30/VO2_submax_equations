% HRmax vs Age: Tanaka prediction interval vs 220 - Age

clear; clc;

%% Age range
age = (10:1:90)';

%% Models
hr_tanaka = 208 - 0.7 .* age;   % Tanaka et al. (2001)
hr_220    = 220 - age;          % Traditional formula

%% 95% Prediction interval for Tanaka
% Standard Error of Estimate (SEE) reported by Tanaka et al.
SEE = 10.8;      % beats per minute
z   = 1.96;      % 95% normal quantile

upper_pi = hr_tanaka + z * SEE;
lower_pi = hr_tanaka - z * SEE;

%% Plot
figure; hold on;

% Shaded prediction interval
fill([age; flipud(age)], ...
     [upper_pi; flipud(lower_pi)], ...
     [0.85 0.90 1.00], ...
     'EdgeColor', 'none', ...
     'FaceAlpha', 0.5);

% Tanaka curve
plot(age, hr_tanaka, 'b-', 'LineWidth', 2);

% 220 - Age curve
plot(age, hr_220, 'r--', 'LineWidth', 2);

%% Formatting
xlabel('Age (years)');
ylabel('HR_{max} (beats·min^{-1})');
title('Maximum Heart Rate vs Age');
legend({'95% prediction interval (Tanaka)', ...
        'Tanaka: 208 - 0.7·Age', ...
        '220 - Age'}, ...
        'Location', 'northeast');

grid on;
xlim([10 90]);

