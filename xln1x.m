%% bit of code to show the relationship between ln(1+x) vs x 
% compared with the line of unity (y = x) - checking re MCF, stress and
% strain analysis
%% Define the range 
x = linspace(0.3, 0.9, 100);

% Calculate ln(1+x)
y = log(1 + x);

% Create the plot
figure;
plot(x, y, 'b-', 'LineWidth', 2);
hold on;
plot(x, x, 'r--', 'LineWidth', 2);
grid on;
xlabel('x');
ylabel('y');
title('Plot of ln(1+x) vs x with Line of Unity');
legend('y = ln(1+x)', 'y = x', 'Location', 'best');
hold off;

ratio = y./x;

