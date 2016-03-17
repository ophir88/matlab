function save_image_array(imageArray, imageNames, format)
if ~exist('format','var')
  format = 'JPG';
end
Nimages=size(imageArray,4);
assert(length(imageNames) == Nimages)

for j=1:Nimages
  imwrite(imageArray(:,:,:,j),[imageNames{j} '.' format],format)
end

end