function  result  = applyCurves(curves, x )
%ENLIGHTCURVES Summary of this function goes here
%   Detailed explanation goes here
result = 0:1/255:1;
[r, c] = size(curves);
for i = 1 : c
   result = result + (curves(:, i) .* x(i))';    
end
end