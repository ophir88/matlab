function [ result ] = enlightCurveError( x, T )
%ENLIGHTCURVEERROR Summary of this function goes here
%   Detailed explanation goes here
result = norm(enlightCurve(x, 0)-T,2);
end

