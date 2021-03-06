function [pg_x, pg_y, pg_side1, pg_side2, pg_theta, p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y] = Parallelogram_det(img)
[rows,~]=size(img);
[imgB, imgL, ~, ~] = bwboundaries(img);
% imshow(img2*255);
props = regionprops(imgL,'all');
% boundary = bwperim(imgL);
bbox = props.BoundingBox;
extrema = props.Extrema;
area = props.Area;
pg_top = max(extrema,[],1);
pg_top = pg_top(2);
pg_bot = min(extrema,[],1);
pg_bot = pg_bot(2);

imgB = imgB{1};
num_imgB_point = size(imgB,1); %一共多少边界点
intersec_point_set = zeros(180, 14); %1.第一个交点索引 2.第二个交点索引 3.面积 4.真实面积占比例 5.斜边1长度 6.底边2长度 7-14是四个点
for i = 1 : 180
    k = tan(i*pi/180); %斜率
    if i < 90
        b = rows;
    else
        b = 0;
    end
    dis_set = zeros(num_imgB_point,1); %存储当前角度下，所有边界点到直线的距离
    for m = 1 : num_imgB_point
        x0 = imgB(m,2);
        y0 = imgB(m,1);
        dis_set(m,1) = abs(k*x0-y0+b)/sqrt(k*k+1);
    end
    [intersec_point_set(i,1),~]=find(dis_set==max(max(dis_set)),1,'first');
    [intersec_point_set(i,2),~]=find(dis_set==min(min(dis_set)),1,'first');
    x1 = imgB(intersec_point_set(i,1),2);%第一条斜线
    y1 = imgB(intersec_point_set(i,1),1);
    b1 = y1 - k*x1;
    x2 = imgB(intersec_point_set(i,2),2);%第二条斜线
    y2 = imgB(intersec_point_set(i,2),1);
    b2 = y2 - k*x2;
    [x3,y3] = point_of_two_line(k,b1,0,pg_top);%第一条斜线和上边交点
    [x4,y4] = point_of_two_line(k,b1,0,pg_bot);%第一条斜线和下边交点
    [x5,y5] = point_of_two_line(k,b2,0,pg_top);%第二条斜线和上边交点
    [x6,y6] = point_of_two_line(k,b2,0,pg_bot);%第二条斜线和下边交点
    dis_p3p4 = sqrt((x3-x4)*(x3-x4)+(y3-y4)*(y3-y4)); %斜边1长度
    dis_p3p5 = sqrt((x3-x5)*(x3-x5)+(y3-y5)*(y3-y5)); %底边2长度
    dis_l1l2 = abs(b1-b2)/sqrt(k*k+1); %两条平行斜线之间的距离
    pg_area = dis_p3p4 * dis_l1l2; %平行四边形面积
    intersec_point_set(i, 3) = pg_area;
    intersec_point_set(i, 4) = area / pg_area; %计算不同角度下，实际目标面积占比平行四边形
    intersec_point_set(i, 5) = dis_p3p4;
    intersec_point_set(i, 6) = dis_p3p5;
    intersec_point_set(i, 7:14) = [x3,y3,x4,y4,x6,y6,x5,y5];
    if intersec_point_set(i, 4) > 1
        intersec_point_set(i, 4) = 0;
    end
end
i_final = find(intersec_point_set(:,4)==max(intersec_point_set(:,4)),1,'first');

pg_theta = 180 - i_final;
pg_side1 = intersec_point_set(i_final, 5);
pg_side2 = intersec_point_set(i_final, 6);
pg_x = bbox(1);
pg_y = bbox(2);
p1x = intersec_point_set(i_final, 7);
p1y = intersec_point_set(i_final, 8);
p2x = intersec_point_set(i_final, 9);
p2y = intersec_point_set(i_final, 10);
p3x = intersec_point_set(i_final, 11);
p3y = intersec_point_set(i_final, 12);
p4x = intersec_point_set(i_final, 13);
p4y = intersec_point_set(i_final, 14);
end