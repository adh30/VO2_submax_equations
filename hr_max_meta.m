%% Multivariate REML meta-analysis of HRmax-age equations
% Cholesky-parameterised random-effects covariance (PD guaranteed)
% No Optimization Toolbox required

clear; clc; close all;


%% ------------------------------------------------------------
% Study equations (mixed-sex only)
% [beta0, beta1, N]
% ------------------------------------------------------------

studies = table( ...
    [220;   208;   206.9; 211;   205.8; 217], ...
    [-1.0; -0.7;  -0.67;  -0.64; -0.685; -0.85], ...
    [1000; 18000; 400;    3300;  140;    120], ...
    'VariableNames', {'beta0','beta1','N'});

k = height(studies);


%% ------------------------------------------------------------
% Within-study covariance (heuristic)
% ------------------------------------------------------------

V = cell(k,1);

for i = 1:k
    v = 1/studies.N(i);
    V{i} = diag([v v]);
end


%% ------------------------------------------------------------
% Stack outcomes
% ------------------------------------------------------------

Y = [studies.beta0, studies.beta1]';   % 2 x k


%% ------------------------------------------------------------
% REML optimisation
% ------------------------------------------------------------

obj = @(p) reml_obj(p, Y, V);

% Initial values (Cholesky params)
p0 = [0 0 0];

options = optimset( ...
    'Display','iter', ...
    'MaxIter',1000, ...
    'TolX',1e-8, ...
    'TolFun',1e-8);

p_hat = fminsearch(obj, p0, options);


%% ------------------------------------------------------------
% Recover Psi
% ------------------------------------------------------------

Lmat = [ exp(p_hat(1))   0 ;
         p_hat(2)     exp(p_hat(3)) ];

Psi = Lmat*Lmat';


%% ------------------------------------------------------------
% Pooled coefficients
% ------------------------------------------------------------

[beta_hat, ~] = reml_beta(Y, V, Psi);


fprintf('\nREML Multivariate Meta-Analysis Results\n');
fprintf('--------------------------------------\n');
fprintf('Pooled intercept (beta0): %.3f\n', beta_hat(1));
fprintf('Pooled slope     (beta1): %.4f\n', beta_hat(2));

fprintf('\nBetween-study covariance (Psi):\n');
disp(Psi);


%% ------------------------------------------------------------
% Plot results
% ------------------------------------------------------------

age = (10:1:90)';

eq = {
    'Fox (1971)',       220,   -1.0;
    'Tanaka (2001)',    208,   -0.7;
    'Gellish (2007)',   206.9, -0.67;
    'Nes (2013)',       211,   -0.64;
    'Inbar (1994)',     205.8, -0.685;
    'Miller (1993)',    217,   -0.85
};

figure; hold on; box on;


% Individual curves
for i = 1:size(eq,1)

    hr = eq{i,2} + eq{i,3}.*age;

    plot(age, hr, 'LineWidth',1.2);

end


% Pooled curve
hr_pool = beta_hat(1) + beta_hat(2).*age;

plot(age, hr_pool, 'k', 'LineWidth',3);


%% ------------------------------------------------------------
% Prediction band
% ------------------------------------------------------------

v0 = Psi(1,1);
v1 = Psi(2,2);
c01 = Psi(1,2);

pred_var = v0 + age.^2.*v1 + 2*age.*c01;

pred_se = sqrt(pred_var);

upper = hr_pool + 1.96*pred_se;
lower = hr_pool - 1.96*pred_se;


fill([age; flipud(age)], ...
     [upper; flipud(lower)], ...
     [0.9 0.9 0.9], ...
     'EdgeColor','none', ...
     'FaceAlpha',0.5);

uistack(findobj(gca,'Type','Line'),'top');


xlabel('Age (years)');
ylabel('HR_{max} (bpm)');
title('REML Meta-Analysis of HRmax–Age Equations');

legend([eq(:,1); ...
       {'Pooled (REML)'; '95% Prediction Band'}], ...
       'Location','northeast');

grid on;
xlim([10 90]);
ylim([120 230]);

hold off;



%% ============================================================
%                     LOCAL FUNCTIONS
% ============================================================

function L = reml_obj(p, Y, V)
% REML objective (Cholesky parameterisation)

    Lmat = [ exp(p(1))   0 ;
             p(2)     exp(p(3)) ];

    Psi = Lmat*Lmat';

    [~, L] = reml_beta(Y, V, Psi);

end


% ------------------------------------------------------------

function [beta_hat, negloglik] = reml_beta(Y, V, Psi)
% REML estimator and likelihood

    k = size(Y,2);
    p = 2;


    %% Stack response

    y = Y(:);


    %% Design matrix

    X = repmat(eye(p), k, 1);


    %% Build W

    W = zeros(2*k);

    for i = 1:k

        Si = V{i} + Psi;

        % Enforce symmetry
        Si = (Si + Si')/2;

        % Cholesky inverse
        Ci = chol(Si,'lower');
        Wi = Ci'\(Ci\eye(2));

        idx = (2*i-1):(2*i);

        W(idx,idx) = Wi;

    end


    %% GLS estimate

    XtW = X'*W;

    beta_hat = (XtW*X)\(XtW*y);


    %% Residuals

    r = y - X*beta_hat;


    %% Determinants (stable)

    Cw = chol(W,'lower');
    logdetW = 2*sum(log(diag(Cw)));

    A = XtW*X;
    Ca = chol(A,'lower');
    logdetA = 2*sum(log(diag(Ca)));

    quad = r'*W*r;


    %% Negative REML log-likelihood

    negloglik = 0.5*( ...
        -logdetW + ...
         logdetA + ...
         quad );

end
