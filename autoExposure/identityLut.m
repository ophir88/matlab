
LUT = zeros(64,64,3);
% 
% cube = zeros(8,8,3);
% for i = 1 : 8
%     for j = 1:8
%         cube(i,j,1) = i / 8;
%          cube(i,j,2)= j / 8;
%     end
% end
% for i = 1 : 8
%     for j = 1:8
%         currentCube = cube;
%         currentCube(:,:,3) = ((i-1)*8 + j)/64;
%         LUT((i-1)*8 + 1:i*8,(j-1)*8 + 1:j*8,:) = currentCube;
%     end
% end 
% % figure; imshow(LUT);
% % imwrite(LUT,'identityLUT.png')
LUT = im2double(imread('identityLUT.png'));
LUT50Vibrance = im2double(imread('identityLUT5.png'));
LUT100Vibrance = im2double(imread('identityLUT10.png'));
diff = LUT100Vibrance(:,:,1) - LUT(:,:,1);
figure; imshow(diff);
% figure;
% subplot(1,2,1); imshow(LUT50Vibrance);
% subplot(1,2,2); imshow(LUT100Vibrance);


figure; imshow(LUT50Vibrance-LUT);
figure; imshow(LUT100Vibrance-LUT);