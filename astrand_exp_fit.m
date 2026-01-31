% Data
t = [24; 30; 40; 50; 60; 70];
y = [1.1; 1.0; 0.87; 0.83; 0.78; 0.75];

% load constant
load = 480;

% Model: y = a * sqrt(load/(b-60)) * exp(-x * t)
model = @(p, t) p(1) .* sqrt(load ./ (p(2) - 60)) .* exp(-p(3).* t);

% Initial guess
b0 = [1.0, 120, 0.01];
lb = [0, 60.0001, 0];

opts = optimoptions('lsqcurvefit', 'Display', 'off');
[p_hat, ~] = lsqcurvefit(model, b0, t, y, lb, [], opts);

% Extract parameters
a_hat = p_hat(1);
b_hat = p_hat(2);
x_hat = p_hat(3);

% R^2
y_hat = model(p_hat, t);
R2 = 1 - sum((y-y_hat).^2)/sum((y-mean(y)).^2);

% Plot + side panel
figure;

subplot(1,2,1);
scatter(t, y, 60, 'filled'); hold on;
t_fit = linspace(min(t), max(t), 200)';
plot(t_fit, model(p_hat, t_fit), 'LineWidth', 2);
xlabel('t'); ylabel('y'); grid on;
legend('Observed','Fitted','Location','northeast');

subplot(1,2,2);
axis off;

% Correct equation string (LaTeX)
eqnStr = sprintf(['Equation: $VO_2max = %.3f \\cdot \\sqrt{\\frac{%d}{%.3f - 60}} ', ...
                  '\\cdot e^{-(%.5f) t}$'], a_hat, load, b_hat, x_hat);

r2Str  = sprintf('$R^2 = $ %.4f', R2);

text(0.05, 0.6, eqnStr, 'FontSize', 12, 'Interpreter', 'latex');
text(0.05, 0.4, r2Str,  'FontSize', 12, 'Interpreter', 'latex');
title('Model Summary');
