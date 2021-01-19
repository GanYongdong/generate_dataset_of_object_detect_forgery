function [imgOut] = generate_irregular_areas_based_on_one_point(img, coordinateOfPoint, step)
% ����һ����coordinateOfPoint��x,y����ͼ��img������һ������������

imgOut = zeros(size(img));
[rows,cols] = size(imgOut);

imgOut(coordinateOfPoint(1,2),coordinateOfPoint(1,1)) = 1; %���ĵ㸳ֵΪ1

xTmp = coordinateOfPoint(1,1);
yTmp = coordinateOfPoint(1,2);
for j = 1 : 5 %5��ѭ������α任��������һ��������ϸ�ߣ�Ϊ���������ԣ�����������������������
    k = randi([-100,100])/100; %���б��
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

for i = 1 : step %step�����Ͳ���
    if mod(i,5)==1 %ÿ5�θ���һ�����͵ķ���
        directX = randi([1,3]);
        directY = randi([1,3]);
    end
    kernel = zeros(3,3);
    kernel(2,2) = 1;
    kernel(directY, directX) = 1;
    % kernel(directY+1, directX+1) = 1; %������״���嶼��һ������
    imgOut = imdilate(imgOut, kernel); %����,�ֲ����ֵ,������ͼ����ѿն��������

    if length(find(imgOut==1)) > rows*cols*0.75
        break;
    end
        
end

end