% ��������ͼ���غϲ��֣����м��ճ�һ������,��img1Ϊ��������img1����������img2�Ĳ���
% ���ڸĳ�������img2ȫ������Ϊ�����м�ָ������ȫ��Χ������ɴ඼ɾ��
function [img1, img2, is_overlap] = eliminate_overlap(img1, img2)

kernel = ones(3,3);
img1 = imdilate(img1, kernel); %����,�ֲ����ֵ
img2 = imdilate(img2, kernel); %����,�ֲ����ֵ

[rows,cols] = size(img1);

is_overlap = logical(false); %�Ƿ��غ�

for r = 1 : rows
    for c = 1 : cols
        if img2(r,c) ==1 && img1(r,c) == 1
            is_overlap = logical(true);
        end
    end
end

if is_overlap
    img2 = zeros(size(img2)); %��0
end

img1 = imerode(img1, kernel); %����,�ֲ����ֵ
img2 = imerode(img2, kernel); %����,�ֲ����ֵ

% ������ʾ
% figure(1);
% subplot(1,2,1)
% imshow(img1);
% subplot(1,2,2)
% imshow(img2);
% disp('ok');
end