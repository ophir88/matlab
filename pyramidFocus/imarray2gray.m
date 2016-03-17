function grayImageArray = imarray2gray(inputArray)
%convert an array of images to grayscale
[r, c, k, Nimages] = size(inputArray);

if k == 1
  grayImageArray = inputArray;
  return
end

grayImageArray = zeros(r, c, 1, Nimages);
for j=1:Nimages
  grayImageArray(:,:,:,j) = rgb2gray(inputArray(:,:,:,j));
end
end