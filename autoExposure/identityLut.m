% 
% LUT = zeros(64,64,3);
% % 
% % cube = zeros(8,8,3);
% % for i = 1 : 8
% %     for j = 1:8
% %         cube(i,j,1) = i / 8;
% %          cube(i,j,2)= j / 8;
% %     end
% % end
% % for i = 1 : 8
% %     for j = 1:8
% %         currentCube = cube;
% %         currentCube(:,:,3) = ((i-1)*8 + j)/64;
% %         LUT((i-1)*8 + 1:i*8,(j-1)*8 + 1:j*8,:) = currentCube;
% %     end
% % end 
% % % figure; imshow(LUT);
% % % imwrite(LUT,'identityLUT.png')
% LUT = rgb2hsv(im2double(imread('identityLUT.png')));
% % LUTVec = zeros(8,64*8,3);
% % for i = 1 : 8
% %     for j = 1:8
% %         currentCube = LUT((i-1)*8 + 1:i*8,(j-1)*8 + 1:j*8,:);
% %         LUTVec(:,(64*(j-1) + 1) + (i-1)*8 + 1: 64*(j-1) + 1 + i*8, :) = currentCube;
% %     end
% % end 
% % figure; imshow(LUTVec(:,:,2));
% LUTS = LUT(:,:,2);
% [LUTSsorted, I] = sort(reshape(LUTS,1,64*64));
% 
% LUT50Vibrance = rgb2hsv(im2double(imread('identityLUT5.png')));
% LUT100Vibrance = rgb2hsv(im2double(imread('identityLUT10.png')));
% diff = LUT100Vibrance(:,:,2) - LUTS;
% diffReshaped = reshape(diff,1,64*64);
% diffReshapedSorted = diffReshaped(I);
% lutSampled = zeros(1,256);
% index = 1;
% for i = 1 : 16 : 4096
%     lutSampled(1,index) = diffReshapedSorted(1,i);
%     index = index + 1;
% end
% lutSampled = smooth(lutSampled, 40);
% figure; plot(lutSampled);
% figure;
% ax1 = subplot(1,2,1); imshow(LUTS);
% ax2 = subplot(1,2,2); imshow(diff);
% linkaxes([ax1 ax2],'xy')
% 
% 
% figure; imshow(LUT50Vibrance-LUT);
% figure; imshow(LUT100Vibrance-LUT);
x = -127/256 : 1/256 : 128/256;
x = (0.25 + -x.^2) .* 1.5;
x = im2uint8(x);
% x = repmat(x, [1,1,3])
imwrite(x,'vibranceLUT.png');
figure; plot(x);


% imwrite(x,'vibranceLUT.png');
