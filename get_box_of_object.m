function [left,top,w,h,cx,cy,right,bottom,area, cx_rate, cy_rate, w_rate, h_rate] = get_box_of_object(img)
% 获取图像中区域的box等信息
% [left,top,w,h,cx,cy,right,bottom,area, cx_rate, cy_rate, w_rate,
% h_rate]应该能看懂

region = regionprops(img, 'BoundingBox');
box = region.BoundingBox;

[rows,cols] = size(img);

left = round(box(1,1));
top = round(box(1,2));
w = round(box(1,3));
h = round(box(1,4));
right = round(left + w);
bottom = round(top + h);
boxArea = regionprops(img, 'Area');
area = boxArea(1,1).Area;
cx = round(round((left+right)/2));
cy = round(round((top+bottom)/2));
cx_rate = cx / cols;
cy_rate = cy / rows;
w_rate = w / cols;
h_rate = h / rows;

end