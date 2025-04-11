function [fitresult, gof] = createFit(VarName1, VarName2)

%% Fit: 'glass'.
[xData, yData] = prepareCurveData( VarName1, VarName2 );

% Set up fittype and options.
ft = fittype( 'power2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.193772091984024 0.603452176527001 0.00505911845987706];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'glass' );
h = plot( fitresult, xData, yData );
legend( h, 'VarName2 vs. VarName1', 'glass', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'VarName1', 'Interpreter', 'none' );
ylabel( 'VarName2', 'Interpreter', 'none' );
grid on


