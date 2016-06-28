function [new] = grow_tumor(I)
% grows the tumor in the image I

I = imresize(I,0.5);
% I = imresize(rot90(imread('501B_1.tif'),2), .3); % load brain image
% I = imread('410B.tif'); % load brain image
figure('Name','Draw a boundary of the tumor'), imshow(I); title('trace around the tumor'); % display brain image
ROI = imfreehand(); % outline tumor

mask = ROI.createMask(); % binary mask of tumor area
com1 = mean(ROI.getPosition()); % center of mass of tumor 
growth = 1.05; % desired level of tumor growth

boundary = bwboundaries(mask); % boundary of tumor (tumor outline)
xy = boundary{1};
x = xy(:, 2); % x values on tumor outline
y = xy(:, 1); % y values on tumor outline
hold on;
plot(x, y, 'LineWidth', 2); 
drawnow; % shows brain image with blue outline of tumor

% burned = I;
% burned(mask) = 255; % brain image with the tumor colored pink

maskedRgbImage = bsxfun(@times, I, cast(mask,'like', I)); % blacks out tumor's surroundings
M = repmat(all(~maskedRgbImage,3),[1 1 3]);
maskedRgbImage(M) = 255; % whites out everything but the tumor

% top = min(x); % x value at the top of the tumor
% bottom = max(x); % x value at the bottom of the tumor
% left = min(y); % y value at the far left of the tumor
% right = max(y); % y value at the far right of the tumor
% width = bottom - top + 1; % width of the tumor
% height = right - left + 1; % height of the tumor
% cropped = imcrop(maskedRgbImage, [top, left, width, height]); % crops image to only show tumor

large = imresize(maskedRgbImage, growth); % enlarge image so tumor enlarges by growth factor
com2 = growth.*com1; % calculate the center of mass of the new image's tumor

xdiff = com2(1)-com1(1); % compute the change in the center of mass's x-coordinate
ydiff = com2(2)-com1(2); % compute the change in the center of mass's y-coordinate
[height, width, rgb] = size(I); % find the size of the original brain image
I2 = imcrop(large, [xdiff, ydiff, width, height]); %crop to the size of the original image

greenChannel = I2(:, :, 2); % extract the green channel
tumor = greenChannel < 254; % create binary mask image with a green threshold 
close all

imshow(I); % show original brain image
hold on;
h = imshow(I2); % add enlarged tumor on top of original brain image
hold off;
set (h, 'AlphaData', tumor); % make surrounding of enlarged tumor transparent
set(gca,'position',[0 0 1 1],'units','normalized'); % get rid of the white border
saveas(gcf, 'new.tif'); % save figure as a tif

new = imread('new.tif'); % open saved figure (for some reason it's a lot larger)
[height2, width2, rgb2] = size(new); % find the size of the new brain image
new = imresize(new, (height/height2)); % make smaller to the size of the original image

compile_c_files

  % Read two greyscale images of Lena
  Imoving=I;
  Istatic=new;

  % Register the images
  [Ireg,O_trans,Spacing,M,B,F] = image_registration(Imoving,Istatic);

new = imresize(Ireg, 2);
  
%   % Show the registration result
%   figure,
%   subplot(2,2,1), imshow(Imoving); title('moving image');
%   subplot(2,2,2), imshow(Istatic); title('static image');
%   subplot(2,2,3), imshow(Ireg); title('registerd moving image');
%   % Show also the static image transformed to the moving image
%   Ireg2=movepixels(Istatic,F);
%   subplot(2,2,4), imshow(Ireg2); title('registerd static image');
% 
%  % Show the transformation fields
%   figure,
%   subplot(2,2,1), imshow(B(:,:,1),[]); title('Backward Transf. in x direction');
%   subplot(2,2,2), imshow(F(:,:,2),[]); title('Forward Transf. in x direction');
%   subplot(2,2,3), imshow(B(:,:,1),[]); title('Backward Transf. in y direction');
%   subplot(2,2,4), imshow(F(:,:,2),[]); title('Forward Transf. in y direction');
% 
% % Calculate strain tensors
%   E = strain(F(:,:,1),F(:,:,2));
% % Show the strain tensors
%   figure,
%   subplot(2,2,1), imshow(E(:,:,1,1),[-1 1]); title('Strain Tensors Exx');
%   subplot(2,2,2), imshow(E(:,:,1,2),[-1 1]); title('Strain Tensors Exy');
%   subplot(2,2,3), imshow(E(:,:,2,1),[-1 1]); title('Strain Tensors Eyx');
%   subplot(2,2,4), imshow(E(:,:,2,2),[-1 1]); title('Strain Tensors Eyy');

