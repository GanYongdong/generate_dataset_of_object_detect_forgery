%
% 生成目标检测的数据集，这里目标是自己生成的一些操作
% 比如这个取证数据集，给定图片集，读取每一张图片，会随机取一块矩形区域，提取ROI进行对应操作，保存当前矩形框变量和操作后的图片，储存到本地文件
% 操作数目前是5，对应类别标签1-5，稍微看懂m文件都是可以修改
% 输入输出目录和一些用户参数在用户区修改
% author: ganyongdong <1141951289@qq.com> 2020.8.17
%

clc; clear; close all;

% 用户选择区
is_process_rgb = logical(true); % 是否处理RGB图像
Maximum_number_of_targets = 10; % 每张图片最大目标个数
Maximum_proportion_of_target_in_image = 0.4; % 目标占图像最大比例
imgDataPath = 'D:\DataSet\VOC2012_JPEGImages'; %源图像目录
imgDataOutPath = 'D:\MyStudyProj\generate_dataset_of_object_detect_forgery\dataset'; %输出图像目录

% 计时开始
tic;
% 全局计数
count = 1;
% 预设label可选所属类别
labelSet = ["homoFilter", "medianFiltering", "additiveNoise", "histogramEqualization", "gaussianBlurring"];
% 最终保存的lable容器和box容器
labelArrIdxFile = [];
labelArrStrFile = ["str"];
boxArrFile = [];
% 保存的文件路径
inputPathFile = ["str"];

% 对不同图像循环
imgDataDir = dir(imgDataPath);
imgCountTotal = size(imgDataDir,1) - 2;
for picCount = 1:length(imgDataDir) % 遍历所有文件
% for picCount = 1:20 % 遍历所有文件
    if(isequal(imgDataDir(picCount).name,'.') || isequal(imgDataDir(picCount).name,'..'))
        % 去除系统自带的两个隐文件夹
        continue;
    end
    
    % 获取输入图像路径
    picPath = strcat(imgDataPath,'\',imgDataDir(picCount).name);
    if inputPathFile(1,1) == "str"
        inputPathFile(1,1) = picPath;
    else
        inputPathFile(end+1,:) = picPath;
    end
    
    % 生成输出图像路径
    picGrayPath = strcat(imgDataOutPath,'\','gray','\',imgDataDir(picCount).name);
    picGrayOutPath = strcat(imgDataOutPath,'\','grayOut','\',imgDataDir(picCount).name);
    picGrayWithBoxOutPath = strcat(imgDataOutPath,'\','grayOutWithBox','\',imgDataDir(picCount).name);
    picRgbPath = strcat(imgDataOutPath,'\','rgb','\',imgDataDir(picCount).name);
    picRgbOutPath = strcat(imgDataOutPath,'\','rgbOut','\',imgDataDir(picCount).name);
    picRgbWithBoxOutPath = strcat(imgDataOutPath,'\','rgbOutWithBox','\',imgDataDir(picCount).name);
    
    % 生成输出yolo标准标签文件路径
    nameTmp1 = imgDataDir(picCount).name;
    nameTmp2 = strsplit(nameTmp1,'.');
    nemeTmp3 = strcat(nameTmp2(1,1), '.txt');
    saveTxtPathOflabelWithBoxFile2 = strcat(imgDataOutPath,'\','label','\', nemeTmp3);
    saveTxtPathOflabelWithBoxFile = saveTxtPathOflabelWithBoxFile2{1};
    nemeTmp3 = strcat(nameTmp2(1,1), '.xlsx');
    saveTxtPathOflabelWithBoxXlsxFile2 = strcat(imgDataOutPath,'\','label','\', nemeTmp3);
    saveTxtPathOflabelWithBoxXlsxFile = saveTxtPathOflabelWithBoxXlsxFile2{1};
    
    % 最终保存的lable容器和box容器
    labelArrIdx = [];
    labelArrStr = ["str"];
    boxArr = [];
    labelWithBoxFile = [];
    
    % 读取输入图像
    % imgSrc = imread('D:/DataSet/VOC2012_JPEGImages/2007_000032.jpg');
    imgSrc = imread(picPath);
    [rows, cols, channel] = size(imgSrc);
    edge = min(rows,cols);
    if channel == 3
        imgGray = rgb2gray(imgSrc);
    else
        imgGray = imgSrc;
    end
    imgSrcWithBox = imgSrc;
    imgSrcOut = imgSrc;
    imgGrayWithBox = imgGray;
    imgGrayOut = imgGray;
    
    % 循环生成多个目标
    for objectIdx = 1 : Maximum_number_of_targets
        
        % 随机生成当前目标类别
        labelIdx = randi([1, 5]);
        % labelIdx = 1 ; % 当前强制，记得注释掉换成随机的
        label = labelSet(labelIdx);
        
        % 随机生成核尺寸，在图像范围内
        kernelVal = randi([3, 11]);
        if mod(kernelVal, 2) == 0
            kernelVal = kernelVal + 1;
        end
        
        % 随机生成处理区域
        minVal = kernelVal*3;
        maxVal = floor(edge * Maximum_proportion_of_target_in_image);
        if maxVal < minVal
            maxVal = minVal + 1;
        end
        roiWidth = randi([minVal, maxVal]);
        if mod(roiWidth, 2) == 1
            roiWidth = roiWidth + 1;
        end
        roiHeight = randi([minVal, maxVal]);
        if mod(roiHeight, 2) == 1
            roiHeight = roiHeight + 1;
        end
        minVal = ceil(roiWidth/2);
        maxVal = floor(cols - roiWidth/2);
        roiCenterPointX = randi([minVal, maxVal]);
        minVal = ceil(roiHeight/2);
        maxVal = floor(rows - roiHeight/2);
        roiCenterPointY = randi([minVal, maxVal]);
        roiLeft = roiCenterPointX - floor(roiWidth/2);
        roiTop = roiCenterPointY - floor(roiHeight/2);
        imgRoi = imcrop(imgGray, [roiLeft,roiTop,roiWidth,roiHeight]); % 提取roi区域
        if is_process_rgb
            imgRoiRgb = imcrop(imgSrc, [roiLeft,roiTop,roiWidth,roiHeight]); % 提取roi区域rgb
        end
        [roiHeight, roiWidth] = size(imgRoi);
        roiRight = roiLeft + roiWidth - 1;
        roiBottom = roiTop + roiHeight - 1;
        
        % 变量初始化，可变大小
        roiImgOperaRGB = [];
        coder.varsize('roiImgOperaRGB'); %变量可变大小
        
        % 对应进行对应操作
        switch labelIdx
            case 1 % HomoFilter
                roiImgOpera = HomoFilter(imgRoi, 2, 0.25, 1, 0.05); % 同态滤波
                if is_process_rgb
                    channelR = imgRoiRgb(:,:,1);
                    channelG = imgRoiRgb(:,:,2);
                    channelB = imgRoiRgb(:,:,3);
                    clear roiImgOperaRGB;
                    roiImgOperaRGB(:,:,1) = HomoFilter(channelR, 2, 0.25, 1, 0.05); % 同态滤波
                    roiImgOperaRGB(:,:,2) = HomoFilter(channelG, 2, 0.25, 1, 0.05); % 同态滤波
                    roiImgOperaRGB(:,:,3) = HomoFilter(channelB, 2, 0.25, 1, 0.05); % 同态滤波
                end
                
            case 2 % median filtering
                roiImgOpera = medfilt2(imgRoi, [kernelVal, kernelVal]);
                if is_process_rgb
                    channelR = imgRoiRgb(:,:,1);
                    channelG = imgRoiRgb(:,:,2);
                    channelB = imgRoiRgb(:,:,3);
                    channelROpera = medfilt2(channelR, [kernelVal, kernelVal]);
                    channelGOpera = medfilt2(channelG, [kernelVal, kernelVal]);
                    channelBOpera = medfilt2(channelB, [kernelVal, kernelVal]);
                    clear roiImgOperaRGB;
                    roiImgOperaRGB(:,:,1) = channelROpera;
                    roiImgOperaRGB(:,:,2) = channelGOpera;
                    roiImgOperaRGB(:,:,3) = channelBOpera;
                end
                
            case 3 % additive noise
                img = im2double(imgRoi); % 改为你要读入图片的路径;im2double作归一化处理
                roiImgOperaDouble = imnoise(img, 'salt & pepper', 0.05); %添加密度为5%的椒盐噪声
                roiImgOpera = im2uint8(roiImgOperaDouble); 
                if is_process_rgb
                    channelR = imgRoiRgb(:,:,1);
                    channelG = imgRoiRgb(:,:,2);
                    channelB = imgRoiRgb(:,:,3);
                    clear roiImgOperaRGB;
                    img = im2double(channelR); % 归一化处理
                    roiImgOperaRGB(:,:,1) = imnoise(img, 'salt & pepper', 0.05); %添加密度为5%的椒盐噪声
                    img = im2double(channelG); % 归一化处理
                    roiImgOperaRGB(:,:,2) = imnoise(img, 'salt & pepper', 0.05); %添加密度为5%的椒盐噪声
                    img = im2double(channelB); % 归一化处理
                    roiImgOperaRGB(:,:,3) = imnoise(img, 'salt & pepper', 0.05); %添加密度为5%的椒盐噪声
                    roiImgOperaRGB = im2uint8(roiImgOperaRGB); 
                end
                
            case 4 % histogram equalization
                roiImgOpera = histeq(imgRoi);
                if is_process_rgb
                    channelR = imgRoiRgb(:,:,1);
                    channelG = imgRoiRgb(:,:,2);
                    channelB = imgRoiRgb(:,:,3);
                    clear roiImgOperaRGB;
                    roiImgOperaRGB(:,:,1) = histeq(channelR);
                    roiImgOperaRGB(:,:,2) = histeq(channelG);
                    roiImgOperaRGB(:,:,3) = histeq(channelB);
                end
                
            case 5 % gaussian blurring
                gausFilter = fspecial('gaussian',[kernelVal kernelVal],1);  %高斯滤波
                roiImgOpera = imfilter(imgRoi, gausFilter, 'replicate');      %对任意类型数组或多维图像进行滤波
                if is_process_rgb
                    channelR = imgRoiRgb(:,:,1);
                    channelG = imgRoiRgb(:,:,2);
                    channelB = imgRoiRgb(:,:,3);
                    channelROpera = imfilter(channelR, gausFilter, 'replicate');
                    channelGOpera = imfilter(channelG, gausFilter, 'replicate');
                    channelBOpera = imfilter(channelB, gausFilter, 'replicate');
                    clear roiImgOperaRGB;
                    roiImgOperaRGB(:,:,1) = channelROpera;
                    roiImgOperaRGB(:,:,2) = channelGOpera;
                    roiImgOperaRGB(:,:,3) = channelBOpera;
                end
                
            otherwise % 否则
                disp('labelIdx must be Integer and in 1-5');
        end
        
        % 去除周围的黑边
        edgeBlack = floor(kernelVal / 2);
        roiLeft = roiLeft + edgeBlack;
        roiRight = roiRight - edgeBlack;
        roiTop = roiTop + edgeBlack;
        roiBottom = roiBottom - edgeBlack;
        roiWidth = roiWidth - edgeBlack;
        roiHeight = roiHeight - edgeBlack;
        
        % 保存box
        box = [roiLeft, roiRight, roiTop, roiBottom, roiWidth, roiHeight, roiCenterPointX, roiCenterPointY];
        
        % 判断是否重合存在
        is_process_vaild = logical(true); % 是否处理RGB图像
        for i = 1 : size(boxArr, 1)
            boxTmp = boxArr(i, :);
            boxDistance = sqrt(power((box(1,7)-boxTmp(1,7)), 2) + power((box(1,8)-boxTmp(1,8)), 2)); %计算两个box中心点距离
            boxDistanceMin = sqrt(power((box(1,5)+boxTmp(1,5))/2, 2) + power((box(1,6)+boxTmp(1,6))/2, 2));
            if boxDistance < boxDistanceMin
                is_process_vaild = logical(false);
                % disp("目标重合");
                break;
            end
        end
        
        if is_process_vaild == true
            % 保存boxArr
            boxArr(end+1,:) = box;
            labelArrIdx(end+1,1) = labelIdx;
            if labelArrStr(1,1) == "str"
                labelArrStr(1,1) = labelSet(1, labelIdx);
            else
                labelArrStr(end+1,1) = labelSet(1, labelIdx);
            end
            % 保存label 和 box的标准训练文件
            labelWithBox = [labelIdx, roiCenterPointX/cols, roiCenterPointY/rows, roiWidth/cols, roiHeight/rows];
            labelWithBoxFile(end+1,:) = labelWithBox;
            
            % 不存在重合则进行图像融合，分别保存rgb gray的 处理图和带label框的处理图
            roiImgOpera = roiImgOpera((edgeBlack+1):roiHeight, (edgeBlack+1):roiWidth); % 滤波后的roi图去除黑边
            imgGrayOut(roiTop:roiBottom, roiLeft:roiRight) = roiImgOpera; % 把滤波后的roi图融合进原灰度图
            imgGrayWithBox(roiTop:roiBottom, roiLeft:roiRight) = roiImgOpera;
            imgGrayWithBox = insertShape(imgGrayWithBox, 'Line', [roiLeft, roiTop, roiLeft, roiBottom], 'LineWidth', 1, 'Color', 'black');
            imgGrayWithBox = insertShape(imgGrayWithBox, 'Line', [roiLeft, roiBottom, roiRight, roiBottom], 'LineWidth', 1, 'Color', 'black');
            imgGrayWithBox = insertShape(imgGrayWithBox, 'Line', [roiRight, roiBottom, roiRight, roiTop], 'LineWidth', 1, 'Color', 'black');
            imgGrayWithBox = insertShape(imgGrayWithBox, 'Line', [roiLeft, roiTop, roiRight, roiTop], 'LineWidth', 1, 'Color', 'black');
            
            if is_process_rgb
                roiImgOperaRGB = roiImgOperaRGB((edgeBlack+1):roiHeight, (edgeBlack+1):roiWidth); % 滤波后的roi图去除黑边
                imgSrcOut(roiTop:roiBottom, roiLeft:roiRight) = roiImgOperaRGB; % 把滤波后的roi图融合进原rgb图
                imgSrcWithBox(roiTop:roiBottom, roiLeft:roiRight) = roiImgOperaRGB;
                colorOfLine = '';
                switch labelIdx
                    case 1
                        colorOfLine = 'blue';
                    case 2
                        colorOfLine = 'green';
                    case 3
                        colorOfLine = 'red';
                    case 4
                        colorOfLine = 'cyan';
                    case 5
                        colorOfLine = 'magenta';
                    otherwise
                        disp("error label idx");
                end
                        
                imgSrcWithBox = insertShape(imgSrcWithBox, 'Line', [roiLeft, roiTop, roiLeft, roiBottom], 'LineWidth', 1, 'Color', colorOfLine);
                imgSrcWithBox = insertShape(imgSrcWithBox, 'Line', [roiLeft, roiBottom, roiRight, roiBottom], 'LineWidth', 1, 'Color', colorOfLine);
                imgSrcWithBox = insertShape(imgSrcWithBox, 'Line', [roiRight, roiBottom, roiRight, roiTop], 'LineWidth', 1, 'Color', colorOfLine);
                imgSrcWithBox = insertShape(imgSrcWithBox, 'Line', [roiLeft, roiTop, roiRight, roiTop], 'LineWidth', 1, 'Color', colorOfLine);
            end
        end
        
        % 结束一个框的处理
        % disp('a object finish');
    end
    
    % label显示
    % subplot(2,1,1)
    % imshow(imgSrcWithBox);
    % subplot(2,1,2)
    % imshow(imgGrayWithBox);
    
    % 一张图片处理完了，对应保存图片和label
    imwrite(imgGray, picGrayPath);
    imwrite(imgGrayOut, picGrayOutPath);
    imwrite(imgGrayWithBox, picGrayWithBoxOutPath);
    imwrite(imgSrc, picRgbPath);
    imwrite(imgSrcOut, picRgbOutPath);
    imwrite(imgSrcWithBox, picRgbWithBoxOutPath);
    
    % 保存对应的标签文件
    labelArrIdxFile(count,1:size(labelArrIdx,1)) = labelArrIdx';
    labelArrStrFile(count,1:size(labelArrStr,1)) = labelArrStr';
    boxArrFile(end+1:end+size(boxArr,1),:) = boxArr;
    
    % 保存yolo标准标签文件
    dlmwrite(saveTxtPathOflabelWithBoxFile, labelWithBoxFile, 'delimiter',' ');
    xlswrite(saveTxtPathOflabelWithBoxXlsxFile, labelWithBoxFile);
    
    % 显示速度进程
    if mod(count,10) == 0
        disp(['n:', num2str(count), '/', num2str(imgCountTotal)]);
        % 暂停0.1s
        pause(0.1);
    end
    
    % 图像计数+1
    count = count + 1;
    
end

% 全部图片处理结束，保存标签对应的txt文件
saveTxtPathOfLabelArrIdxFile = strcat(imgDataOutPath,'\','saveTxtPathOfLabelArrIdxFile.txt');
dlmwrite(saveTxtPathOfLabelArrIdxFile, labelArrIdxFile, 'delimiter',' ');
saveTxtPathOfLabelArrIdxXlsxFile = strcat(imgDataOutPath,'\','saveTxtPathOfLabelArrIdxFile.xlsx');
xlswrite(saveTxtPathOfLabelArrIdxXlsxFile, labelArrIdxFile);

saveTxtPathOfLabelArrStrXlsxFile = strcat(imgDataOutPath,'\','saveTxtPathOfLabelArrStrFile.xlsx');
xlswrite(saveTxtPathOfLabelArrStrXlsxFile, labelArrStrFile);

saveTxtPathOfBoxArrFile = strcat(imgDataOutPath,'\','saveTxtPathOfBoxArrFile.txt');
dlmwrite(saveTxtPathOfBoxArrFile, boxArrFile, 'delimiter',' ');
saveTxtPathOfBoxArrXlsxFile = strcat(imgDataOutPath,'\','saveTxtPathOfBoxArrFile.xlsx');
xlswrite(saveTxtPathOfBoxArrXlsxFile, boxArrFile);

saveTxtPathOfInputXlsxFile = strcat(imgDataOutPath,'\','saveTxtPathOfInputXlsxFile.xlsx');
xlswrite(saveTxtPathOfInputXlsxFile, inputPathFile);

% 计时结束并显示
toc;

% 结束
disp('end');