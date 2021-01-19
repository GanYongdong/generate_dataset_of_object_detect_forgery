function imgOutput = histeq_in_local_irregular_area(imgInput, mask)

[height, width, channels] = size(imgInput);
if channels == 3
    I = rgb2gray(imgInput);
else
    I = imgInput;
end

% figure
% subplot(221);
% imshow(I);
% title('ԭʼͼ��');
% subplot(222);
% imhist(I);
% title('ԭʼͼ��ֱ��ͼ');

%�������ػҶ�ͳ��;
NumPixel = zeros(1,256);%ͳ�Ƹ��Ҷ���Ŀ����256���Ҷȼ�
pix_total = 0; %�ܵ���Ҫ��������ص����
for i = 1:height
    for j = 1: width
        if mask(i,j) == 1
        	NumPixel(I(i,j) + 1) = NumPixel(I(i,j) + 1) + 1;%��Ӧ�Ҷ�ֵ���ص���������һ
            pix_total = pix_total + 1;
        end
    end
end
%����Ҷȷֲ��ܶ�
ProbPixel = zeros(1,256);
for i = 1:256
    ProbPixel(i) = NumPixel(i) / (pix_total * 1.0);
end
%�����ۼ�ֱ��ͼ�ֲ�
CumuPixel = zeros(1,256);
for i = 1:256
    if i == 1
        CumuPixel(i) = ProbPixel(i);
    else
        CumuPixel(i) = CumuPixel(i - 1) + ProbPixel(i);
    end
end
%�ۼƷֲ�ȡ��
CumuPixel = uint8(255 .* CumuPixel + 0.5);
%�ԻҶ�ֵ����ӳ�䣨���⻯��
for i = 1:height
    for j = 1: width
        if mask(i,j) == 1
            I(i,j) = CumuPixel(I(i,j)+1);
        end
    end
end
% subplot(223);
% imshow(I);
% title('ֱ��ͼ���⻯��ĻҶ�ͼ��');
% subplot(224);
% imhist(I);
% title('���⻯���ֱ��ͼ');

imgOutput = I;

end
