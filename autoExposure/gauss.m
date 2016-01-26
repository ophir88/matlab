function [y] = gauss(x,mean,var)
amp = 1 / ((2 * pi)^(1 / 2) * var);
y = amp * exp((-(x - mean)^2) / (2 * var^2));
end
