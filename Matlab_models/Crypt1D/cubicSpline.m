function [y, yd, ydd, abc] = cubicSpline(x, xj, fj)
% Fits a 1-D cubic spline
%Inputs:
% x = column vector of points to be interpolated at
% xj = column vector of x-coordinates of data points
% fj = vector of same length as xj, function values at each xj
%Outputs:
% y = Value of spline at each x
% yd = derivative/slope of spline at each x
% ydd = second derivative of spline at each x
% abc = coefficients of spline model
%
%Scott Carnie-Bronca, 30/08/18
N = length(xj);
A = [ones(N,1) xj abs(xj - xj(2:N-1)').^3];
abc = A\fj;
y = abc(1) + abc(2)*x + abs(x - xj(2:N-1)').^3*abc(3:N);
yd = abc(2) + 3*sign(x - xj(2: N-1)').*(x - xj(2:N-1)').^2*abc(3:N);
ydd = 6*abs(x - xj(2:N-1)')*abc(3:N);
end