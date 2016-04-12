function [sigma]=AjaNE(I,Nb)

%Aja Noise estimation in 2D MR images using Aja's method 
%
% The mode of some histogram is calculated
%
%  Inputs: 
%       I: (double) image with Rayleigh background
%       N: Size of window to estimate local square mean (size=NxN)
%       Nb: Number of beens in the histogram
%       method:
%           1: histogram
%           2: mean
%           3: Second order moment 
%           4: Square root of second order moment
%
% Methods from:
%
% Aja-Fernandez, S. Noise and Signal Estimation in Magnitude MRI and 
% Rician Distributed Images: A LMMSE Approach 
% Image Processing, IEEE Transactions on, Volume: 17 , Issue: 8  2008
%
% Author: Santiago Aja Fernandez
% NOISE ESTIMATION IN MRI TOOLBOX 
%
% Modified: Oct 02 2008
     sigma=moda(I,Nb);
     sigma=moda(I(I<2.*sigma),Nb);
end


