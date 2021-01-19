% 消除两个图像重合部分，且中间会空出一条线来,以img1为主，保持img1不动，消除img2的部分
% 现在改成了消除img2全部，因为存在中间分割和外面全包围情况，干脆都删了
function [img1, img2, is_overlap] = eliminate_overlap(img1, img2)

kernel = ones(3,3);
img1 = imdilate(img1, kernel); %膨胀,局部最大值
img2 = imdilate(img2, kernel); %膨胀,局部最大值

[rows,cols] = size(img1);

is_overlap = logical(false); %是否重合

for r = 1 : rows
    for c = 1 : cols
        if img2(r,c) ==1 && img1(r,c) == 1
            is_overlap = logical(true);
        end
    end
end

if is_overlap
    img2 = zeros(size(img2)); %清0
end

img1 = imerode(img1, kernel); %膨胀,局部最大值
img2 = imerode(img2, kernel); %膨胀,局部最大值

% 调试显示
% figure(1);
% subplot(1,2,1)
% imshow(img1);
% subplot(1,2,2)
% imshow(img2);
% disp('ok');
end