function [imgOut] = generate_irregular_areas_based_on_one_point(img, coordinateOfPoint, step)
% 根据一个点coordinateOfPoint（x,y）在图像img上生成一个不规则区域

imgOut = zeros(size(img));
[rows,cols] = size(imgOut);

imgOut(coordinateOfPoint(1,2),coordinateOfPoint(1,1)) = 1; %中心点赋值为1

xTmp = coordinateOfPoint(1,1);
yTmp = coordinateOfPoint(1,2);
for j = 1 : 5 %5次循环，五次变换方向，生成一条弯曲的细线，为了添加随机性，让随后生长的区域更不规则
    k = randi([-100,100])/100; %随机斜率
    b = yTmp - k*xTmp;
    for i = -5 : 5
        x = xTmp + i;
        y = round(k * x + b);
        if x > 1 && x < cols && y > 1 && y < rows
            imgOut(y,x) = 1;
        end
    end
    xTmp = x;
    yTmp = y;
end

for i = 1 : step %step次膨胀操作
    if mod(i,5)==1 %每5次更改一下膨胀的方向
        directX = randi([1,3]);
        directY = randi([1,3]);
    end
    kernel = zeros(3,3);
    kernel(2,2) = 1;
    kernel(directY, directX) = 1;
    % kernel(directY+1, directX+1) = 1; %控制形状整体都朝一个方向
    imgOut = imdilate(imgOut, kernel); %膨胀,局部最大值,把手掌图像断裂空洞部分填充

    if length(find(imgOut==1)) > rows*cols*0.75
        break;
    end
        
end

end