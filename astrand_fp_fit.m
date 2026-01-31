%% Fractional Polynomial Model Comparison
% FP(1) vs FP(2), FP(2) as baseline
% Equations, statistics, and tests shown in a side panel

clear; clc;

%% ===================== Data =====================
t = [24; 30; 40; 50; 60; 70];
y = [1.1; 1.0; 0.87; 0.83; 0.78; 0.75];

n = length(t);
TSS = sum((y - mean(y)).^2);

powers = [-2 -1 -0.5 0 0.5 1 2 3];   % 0 = log(t)

%% ===================== FP(1) =====================
bestRSS1 = Inf;

for i = 1:length(powers)
    p = powers(i);
    z = (p == 0).*log(t) + (p ~= 0).*t.^p;

    X = [ones(n,1), z];
    beta = X \ y;
    RSS = sum((y - X*beta).^2);

    if RSS < bestRSS1
        bestRSS1  = RSS;
        bestBeta1 = beta;
        bestPower1 = p;
    end
end

Dev1 = n * log(bestRSS1 / n);
R2_1 = 1 - bestRSS1 / TSS;
k1 = 2;

%% ===================== FP(2) =====================
bestRSS2 = Inf;

for i = 1:length(powers)
    for j = i:length(powers)

        p1 = powers(i);
        p2 = powers(j);

        z1 = (p1 == 0).*log(t) + (p1 ~= 0).*t.^p1;
        z2 = (p2 == 0).*log(t) + (p2 ~= 0).*t.^p2;

        if p1 == p2
            z2 = z1 .* log(t);
        end

        X = [ones(n,1), z1, z2];
        beta = X \ y;
        RSS = sum((y - X*beta).^2);

        if RSS < bestRSS2
            bestRSS2  = RSS;
            bestBeta2 = beta;
            bestPowers2 = [p1 p2];
        end
    end
end

Dev2 = n * log(bestRSS2 / n);
R2_2 = 1 - bestRSS2 / TSS;
k2 = 3;

%% ===================== Model comparison =====================
DeltaDev = Dev2 - Dev1;          % FP(2) − FP(1)
LR = -DeltaDev;
df = k2 - k1;
pValue = 1 - chi2cdf(LR, df);

AIC1 = Dev1 + 2*k1;   AIC2 = Dev2 + 2*k2;
BIC1 = Dev1 + k1*log(n); BIC2 = Dev2 + k2*log(n);

DeltaAIC = AIC1 - AIC2;
DeltaBIC = BIC1 - BIC2;

%% ===================== Predictions =====================
t_fit = linspace(min(t), max(t), 300)';

% FP(1)
z1 = (bestPower1 == 0).*log(t_fit) + (bestPower1 ~= 0).*t_fit.^bestPower1;
y_fit1 = [ones(size(t_fit)), z1] * bestBeta1;

% FP(2)
p1 = bestPowers2(1); p2 = bestPowers2(2);
u1 = (p1 == 0).*log(t_fit) + (p1 ~= 0).*t_fit.^p1;
u2 = (p2 == 0).*log(t_fit) + (p2 ~= 0).*t_fit.^p2;
if p1 == p2
    u2 = u1 .* log(t_fit);
end
y_fit2 = [ones(size(t_fit)), u1, u2] * bestBeta2;

%% ===================== Equation strings =====================
% FP(1)
b0 = bestBeta1(1); b1 = bestBeta1(2);
if bestPower1 == 0
    eqFP1 = sprintf('y = %.3f + %.3f log(t)', b0, b1);
else
    eqFP1 = sprintf('y = %.3f + %.3f t^{%.1f}', b0, b1, bestPower1);
end

% FP(2)
c0 = bestBeta2(1); c1 = bestBeta2(2); c2 = bestBeta2(3);
p1 = bestPowers2(1); p2 = bestPowers2(2);

if p1 == p2
    if p1 == 0
        eqFP2 = sprintf('y = %.3f + %.3f log(t) + %.3f log(t)^2', c0, c1, c2);
    else
        eqFP2 = sprintf('y = %.3f + %.3f t^{%.1f} + %.3f t^{%.1f}log(t)', ...
                        c0, c1, p1, c2, p2);
    end
else
    term1 = ternary(p1==0, 'log(t)', sprintf('t^{%.1f}', p1));
    term2 = ternary(p2==0, 'log(t)', sprintf('t^{%.1f}', p2));
    eqFP2 = sprintf('y = %.3f + %.3f %s + %.3f %s', ...
                    c0, c1, term1, c2, term2);
end

%% ===================== Figure with side panel =====================
figure;
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');

% ---- Left: plot ----
nexttile;
scatter(t, y, 60, 'filled'); hold on;
plot(t_fit, y_fit1, '--', 'LineWidth', 2);
plot(t_fit, y_fit2, '-',  'LineWidth', 2);
xlabel('t'); ylabel('y');
grid on;
legend('Observed','FP(1)','FP(2)','Location','northeast');
title('Fractional Polynomial Fits');

% ---- Right: results panel ----
nexttile;
axis off;

panelText = sprintf([ ...
    'FRACTIONAL POLYNOMIAL MODELS\n\n' ...
    'FP(1) EQUATION:\n  %s\n\n' ...
    'FP(2) EQUATION:\n  %s\n\n' ...
    'MODEL FIT\n' ...
    '  FP(1): R^2 = %.4f, Dev = %.3f\n' ...
    '  FP(2): R^2 = %.4f, Dev = %.3f\n\n' ...
    'LIKELIHOOD RATIO TEST (FP(2) baseline)\n' ...
    '  LR = %.3f (df = %d)\n  p-value = %.4g\n\n' ...
    'INFORMATION CRITERIA (relative to FP(2))\n' ...
    '  ΔAIC = %.3f\n  ΔBIC = %.3f'], ...
    eqFP1, eqFP2, ...
    R2_1, Dev1, R2_2, Dev2, ...
    LR, df, pValue, ...
    DeltaAIC, DeltaBIC);

text(0, 1, panelText, 'VerticalAlignment','top', ...
     'FontName','Courier','FontSize',10);

%% ===================== Helper function =====================
function out = ternary(cond, a, b)
    if cond
        out = a;
    else
        out = b;
    end
end
