% 通过平行四边形四个无序的点坐标，筛选出左上角和右下角坐标
function [top_left_x, top_left_y, bottom_right_x, bottom_right_y] = get_top_left_and_bottom_right(p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y)
    p = [p1x,p1y;p2x,p2y;p3x,p3y;p4x,p4y];
%     p = [153.5,41.5; 190.5,4.5; 153.5,4.5; 116.5,41.5] 
    p_tmp = p;
    % 找左上角坐标
    [min1,~] = min(p_tmp(:,2));
    index1 = find(p_tmp(:,2)==min1);
    p_tmp(index1,:) = [];
    [min2,~] = min(p_tmp(:,2));
    index2 = find(p_tmp(:,2)==min2);
    
    p2 = [p(index1,:);p(index2,:)];
    [min2,~] = min(p2(:,1));
    top_left_x = min2;
    top_left_y = min(p(find(p(:,1)==min2),2));

    % 找右下角坐标
    p_tmp = p;
    [max1,~] = max(p_tmp(:,2));
    index1 = find(p_tmp(:,2)==max1);
    p_tmp(index1,:) = [];
    [max2,~] = max(p_tmp(:,2));
    index2 = find(p_tmp(:,2)==max2);
    
    p2 = [p(index1,:);p(index2,:)];
    [max2,~] = max(p2(:,1));
    bottom_right_x = max2;
    bottom_right_y = max(p(find(p(:,1)==max2),2));
%     disp("oka")
    
end
