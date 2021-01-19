clc; clear; close all;

imgSrc = imread('D:/DataSet/VOC2012_JPEGImages/2007_000033.jpg');

gray = rgb2gray(imgSrc);
[r, c] = size(gray);

% gray2 = gammaCorrection(gray, 1.02, 1.02);
img2 = imresize(imgSrc, 0.5);
a = size(imgSrc,2);
img_gray_resampling = imresize(img2, size(imgSrc,2));
% 
% figure(1)
% subplot(2,2,1)
% imshow(gray);
% subplot(2,2,2)
% imshow(uint8(img_gray_resampling));

% disp('okk');
% y1 = awgn(double(gray), 30, 'measured');
% 
% y2 = abs(y1 - gray_d);
% sum_e = sum(y2,'all')/(r*c);
% disp(sum_e);
% 
% figure(1)
% subplot(2,2,1)
% imshow(gray);
% subplot(2,2,2)
% imshow(uint8(y1));
% subplot(2,2,3)
% imshow(uint8(y2));

