clear; clc;

% --- User parameters ---
weight = 75;    % kg
step   = 0.2;   % 20 cm
freq   = 24;    % steps/min

% --- HR and Age ranges ---
HR  = 70:130;
AGE = 20:70;

[HRg, AGEg] = meshgrid(HR, AGE);

% ---------------------------------------------------------
% Mechanical load
% ---------------------------------------------------------
load_kgm_min = 1.33 * (step * freq * weight);

% ---------------------------------------------------------
% 1) Astrand–Ryhming
% ---------------------------------------------------------
VO2_sub = 19.8;

% Smooth age correction factor
cf = 0.566 + 12.825 ./ AGEg;

HRmax = 220 - AGEg;
VO2_astrand = VO2_sub .* (HRmax ./ HRg) .* cf;

% ---------------------------------------------------------
% 2) Milligan equation
% ---------------------------------------------------------
VO2_reg = 84.687 - 0.722 .* (HRg/2) - 0.383 .* AGEg;

% ---------------------------------------------------------
% 3) Sharkey equation
% ---------------------------------------------------------
sharkeyfactor = 1/2;
maxpulse = 64.83 + 0.662 .* HRg;

VO2_s_ml = sharkeyfactor * 3.744 .* (weight + 5) ./ (maxpulse - 62);
VO2_sharkey = VO2_s_ml * 1000 / weight;

% ---------------------------------------------------------
% 4) Van Dobeln equation
% ---------------------------------------------------------
VO2_ml = 1.29 .* sqrt(load_kgm_min ./ (maxpulse - 60)) .* exp(-0.0088 .* AGEg);
VO2_vandobeln = VO2_ml * 1000 / weight;

% ---------------------------------------------------------
% Combined surface plot with primary colors
% ---------------------------------------------------------
figure; hold on;

s1 = surf(HRg, AGEg, VO2_astrand);
s1.FaceColor = [1 0 0];   % red
s1.FaceAlpha = 0.45;
s1.EdgeColor = 'none';

s2 = surf(HRg, AGEg, VO2_reg);
s2.FaceColor = [0 0 1];   % blue
s2.FaceAlpha = 0.45;
s2.EdgeColor = 'none';

s3 = surf(HRg, AGEg, VO2_sharkey);
s3.FaceColor = [0 1 0];   % green
s3.FaceAlpha = 0.45;
s3.EdgeColor = 'none';

s4 = surf(HRg, AGEg, VO2_vandobeln);
s4.FaceColor = [1 1 0];   % yellow
s4.FaceAlpha = 0.45;
s4.EdgeColor = 'none';

xlabel('Heart rate (bpm)');
ylabel('Age (years)');
zlabel('VO2_{max} (mL·kg^{-1}·min^{-1})');
title('Combined VO2_{max} Prediction Surfaces (Primary Colors)');

legend({'Astrand–Ryhming','Milligan','Sharkey','Van Dobeln'}, ...
       'Location','northeast');

grid on;
view(45,30);
