% Data
t = [24; 30; 40; 50; 60; 70];
y = [1.1; 1.0; 0.87; 0.83; 0.78; 0.75];

% Model
model = @(p, t) p(1) .* exp(-p(3).* t);

% Initial guess
b0 = [1.0, 120, 0.01];
lb = [0, 60.0001, 0];

opts = optimoptions('lsqcurvefit', 'Display', 'off');
[p_hat, ~] = lsqcurvefit(model, b0, t, y, lb, [], opts);

% Extract parameters
a_hat = p_hat(1);
x_hat = p_hat(3);

% R^2
y_hat = model(p_hat, t);
R2 = 1 - sum((y-y_hat).^2)/sum((y-mean(y)).^2);

% Create figure
figure;

% Left panel (larger)
ax1 = axes('Position',[0.07 0.15 0.65 0.75]);  % [left bottom width height]
scatter(ax1, t, y, 60, 'filled'); hold(ax1, 'on');
t_fit = linspace(min(t), max(t), 200)';
plot(ax1, t_fit, model(p_hat, t_fit), 'LineWidth', 2);
xlabel(ax1,'t'); ylabel(ax1,'y'); grid(ax1,'on');
legend(ax1,'Observed','Fitted','Location','northeast');

% Right panel (smaller)
ax2 = axes('Position',[0.78 0.15 0.20 0.75]); % smaller width
axis(ax2, 'off');

eqnStr = sprintf('$factor = %.3f \\cdot e^{-(%.5f)\\,t}$', a_hat, x_hat);
r2Str  = sprintf('$R^2 = %.4f$', R2);

text(ax2, 0.05, 0.6, eqnStr, 'FontSize', 12, 'Interpreter', 'latex');
text(ax2, 0.05, 0.4, r2Str,  'FontSize', 12, 'Interpreter', 'latex');
title(ax2, 'Model Summary');
