function [ result ] = enlightCurveError( x, T )
%ENLIGHTCURVEERROR Summary of this function goes here
%   Detailed explanation goes here
identity = 0:1/255:1;
result = norm(enlightCurve(x, identity )-T,2);
end

