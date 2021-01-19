% function image_out = priwitt_sharpen(image_in)
% % Priwitt锐化算法
% % g(i,j)=[dx(i,j)^2+dy(i,j)^2]^(1/2);
% % dx = [-1 -1 -1;0 0 0;1 1 1]; dy = [-1 0 1;-1 0 1;-1 0 1];
% 
% % 输入原始图像
% imgSrc = imread('D:/DataSet/VOC2012_JPEGImages/2007_000032.jpg');
% image_in = rgb2gray(imgSrc);
% im = double(image_in);
% 
% H1 = [-1 -1 -1;0 0 0;1 1 1]; dx = filter2(H1,im);
% H2 = [-1 0 1;-1 0 1;-1 0 1]; dy = filter2(H2,im);
% 
% im2 = sqrt(dx.^2 + dy.^2); % .^2:矩阵中的每个元素都求平方
% image_out = im + sqrt(dx.^2 + dy.^2)*0.1;
% 
% figure (1)
% subplot(2,1,1)
% imshow(image_in);
% subplot(2,1,2)
% imshow(image_out);
% end

% 输入原始图像
imgSrc = imread('D:/MyStudyProj/generate_dataset_of_object_detect_forgery/4dataset_irregular_png_06resize/rgbOut/2007_001288.png');
image_in = rgb2gray(imgSrc);
% image_in = image_in / 255;
% image_in = double(image_in);

% H1 = [-1 -1 -1;0 0 0;1 1 1]; dx = filter2(H1,im);
% H2 = [-1 0 1;-1 0 1;-1 0 1]; dy = filter2(H2,im);

% ff=fspecial('prewitt');
image_out = image_in + uint8(filter2(fspecial('prewitt'),image_in)*0.3);

% im2 = sqrt(dx.^2 + dy.^2); % .^2:矩阵中的每个元素都求平方
% image_out = im + sqrt(dx.^2 + dy.^2)*0.1;
% image_out = image_out + im;

figure (1)
subplot(2,1,1)
imshow(uint8(image_in));
subplot(2,1,2)
imshow(uint8(image_out));