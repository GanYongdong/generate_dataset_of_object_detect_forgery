
function imgOut = gammaCorrection(gray, a, gamma)
    r = double(gray); % �������ǻҶ�ͼ��ʱ��ɾ���þ䣻
    imgOut = uint8(a * (r .^ gamma));
end