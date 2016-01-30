function [ result ] = sCruveImg( img, shadow, highlight )
%SCRUVEIMG Summary of this function goes here
%   Detailed explanation goes here

result = img + shadow*fd(img) + highlight*fd(1-img);

end


function [incremented] = fd(values)
k1 = 5;
k2 = 14;
k3 = 1.6;
incremented = k1 .* values .* exp (-k2 .*( values .^ k3));
end