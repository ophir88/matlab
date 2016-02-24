function [ ouput ] = normalize( input )
%NORMALIZE Summary of this function goes here
%   Detailed explanation goes here

sorted = sort(reshape(input,[],1), 'descend');
minVal = mean(sorted(round(length(sorted)*95/100):length(sorted)));
input = (input - minVal);
sorted = sort(reshape(input,[],1), 'descend');
maxVal = mean(sorted(1:round(length(sorted)*5/100)));
ouput = input/ maxVal;
end

