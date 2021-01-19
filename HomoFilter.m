% 同态滤波，参考：https://blog.csdn.net/cjsh_123456/article/details/79351654
% [image_out] = HomoFilter(image_in, rh, rl, c, D0)

function [image_out] = HomoFilter(image_in, rh, rl, c, D0)
% 同态滤波器
% 输入为需要进行滤波的灰度图像，同态滤波器的参数rh, rl,c, D0
% 输出为进行滤波之后的灰度图像
[m, n] = size(image_in);
P = 2*m;
Q = 2*n;
 
% 取对数
image1 = log(double(image_in) + 1);
 
fp = zeros(P, Q);
%对图像填充0,并且乘以(-1)^(x+y) 以移到变换中心
for i = 1 : m
    for j = 1 : n
        fp(i, j) = double(image1(i, j)) * (-1)^(i+j);
    end
end
% 对填充后的图像进行傅里叶变换
F1 = fft2(fp);
 
% 生成同态滤波函数，中心在(m+1,n+1)
Homo = zeros(P, Q);
a = D0^2; % 计算一些不变的中间参数
r = rh-rl;
for u = 1 : P
    for v = 1 : Q
        temp = (u-(m+1.0))^2 + (v-(n+1.0))^2;
        Homo(u, v) = r * (1-exp((-c)*(temp/a))) + rl;
    end
end
 
%进行滤波
G = F1 .* Homo;
 
% 反傅里叶变换
gp = ifft2(G);
 
% 处理得到的图像
image_out = zeros(m, n, 'uint8');
gp = real(gp);
g = zeros(m, n);
for i = 1 : m
    for j = 1 : n
        g(i, j) = gp(i, j) * (-1)^(i+j);
        
    end
end
% 指数处理
ge = exp(g)-1;
% 归一化到[0, L-1]
mmax = max(ge(:));
mmin = min(ge(:));
range = mmax-mmin;
for i = 1 : m
    for j = 1 : n
        image_out(i,j) = uint8(255 * (ge(i, j)-mmin) / range);
    end
end

end