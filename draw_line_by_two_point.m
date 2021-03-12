% clc; clear; close all;

% img = imread('D:\\Dataset\\VOC2012_JPEGImages\\2007_000027.jpg');

function img = draw_line_by_two_point(img, p1x, p1y, p2x, p2y)
% img = rgb2gray(img);
[rows,cols] = size(img);
p2x = round(p2x);
p2y = round(p2y);
p1x = round(p1x);
p1y = round(p1y);
% p2x = 100;
% p2y = 150;
% p1x = 100;
% p1y = 360;
% is_rgb = 1;
if p2x == p1x
    k = 999;
else
    k = (p2y - p1y)/(p2x-p1x);
end
b = p1y - k*p1x;

if abs(k) < 1
    for i = min(p1x,p2x) : max(p1x,p2x)
        y = round(k*i+b);
        if i < cols && i > 0 && y < rows && y > 0
            img(y,i,1) = 255;
            img(y,i,2) = 100;
            img(y,i,3) = 0;
            img(y+1,i,1) = 255;
            img(y+1,i,2) = 100;
            img(y+1,i,3) = 0;
        end
    end
else
    for y = min(p1y,p2y) : max(p1y,p2y)
        i = round((y-b)/k);
        if i < cols && i > 0 && y < rows && y > 0
            img(y,i,1) = 255;
            img(y,i,2) = 100;
            img(y,i,3) = 0;
            img(y,i+1,1) = 255;
            img(y,i+1,2) = 100;
            img(y,i+1,3) = 0;
        end
    end
end
% imshow(img);
% disp('oka');
end



