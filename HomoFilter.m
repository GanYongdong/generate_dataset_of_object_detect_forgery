% ̬ͬ�˲����ο���https://blog.csdn.net/cjsh_123456/article/details/79351654
% [image_out] = HomoFilter(image_in, rh, rl, c, D0)

function [image_out] = HomoFilter(image_in, rh, rl, c, D0)
% ̬ͬ�˲���
% ����Ϊ��Ҫ�����˲��ĻҶ�ͼ��̬ͬ�˲����Ĳ���rh, rl,c, D0
% ���Ϊ�����˲�֮��ĻҶ�ͼ��
[m, n] = size(image_in);
P = 2*m;
Q = 2*n;
 
% ȡ����
image1 = log(double(image_in) + 1);
 
fp = zeros(P, Q);
%��ͼ�����0,���ҳ���(-1)^(x+y) ���Ƶ��任����
for i = 1 : m
    for j = 1 : n
        fp(i, j) = double(image1(i, j)) * (-1)^(i+j);
    end
end
% �������ͼ����и���Ҷ�任
F1 = fft2(fp);
 
% ����̬ͬ�˲�������������(m+1,n+1)
Homo = zeros(P, Q);
a = D0^2; % ����һЩ������м����
r = rh-rl;
for u = 1 : P
    for v = 1 : Q
        temp = (u-(m+1.0))^2 + (v-(n+1.0))^2;
        Homo(u, v) = r * (1-exp((-c)*(temp/a))) + rl;
    end
end
 
%�����˲�
G = F1 .* Homo;
 
% ������Ҷ�任
gp = ifft2(G);
 
% ����õ���ͼ��
image_out = zeros(m, n, 'uint8');
gp = real(gp);
g = zeros(m, n);
for i = 1 : m
    for j = 1 : n
        g(i, j) = gp(i, j) * (-1)^(i+j);
        
    end
end
% ָ������
ge = exp(g)-1;
% ��һ����[0, L-1]
mmax = max(ge(:));
mmin = min(ge(:));
range = mmax-mmin;
for i = 1 : m
    for j = 1 : n
        image_out(i,j) = uint8(255 * (ge(i, j)-mmin) / range);
    end
end

end