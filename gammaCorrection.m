
function imgOut = gammaCorrection(gray, a, gamma)
    r = double(gray); % 当输入是灰度图像时，删除该句；
    imgOut = uint8(a * (r .^ gamma));
end