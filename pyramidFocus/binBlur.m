function [ output ] = binBlur( input , kernelSize )
%BINBLUR Summary of this function goes here
%   Detailed explanation goes here

output = zeros(size(input));
    H = fspecial('disk',kernelSize);
for i = 0.1 : 0.1 : 1.1
   temp = zeros(size(input));
   idx = input >= (i - 0.1) && (input < i);
   temp = temp + input(idx);
   output(idx) = output(idx) + imfilter(temp,H,'replicate');
end


