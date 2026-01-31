function hr_max_meta_reml
clear; clc;

%% Study equations (mixed-sex only)
studies = table( ...
    [220;   208;   206.9; 211;   205.8; 217], ...
    [-1.0; -0.7;  -0.67;  -0.64; -0.685; -0.85], ...
    [1000; 18000; 400;    3300;  140;    120], ...
    'VariableNames', {'beta0','beta1','N'});

k = height(studies);

%% Use plausible SEs
SE_beta0 = [5; 5; 5; 5; 5; 5];
SE_beta1 = [0.05; 0.05; 0.05; 0.05; 0.05; 0.05];

%% Within-study variance
V = cell(k,1);
for i = 1:k
    V{i} = diag([SE_beta0(i)^2, SE_beta1(i)^2]);
end

%% Stack outcomes
Y = [studies.beta0, studies.beta1]';

%% REML estimation
obj = @(p) reml_obj(p, Y, V);

p0 = [log(10), 0, log(0.1)];
options = optimset('Display','off', 'MaxIter', 1000, 'TolX', 1e-8, 'TolFun', 1e-8);

p_hat = fminsearch(obj, p0, options);
Psi = buildPsi(p_hat);

[beta_hat, Vbeta] = reml_beta(Y, V, Psi);

fprintf('\nREML Results\n');
disp(Psi);

%% Plot
age = (10:1:90)';

eq = {
    '220 - age',        220,   -1.0;
    'Tanaka (2001)',    208,   -0.7;
    'Gellish (2007)',   206.9, -0.67;
    'Nes (2013)',       211,   -0.64;
    'Inbar (1994)',     205.8, -0.685;
    'Miller (1993)',    217,   -0.85
};

figure; hold on;

% Compute pooled curve
hr_pooled = beta_hat(1) + beta_hat(2) .* age;

% 95% confidence band for pooled curve
X = [ones(length(age),1), age];
se_fit = sqrt(sum((X * Vbeta) .* X, 2));

h_band = fill([age; flipud(age)], ...
     [hr_pooled + 1.96*se_fit; flipud(hr_pooled - 1.96*se_fit)], ...
     [0.9 0.9 0.9], 'EdgeColor','none');

set(h_band, 'HandleVisibility', 'off');
alpha(h_band, 0.4);

% Plot individual equations
h = gobjects(size(eq,1),1);
for i = 1:size(eq,1)
    h(i) = plot(age, eq{i,2} + eq{i,3} .* age, 'LineWidth', 2);
end

% Pooled curve
h_pooled = plot(age, hr_pooled, 'k', 'LineWidth', 3);

xlabel('Age (years)');
ylabel('HR_{max} (beats/min)');
title('Pooled HRmax-Age Curve vs Individual Equations');

legend([h; h_pooled], ...
       [eq(:,1); {'Pooled (REML)'}], ...
       'Location','northeast');

grid on;
xlim([10 90]);
hold off;

end


function Psi = buildPsi(p)
    a = p(1); b = p(2); c = p(3);
    L = [exp(a) 0; b exp(c)];
    Psi = L*L';
end

function nll = reml_obj(p, Y, V)
    Psi = buildPsi(p);
    [~, ~, nll] = reml_beta(Y, V, Psi);
end

function [beta_hat, Vbeta, negloglik] = reml_beta(Y, V, Psi)
    k = size(Y,2);
    p = 2;

    Wsum = zeros(p,p);
    Wy = zeros(p,1);
    negloglik = 0;

    for i = 1:k
        Sigma = Psi + V{i};
        invSigma = inv(Sigma);
        Wsum = Wsum + invSigma;
        Wy   = Wy   + invSigma * Y(:,i);
        negloglik = negloglik + log(det(Sigma)) + Y(:,i)' * invSigma * Y(:,i);
    end

    beta_hat = Wsum \ Wy;
    Vbeta = inv(Wsum);

    negloglik = 0.5 * (negloglik + log(det(Wsum)));
end
