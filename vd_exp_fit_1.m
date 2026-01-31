%% ================================================================
%  Fit y = a*exp(b*t) + c using three initialization strategies
%  and finalize with nonlinear least squares (lsqcurvefit). 
%  work in progress in connection with Astrand fit for women in
%  Van Dobeln model of VO2 heart rate
%  beta 1 (18/02/17)
%  beta 1.1 (23/01/26) 
%  ---------------------------------------------------------------
%  Author: Alun Hughes
%  ================================================================

clear; clc;

%% ---------------------------------------------------------------
%  Example data (replace with your own)
%  ---------------------------------------------------------------
t = [-1; 0; 1; 2; 3];
y = [0.418; 0.911; 3.544; 9.02; 22.1];

%% ---------------------------------------------------------------
%  Model function
%  ---------------------------------------------------------------
model = @(p,t) p(1).*exp(p(2).*t) + p(3);   % p = [a b c]

%% ================================================================
%  STRATEGY A: Fix b, solve for a and c linearly
%  ================================================================
b_grid = linspace(-1, 3, 200);   % search range for b
SSQ_b = zeros(size(b_grid));
ac_vals = zeros(length(b_grid), 2);

for k = 1:length(b_grid)
    b = b_grid(k);
    Z = [exp(b*t), ones(size(t))];   % linear in a and c
    ac = Z \ y;                      % least squares
    a = ac(1); 
    c = ac(2);

    SSQ_b(k) = sum((y - model([a b c], t)).^2);
    ac_vals(k,:) = [a c];
end

[~, idx_b] = min(SSQ_b);
b0_A = b_grid(idx_b);
a0_A = ac_vals(idx_b,1);
c0_A = ac_vals(idx_b,2);

fprintf('\nStrategy A (fix b): a0=%.4f, b0=%.4f, c0=%.4f\n', a0_A, b0_A, c0_A);


%% ================================================================
%  STRATEGY B: Fix c, solve for a and b via log transform
%  ================================================================
c_grid = linspace(min(y)-0.1, min(y)-0.001, 200);  % c must be < min(y)
SSQ_c = zeros(size(c_grid));
ab_vals = zeros(length(c_grid), 2);

for k = 1:length(c_grid)
    c = c_grid(k);
    if any(y - c <= 0)
        SSQ_c(k) = Inf;
        continue
    end

    w = log(y - c);
    W = [t, ones(size(t))];
    params = W \ w;

    b = params(1);
    a = exp(params(2));

    SSQ_c(k) = sum((y - model([a b c], t)).^2);
    ab_vals(k,:) = [a b];
end

[~, idx_c] = min(SSQ_c);
c0_B = c_grid(idx_c);
a0_B = ab_vals(idx_c,1);
b0_B = ab_vals(idx_c,2);

fprintf('Strategy B (fix c): a0=%.4f, b0=%.4f, c0=%.4f\n', a0_B, b0_B, c0_B);


%% ================================================================
%  STRATEGY C: Three-point closed-form estimate
%  ================================================================
% Use first three points (must be equally spaced in t)
t1=t(1); t2=t(2); t3=t(3);
y1=y(1); y2=y(2); y3=y(3);

b0_C = (1/(t3 - t1)) * log((y3 - y2)/(y2 - y1));
a0_C = (y2 - y1) / (exp(b0_C*t2) - exp(b0_C*t1));
c0_C = y1 - a0_C*exp(b0_C*t1);

fprintf('Strategy C (3-point): a0=%.4f, b0=%.4f, c0=%.4f\n', a0_C, b0_C, c0_C);


%% ================================================================
%  FINAL NONLINEAR FIT (choose best initialization)
%  ================================================================
% Compare SSQ of the three initial guesses
pA = [a0_A, b0_A, c0_A];
pB = [a0_B, b0_B, c0_B];
pC = [a0_C, b0_C, c0_C];

SSQ_A = sum((y - model(pA,t)).^2);
SSQ_B = sum((y - model(pB,t)).^2);
SSQ_C = sum((y - model(pC,t)).^2);

[~, bestIdx] = min([SSQ_A, SSQ_B, SSQ_C]);
p0_all = [pA; pB; pC];
p0 = p0_all(bestIdx,:);

fprintf('\nBest initialization chosen: [%f %f %f]\n', p0);

%% ---------------------------------------------------------------
%  Run lsqcurvefit
%  ---------------------------------------------------------------
opts = optimoptions('lsqcurvefit','Display','iter');
p_final = lsqcurvefit(model, p0, t, y, [], [], opts);

fprintf('\nFinal fit parameters:\n');
fprintf('a = %.6f\nb = %.6f\nc = %.6f\n', p_final);

%% ---------------------------------------------------------------
%  Plot results
%  ---------------------------------------------------------------
tt = linspace(min(t), max(t), 200);
yy = model(p_final, tt);

figure; hold on;
plot(t, y, 'ko', 'MarkerFaceColor','k');
plot(tt, yy, 'r-', 'LineWidth', 2);
xlabel('t'); ylabel('y');
title('Fit of y = a e^{bt} + c');
legend('Data','Nonlinear Fit');
grid on;