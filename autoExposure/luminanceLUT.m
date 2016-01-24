function [ lut ] = luminanceLUT( )
%LUMINANCELUT Summary of this function goes here
%   Detailed explanation goes here

lut = zeros(1,255);
step = 25;
for i = 1 : 10
    lut(1,(i-1)*step + 1 : i*step) = i;
end
lut(1,250:255) = 10;
end

