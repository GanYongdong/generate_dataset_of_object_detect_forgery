% 根据一个点coordinateOfPoint（x,y）在图像img上生成一个不规则区域
function [imgOut] = generate_retangle_areas_based_on_one_point(img, coordinateOfPoint, step)

imgOut = zeros(size(img));
[rows,cols] = size(imgOut);

width = randi([1, min(step*2,cols)]);
height = randi([1, min(step*2,rows)]);
left = round(coordinateOfPoint(1,1) - 0.5*width);
top = round(coordinateOfPoint(1,2) - 0.5*height);

if left < 1
    left = 1;
end
if left + width > cols
    width = cols - left - 1;
end
if top < 1
    top = 1;
end
if top + height > rows
    height = rows - top - 1;
end

imgOut(top:top+height,left:left+width) = 1;

end