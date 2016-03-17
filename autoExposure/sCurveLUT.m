function [ result ] = sCurveLUT(x, T )
%SCRUVEIMG Summary of this function goes here
%   Detailed explanation goes here
Icurve = 0:1/255:1;
resultCurve= Icurve + x(1)*fd(Icurve) + x(2)*fd(1-Icurve);
result = norm(resultCurve-T,2);
end

function [incremented] = fd(values)
k1 = 5;
k2 = 14;
k3 = 1.6;
incremented = k1 .* values .* exp (-k2 .*( values .^ k3));
end