% HRmax vs Age: comparison of published equations (including sex-specific)

clear; clc;

%% Age range
age = (10:1:90)';

%% Published equations
% -------------------------------------------------
% General / mixed-sex
hr_220      = 220 - age;                    % Traditional
hr_tanaka  = 208 - 0.7  .* age;             % Tanaka et al. (2001)
hr_gellish = 206.9 - 0.67 .* age;            % Gellish et al. (2007)
hr_nes     = 211  - 0.64 .* age;             % Nes et al. (2013)
hr_inbar   = 205.8 - 0.685 .* age;           % Inbar et al. (1994)
hr_miller  = 217  - 0.85 .* age;             % Miller et al. (1993)

% Sex-specific
hr_gulati_w = 206 - 0.88 .* age;             % Gulati et al. (2010), women
hr_nes_m   = 211 - 0.64 .* age;               % Nes et al., men
hr_nes_w   = 212 - 0.64 .* age;               % Nes et al., women
% -------------------------------------------------

%% Plot
figure; hold on;

plot(age, hr_220,      'k--', 'LineWidth', 1.5);
plot(age, hr_tanaka,  'b-',  'LineWidth', 2.5);
plot(age, hr_gellish, 'c-',  'LineWidth', 1.5);
plot(age, hr_nes,     'm-',  'LineWidth', 1.5);
plot(age, hr_inbar,   'g-',  'LineWidth', 1.5);
plot(age, hr_miller,  'r-',  'LineWidth', 1.5);

plot(age, hr_gulati_w,'r--', 'LineWidth', 2.0);
plot(age, hr_nes_m,  'b--', 'LineWidth', 1.5);
plot(age, hr_nes_w,  'c--', 'LineWidth', 1.5);

%% Formatting
xlabel('Age (years)');
ylabel('HR_{max} (beats·min^{-1})');
title('Maximum Heart Rate vs Age: Published Equations');

legend({ ...
    '220 - Age', ...
    'Tanaka (2001)', ...
    'Gellish (2007)', ...
    'Nes (2013)', ...
    'Inbar (1994)', ...
    'Miller (1993)', ...
    'Gulati (2010) – Women', ...
    'Nes – Men', ...
    'Nes – Women'}, ...
    'Location', 'southwest');

grid on;
xlim([10 90]);

