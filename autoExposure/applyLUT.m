function res = applyLUT(img, lut)
%APPLYLUT apply lut on img

method = 'linear';
x = (1:length(lut))./length(lut);

c = size(img, 3);
res = zeros(size(img));
for i = 1:c
    temp = img(:,:,i);
    temp = interp1(x, lut, temp(:), method);
    res(:,:,i) = reshape(temp, size(img(:,:,i)));
end

end

