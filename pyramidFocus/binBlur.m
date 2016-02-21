function [ output ] = binBlur( input , kernelSize )
%BINBLUR Summary of this function goes here
%   Detailed explanation goes here

output = zeros(size(input));
    H = fspecial('disk',kernelSize);
for i = 0.1 : 0.1 : 1.1
   temp = input;
   idx = input >= (i - 0.1) & (input < i);
   temp(~idx) = 0;
   output = output + imfilter(temp,H);
end


