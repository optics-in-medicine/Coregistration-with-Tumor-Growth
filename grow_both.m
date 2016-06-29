function [new] = grow_both(I, growth_tumor, growth_necrotic)

%ENLARGE THE TUMOR
I = imresize(I,0.5);
% I = imresize(rot90(imread('501B_1.tif'),2), .3); % load brain image
% I = imread('410B.tif'); % load brain image
figure('Name','Draw a boundary of the tumor'), imshow(I); title('trace around the tumor'); % display brain image
ROI_t = imfreehand(); % outline tumor

mask_t = ROI_t.createMask(); % binary mask of tumor area
com_t = mean(ROI_t.getPosition()); % center of mass of tumor 

boundary_t = bwboundaries(mask_t); % boundary of tumor (tumor outline)
xy_t = boundary_t{1};
x_t = xy_t(:, 2); % x values on tumor outline
y_t = xy_t(:, 1); % y values on tumor outline
hold on;
plot(x_t, y_t, 'LineWidth', 2); 
drawnow; % shows brain image with blue outline of tumor

maskedRgbImage_t = bsxfun(@times, I, cast(mask_t,'like', I)); % blacks out tumor's surroundings
M = repmat(all(~maskedRgbImage_t,3),[1 1 3]);
maskedRgbImage_t(M) = 255; % whites out everything but the tumor

% top = min(x); % x value at the top of the tumor
% bottom = max(x); % x value at the bottom of the tumor
% left = min(y); % y value at the far left of the tumor
% right = max(y); % y value at the far right of the tumor
% width = bottom - top + 1; % width of the tumor
% height = right - left + 1; % height of the tumor
% cropped = imcrop(maskedRgbImage, [top, left, width, height]); % crops image to only show tumor

large_t = imresize(maskedRgbImage_t, growth_tumor); % enlarge image so tumor enlarges by growth factor
com_t2 = growth_tumor.*com_t; % calculate the center of mass of the new image's tumor

xdiff_t = com_t2(1)-com_t(1); % compute the change in the center of mass's x-coordinate
ydiff_t = com_t2(2)-com_t(2); % compute the change in the center of mass's y-coordinate
[height, width, ~] = size(I); % find the size of the original brain image
I2_t = imcrop(large_t, [xdiff_t, ydiff_t, width, height]); %crop to the size of the original image

greenChannel = I2_t(:, :, 2); % extract the green channel
tumor = greenChannel < 254; % create binary mask image with a green threshold 
close all

imshow(I); % show original brain image
hold on;
h_t = imshow(I2_t); % add enlarged tumor on top of original brain image
hold off;
set (h_t, 'AlphaData', tumor); % make surrounding of enlarged tumor transparent
set(gca,'position',[0 0 1 1],'units','normalized'); % get rid of the white border
saveas(gcf, 'new.tif'); % save figure as a tif

enlarged_tumor = imread('new.tif'); % open saved figure (for some reason it's a lot larger)
[height2, ~, ~] = size(enlarged_tumor); % find the size of the new brain image
enlarged_tumor = imresize(enlarged_tumor, (height/height2)); % make smaller to the size of the original image


%ENLARGE THE NECROTIC TUMOR
% I = imresize(rot90(imread('501B_1.tif'),2), .6); % load brain image
% I = imread('410B.tif'); % load brain image
figure('Name','Draw a boundary of the liquified necrotic tumor tissue'), imshow(enlarged_tumor); title('trace around the white area'); % display brain image
ROI_n = imfreehand(); % outline tumor

mask_n = ROI_n.createMask(); % binary mask of tumor area
com_n = mean(ROI_n.getPosition()); % center of mass of tumor 

boundary_n = bwboundaries(mask_n); % boundary of tumor (tumor outline)
xy_n = boundary_n{1};
x_n = xy_n(:, 2); % x values on tumor outline
y_n = xy_n(:, 1); % y values on tumor outline
hold on;
plot(x_n, y_n, 'LineWidth', 2); 
drawnow; % shows brain image with blue outline of tumor

maskedRgbImage_n = bsxfun(@times, enlarged_tumor, cast(mask_n,'like', enlarged_tumor)); % blacks out tumor's surroundings
se = strel('disk',5);
maskedRgbImage_n = imdilate(maskedRgbImage_n, se);
maskedRgbImage_n = imerode(maskedRgbImage_n, se);
M = repmat(all(~maskedRgbImage_n,3),[1 1 3]);
maskedRgbImage_n(M) = 255; % whites out everything but the tumor

% top = min(x); % x value at the top of the tumor
% bottom = max(x); % x value at the bottom of the tumor
% left = min(y); % y value at the far left of the tumor
% right = max(y); % y value at the far right of the tumor
% width = bottom - top + 1; % width of the tumor
% height = right - left + 1; % height of the tumor
% cropped = imcrop(maskedRgbImage, [top, left, width, height]); % crops image to only show tumor

large_n = imresize(maskedRgbImage_n, growth_necrotic); % enlarge image so tumor enlarges by growth factor
com_n2 = growth_necrotic.*com_n; % calculate the center of mass of the new image's tumor

xdiff_n = com_n2(1)-com_n(1); % compute the change in the center of mass's x-coordinate
ydiff_n = com_n2(2)-com_n(2); % compute the change in the center of mass's y-coordinate
I2_n = imcrop(large_n, [xdiff_n, ydiff_n, width, height]); %crop to the size of the original image

greenChannel = I2_n(:, :, 2); % extract the green channel
necrotic = greenChannel < 254; % create binary mask image with a green threshold 
close all

imshow(enlarged_tumor); % show brain image with enlarged tumor
hold on;
h_n = imshow(I2_n); % add enlarged necrotic tissue on top of enlarged tumor image
hold off;
set (h_n, 'AlphaData', necrotic); % make surrounding of enlarged tumor transparent
set(gca,'position',[0 0 1 1],'units','normalized'); % get rid of the white border
saveas(gcf, 'new.tif'); % save figure as a tif

new = imread('new.tif'); % open saved figure (for some reason it's a lot larger)
[height2, ~, ~] = size(new); % find the size of the new brain image
new = imresize(new, (height/height2)); % make smaller to the size of the original image


%COREGISTER
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

