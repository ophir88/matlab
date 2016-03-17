function [warpedImageArray, supportPixels] = ...
  backwarp_to_ref_iat(images, projectionMatrices, projectionType, refIndex)

if ~exist('refIndex','var')
  refIndex = 1;
end
[r, c, ~, Nimages]=size(images);
warpedImageArray = zeros(size(images));
supportPixels = nan(r,c,Nimages);
tic
for j=1:Nimages
  if j==refIndex
    warpedImageArray(:,:,:,j) = images(:,:,:,j);
    supportPixels(:,:,j) = ones(r,c);
    continue
  end
  [warpedImageArray(:,:,:,j), supportPixels(:,:,j)] = ...
    iat_inverse_warping(images(:,:,:,j), projectionMatrices{j}, projectionType, 1:c, 1:r);
end
fprintf('%s: IAT Backwarping: %g seconds\n',mfilename,toc())
tic
end