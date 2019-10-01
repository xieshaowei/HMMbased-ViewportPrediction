function [fitresult, gof] = createFit(a, b)
%CREATEFIT(A,B)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : a
%      Y Output: b
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  Refer to FIT, CFIT, SFIT for more details.
%  Automatic Generation with MATLAB.

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( a, b );

% Set up fittype and options.
ft = fittype( 'gauss2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0 -Inf -Inf 0];
opts.StartPoint = [1.44417937187856 0.0142937811442652 0.195477818032767 0.477169276933281 0.327826474749125 0.314682539036896];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData );
% legend( h, 'b vs. a', 'untitled fit 1', 'Location', 'NorthEast' );



