%
% 生成目标检测的数据集，这里目标是自己生成的一些局部操作区域
% 比如这个取证数据集，给定图片集，读取每一张图片，会随机取一块不规则区域，随机
% 采取6种操作方法中的一种进行操作，保存当前最大矩形框变量和操作后的图片，储存
% 到本地文件.操作数目前是6，对应类别标签1-6
% 输入输出目录和一些用户参数在用户区修改
% 2021.1.20更新：
% 1. 将矩形框改成平行四边形框，主要思路是先随机多个平行四边形，不重叠，平行四
%    边形中心开始向外膨胀,触碰到一边的边界则停止
% author: ganyongdong <1141951289@qq.com> 2021.1.20
%

clc; clear; close all;

% 用户选择区
is_process_rgb = logical(true); % 是否处理RGB图像
is_allow_objects_to_overlap = logical(false); % 是否允许object重合，指的是目标不规则区域没有重合，框可能还是重合的
the_region_of_opera = "irregular"; %进行操作的区域形状，可选"irregular"和"retangle"，
% 分别是生成不规则操作区域和矩形操作区域，可以自己写其他操作区域，类似generate_irregular_areas_based_on_one_point.m和
% generate_retangle_areas_based_on_one_point.m
Maximum_number_of_targets = 8; % 每张图片最大目标个数
Maximum_proportion_of_target_in_image = 0.4; % 目标占图像最大比例
imgDataPath = 'D:\Dataset\PASCAL_VOC\VOCtrainval_2012\VOC2012\JPEGImages'; %源图像目录
imgDataOutPath = 'D:\Research\My_tamper_detect_dataset_generate\dataset_tmp'; %输出图像目录
kernel_range = [3,3]; %均值滤波、中值滤波和高斯滤波选择进行操作的内核尺寸范围，一行两列，小的在前，大的在后，相等就是固定大小
saltAndPepper_density = 0.03; %椒盐噪声密度
homo_d0 = 0.008; %同态滤波的D0参数值
sharp_factor = 0.7; %锐化程度[0,1]
step_range_control_the_size_of_object = [25,45]; %控制生成的目标大小的参数，能够大概控制,相等就是几乎固定大小
factor_of_imgSrc_zoom = 0.6; %对源图像缩放倍数，可以控制输出图像尺寸，加快部分网络训练速度。这是在进行操作之前缩放，不影响操作质量。
is_parallelogram = logical(true); %是否生成平行四边形标签，无论如何矩形标签都默认会生成

% 计时开始
tic;
% 全局计数
count = 1;
% 预设label可选所属类别
labelStrSet = ["homofilt"; "medianfilt"; "awgn"; "histeq"; "gaussfilt"; "sharp"; "resampling"; "gamma"];
% 最终保存的lable容器和box容器

% 写label_list文件
label_list_txt = strcat(imgDataOutPath, '\voc_dataset\label_list.txt');
label_list = cellstr(labelStrSet);
T = cell2table(label_list);
writetable(T,label_list_txt);
clear label_list_txt label_list T;

% 对不同图像循环
imgDataDir = dir(imgDataPath);
imgCountTotal = size(imgDataDir,1) - 2;
for picCount = 1:length(imgDataDir) % 遍历所有图片文件

    % for picCount = 1:20 % 遍历所有文件
    if(isequal(imgDataDir(picCount).name,'.') || isequal(imgDataDir(picCount).name,'..'))
        % 去除系统自带的两个隐文件夹
        continue;
    end
    
    % 获取输入图像路径
    picPath = strcat(imgDataPath,'\',imgDataDir(picCount).name);
    
    % 生成输出图像路径
    strTmp1 = imgDataDir(picCount).name;
    strTmp2 = strsplit(strTmp1,'.');
    pngFileName = strcat(strTmp2(1,1), '.png');
    clear strTmp1;
    picGrayPath = strcat(imgDataOutPath,'\','gray','\',pngFileName);
    picGrayOutPath = strcat(imgDataOutPath,'\','grayOut','\',pngFileName);
    picGrayWithBoxOutPath = strcat(imgDataOutPath,'\','grayOutWithBox','\',pngFileName);
    picRgbPath = strcat(imgDataOutPath,'\','rgb','\',pngFileName);
    picRgbOutPath = strcat(imgDataOutPath,'\','rgbOutPng','\',pngFileName);
    picRgbJpgPath = strcat(imgDataOutPath,'\','rgbOutJpg','\',pngFileName);
    picRgbJpgOutPath = strrep(picRgbJpgPath,'png','jpg');
    picRgbWithBoxOutPath = strcat(imgDataOutPath,'\','rgbOutWithBox','\',pngFileName);
    picMask = strcat(imgDataOutPath,'\','picMask','\',pngFileName);
    clear strTmp2;
    
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
    labelArrStr = "str";
    boxArr = [];
    labelWithBoxFile = [];
    
    % 读取输入图像
    % imgSrc = imread('D:/DataSet/VOC2012_JPEGImages/2007_000032.jpg');
    imgSrc = imread(picPath);
    if factor_of_imgSrc_zoom ~= 1.0
        imgSrc = imresize(imgSrc, factor_of_imgSrc_zoom);
    end
    [rows, cols, channel] = size(imgSrc);
    edge = min(rows,cols);
    if channel == 3
        imgRgb = imgSrc;
        imgGray = rgb2gray(imgRgb);
        imgRgbWithBox = imgRgb;
        imgRgbOut = imgRgb;
    else
        imgGray = imgSrc;
        is_process_rgb = logical(false);
        disp('单通道图像处理');
    end
    clear imgSrc;
    imgGrayWithBox = imgGray;
    imgGrayOut = imgGray;

    % 随机生成核尺寸，在图像范围内
    kernelVal = randi(kernel_range);
    if mod(kernelVal, 2) == 0 %内核尺寸必须为奇数
        kernelVal = kernelVal + 1;
    end
        
    % 生成9幅不同操作的图像，后边对应操作的就从这取图像
    img_gray_homoFilter = HomoFilter(imgGray, 2.2, 0.25, 2, homo_d0); %1同态滤波
    img_gray_medfilt = medfilt2(imgGray, [kernelVal, kernelVal]);%2中值滤波
    imgTmp = im2double(imgGray); % 改为你要读入图片的路径;im2double作归一化处理
    % img_gray_saltAndPepper = im2uint8(imnoise(imgTmp, 'salt & pepper', saltAndPepper_density));%3.椒盐噪声
    img_gray_awgn = awgn(double(imgGray), 30, 'measured'); %3.加高斯白噪声
    img_gray_histeq = histeq(imgGray); %4.直方图均衡化
    gausFilter = fspecial('gaussian',[kernelVal kernelVal],1); %高斯滤波核
    img_gray_gausFilter = imfilter(imgGray, gausFilter, 'replicate'); %5.高斯滤波
	img_gray_prewittSharp = imgGray + uint8(filter2(fspecial('prewitt'),imgGray)*sharp_factor); %6.prewitt锐化
    img_gray_resampling = imresize(imresize(imgGray, 0.5), size(imgGray)); %7.重采样
    img_gray_gammaCorrect = gammaCorrection(imgGray, 1.02, 1.02); %8.gamma校正
    
    if is_process_rgb %如果是三通道图像
        channelR = imgRgb(:,:,1);
        channelG = imgRgb(:,:,2);
        channelB = imgRgb(:,:,3);
        clear img_rgb_homoFilter img_rgb_medfilt img_rgb_saltAndPepper img_rgb_histeq img_rgb_gausFilter img_rgb_prewittSharp img_rgb_resampling img_rgb_gammaCorrect;
        % 1.同态滤波
        img_rgb_homoFilter(:,:,1) = HomoFilter(channelR, 2, 0.25, 1, homo_d0); % 同态滤波
        img_rgb_homoFilter(:,:,2) = HomoFilter(channelG, 2, 0.25, 1, homo_d0); % 同态滤波
        img_rgb_homoFilter(:,:,3) = HomoFilter(channelB, 2, 0.25, 1, homo_d0); % 同态滤波
        % 2.中值滤波
        img_rgb_medfilt(:,:,1) = medfilt2(channelR, [kernelVal, kernelVal]);
        img_rgb_medfilt(:,:,2) = medfilt2(channelG, [kernelVal, kernelVal]);
        img_rgb_medfilt(:,:,3) = medfilt2(channelB, [kernelVal, kernelVal]);
        %{
        % 3.添加噪声
        imgTmp = im2double(channelR); % 归一化处理
        img_rgb_saltAndPepper(:,:,1) = im2uint8(imnoise(imgTmp, 'salt & pepper', saltAndPepper_density)); %添加密度为5%的椒盐噪声
        imgTmp = im2double(channelG); % 归一化处理
        img_rgb_saltAndPepper(:,:,2) = im2uint8(imnoise(imgTmp, 'salt & pepper', saltAndPepper_density)); %添加密度为5%的椒盐噪声
        imgTmp = im2double(channelB); % 归一化处理
        img_rgb_saltAndPepper(:,:,3) = im2uint8(imnoise(imgTmp, 'salt & pepper', saltAndPepper_density)); %添加密度为5%的椒盐噪声
        %}
        % 3.加高斯白噪声        
        img_rgb_awgn = awgn(double(imgRgb), 30, 'measured');
        % 4.直方图均衡化
        img_rgb_histeq(:,:,1) = histeq(channelR);
        img_rgb_histeq(:,:,2) = histeq(channelG);
        img_rgb_histeq(:,:,3) = histeq(channelB);
        % 5.高斯滤波
        img_rgb_gausFilter(:,:,1) = imfilter(channelR, gausFilter, 'replicate');
        img_rgb_gausFilter(:,:,2) = imfilter(channelG, gausFilter, 'replicate');
        img_rgb_gausFilter(:,:,3) = imfilter(channelB, gausFilter, 'replicate');
        % 6.prewitt锐化
        img_rgb_prewittSharp(:,:,1) = channelR + uint8(filter2(fspecial('prewitt'),channelR)*sharp_factor); %prewitt锐化
        img_rgb_prewittSharp(:,:,2) = channelG + uint8(filter2(fspecial('prewitt'),channelG)*sharp_factor); %prewitt锐化
        img_rgb_prewittSharp(:,:,3) = channelB + uint8(filter2(fspecial('prewitt'),channelB)*sharp_factor); %prewitt锐化
        % 7.重采样
        img_rgb_resampling = imresize3(imresize(imgRgb, 0.5), size(imgRgb));
        % 8.gamma变换
        img_rgb_gammaCorrect(:,:,1) = gammaCorrection(channelR, 1.02, 1.02);
        img_rgb_gammaCorrect(:,:,2) = gammaCorrection(channelG, 1.02, 1.02);
        img_rgb_gammaCorrect(:,:,3) = gammaCorrection(channelB, 1.02, 1.02);
        
        clear channelR channelG channelB imgTmp;
    end

    % 显示调试
    %{
    figure (1)
    subplot(2,7,1)
    imshow(imgGray);
    subplot(2,7,2)
    imshow(img_gray_homoFilter);
    subplot(2,7,3)
    imshow(img_gray_medfilt);
    subplot(2,7,4)
    imshow(img_gray_saltAndPepper);
    subplot(2,7,5)
    imshow(img_gray_histeq);
    subplot(2,7,6)
    imshow(img_gray_gausFilter);
    subplot(2,7,7)
    imshow(img_gray_prewittSharp);
    if is_process_rgb
        subplot(2,7,8)
        imshow(imgRgb);
        subplot(2,7,9)
        imshow(img_rgb_homoFilter);
        subplot(2,7,10)
        imshow(img_rgb_medfilt);
        subplot(2,7,11)
        imshow(img_rgb_saltAndPepper);
        subplot(2,7,12)
        imshow(img_rgb_histeq);
        subplot(2,7,13)
        imshow(img_rgb_gausFilter);
        subplot(2,7,14)
        imshow(img_rgb_prewittSharp);
    end
    close 1; %关闭figure
    %}

    % 随机生成 当前图片需要进行几次操作
    objectNum = randi([1, Maximum_number_of_targets]);
        
    % 随机生成多种操作类型(目标类别)以及对应的种子坐标
    labelSet = zeros(objectNum,1);
    seedCoordinateSet = zeros(objectNum,2, 'gpuArray');
    for i = 1 : objectNum
        labelSet(i,1) = randi([1, 8]);
%         labelSet(i,1) = 4;
        seedCoordinateSet(i,1) = randi([5, cols-5]);%不要太靠边上
        seedCoordinateSet(i,2) = randi([5, rows-5]);
    end
    
    % 对图像各种子点进行生长
    img_gray_mask = zeros([size(imgGray),objectNum+1]);%保存各个生成的目标区域模板和最后一个合成模板mask
    for i = 1 : objectNum
        step = randi(step_range_control_the_size_of_object);
        if the_region_of_opera == "irregular"
            img_gray_mask(:,:,i) = generate_irregular_areas_based_on_one_point(img_gray_mask(:,:,i), seedCoordinateSet(i,1:2), step);
        elseif the_region_of_opera == "retangle"
            img_gray_mask(:,:,i) = generate_retangle_areas_based_on_one_point(img_gray_mask(:,:,i), seedCoordinateSet(i,1:2), step);
        end
    end
    
    % 如果不允许目标重合，进行处理
    overlapIdxSet = zeros(1,objectNum); %存放重合数组的mask代号
    if ~is_allow_objects_to_overlap
        for i = 2 : objectNum %冒泡处理
            for j = 1 : i-1
            	[img_gray_mask(:,:,j), img_gray_mask(:,:,i), is_overlap] = eliminate_overlap(img_gray_mask(:,:,j), img_gray_mask(:,:,i));
                if is_overlap == true
                    overlapIdxSet(1,i) = 1;
                end
            end
        end
    end
    
    % 删除重合无效的数据
    overlapIdx = find(overlapIdxSet == 1);
    objectNum = objectNum - size(overlapIdx,2);
    img_gray_mask(:,:,overlapIdx) = [];
    
    % 所有mask叠加
    for i = 1 : objectNum
        img_gray_mask(:,:,end) = img_gray_mask(:,:,end) + img_gray_mask(:,:,i);
    end
    
    % 计算每个的宽高
    object_info = zeros(objectNum,21);
    pg_point_set = zeros(objectNum, 8);
    for i = 1 : objectNum
        object_info(i,1) = labelSet(i,1);
        object_info(i,2:3) = [cols,rows];
        % [left,top,w,h,cx,cy,right,bottom,area, cx_rate, cy_rate, w_rate, h_rate]
        [left,top,w,h,cx,cy,right,bottom,area,cx_rate,cy_rate,w_rate,h_rate] = get_box_of_object(img_gray_mask(:,:,i)); 
        object_info(i,4:16) = [left,top,w,h,cx,cy,right,bottom,area,cx_rate,cy_rate,w_rate,h_rate];
        
        % 20210122 每个单层mask进行最大占比平行四边形计算
        [pg_x, pg_y, pg_side1, pg_side2, pg_theta, p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y] = Parallelogram_det(img_gray_mask(:,:,i));
        
        [top_left_x, top_left_y, bottom_right_x, bottom_right_y] = get_top_left_and_bottom_right(p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y);
        % object_info(i,17:21) = [pg_x, pg_y, pg_side1, pg_side2, pg_theta];
        object_info(i,17:21) = [top_left_x, top_left_y, bottom_right_x, bottom_right_y, pg_theta];
        pg_point_set(i,1:8) = [p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y];
    end
    clear left top w h cx cy right bottom area;
    
    % 在输出图像上叠加各操作
    grayOut = imgGray;
    if is_process_rgb
        rgbOut = imgRgb;
    end
    for i = 1 : objectNum
        region = regionprops(img_gray_mask(:,:,i), 'PixelList'); %获取所有像素
        pixel_list = region.PixelList;
        switch labelSet(i,1)
            case 1
                for j = 1 : size(pixel_list,1)
                    grayOut(pixel_list(j,2),pixel_list(j,1)) = img_gray_homoFilter(pixel_list(j,2),pixel_list(j,1));
                    if is_process_rgb
                        rgbOut(pixel_list(j,2),pixel_list(j,1),:) = img_rgb_homoFilter(pixel_list(j,2),pixel_list(j,1),:);
                    end
                end
            case 2
                for j = 1 : size(pixel_list,1)
                    grayOut(pixel_list(j,2),pixel_list(j,1)) = img_gray_medfilt(pixel_list(j,2),pixel_list(j,1));
                    if is_process_rgb
                        rgbOut(pixel_list(j,2),pixel_list(j,1),:) = img_rgb_medfilt(pixel_list(j,2),pixel_list(j,1),:);
                    end
                end
            case 3
                %{
                for j = 1 : size(pixel_list,1)
                    grayOut(pixel_list(j,2),pixel_list(j,1)) = img_gray_saltAndPepper(pixel_list(j,2),pixel_list(j,1));
                    if is_process_rgb
                        rgbOut(pixel_list(j,2),pixel_list(j,1),:) = img_rgb_saltAndPepper(pixel_list(j,2),pixel_list(j,1),:);
                    end
                end
                %}
                for j = 1 : size(pixel_list,1)
                    grayOut(pixel_list(j,2),pixel_list(j,1)) = img_gray_awgn(pixel_list(j,2),pixel_list(j,1));
                    if is_process_rgb
                        rgbOut(pixel_list(j,2),pixel_list(j,1),:) = img_rgb_awgn(pixel_list(j,2),pixel_list(j,1),:);
                    end
                end
            case 4
                % 先整图直方图均衡化，然后取不规则区域
                for j = 1 : size(pixel_list,1)
                    grayOut(pixel_list(j,2),pixel_list(j,1)) = img_gray_histeq(pixel_list(j,2),pixel_list(j,1));
                    if is_process_rgb
                        rgbOut(pixel_list(j,2),pixel_list(j,1),:) = img_rgb_histeq(pixel_list(j,2),pixel_list(j,1),:);
                    end
                end
                % 先取不规则区域, 然后局部直方图均衡化
                %{
                grayOut = histeq_in_local_irregular_area(grayOut, img_gray_mask(:,:,i));
                if is_process_rgb
                    rgbOut(:,:,1) = histeq_in_local_irregular_area(rgbOut(:,:,1), img_gray_mask(:,:,i));
                    rgbOut(:,:,2) = histeq_in_local_irregular_area(rgbOut(:,:,2), img_gray_mask(:,:,i));
                    rgbOut(:,:,3) = histeq_in_local_irregular_area(rgbOut(:,:,3), img_gray_mask(:,:,i));
                end
                %}
            case 5
                for j = 1 : size(pixel_list,1)
                    grayOut(pixel_list(j,2),pixel_list(j,1)) = img_gray_gausFilter(pixel_list(j,2),pixel_list(j,1));
                    if is_process_rgb
                        rgbOut(pixel_list(j,2),pixel_list(j,1),:) = img_rgb_gausFilter(pixel_list(j,2),pixel_list(j,1),:);
                    end
                end
            case 6
                for j = 1 : size(pixel_list,1)
                    grayOut(pixel_list(j,2),pixel_list(j,1)) = img_gray_prewittSharp(pixel_list(j,2),pixel_list(j,1));
                    if is_process_rgb
                        rgbOut(pixel_list(j,2),pixel_list(j,1),:) = img_rgb_prewittSharp(pixel_list(j,2),pixel_list(j,1),:);
                    end
                end
            case 7
                for j = 1 : size(pixel_list,1)
                    grayOut(pixel_list(j,2),pixel_list(j,1)) = img_gray_resampling(pixel_list(j,2),pixel_list(j,1));
                    if is_process_rgb
                        rgbOut(pixel_list(j,2),pixel_list(j,1),:) = img_rgb_resampling(pixel_list(j,2),pixel_list(j,1),:);
                    end
                end
            case 8
                for j = 1 : size(pixel_list,1)
                    grayOut(pixel_list(j,2),pixel_list(j,1)) = img_gray_gammaCorrect(pixel_list(j,2),pixel_list(j,1));
                    if is_process_rgb
                        rgbOut(pixel_list(j,2),pixel_list(j,1),:) = img_rgb_gammaCorrect(pixel_list(j,2),pixel_list(j,1),:);
                    end
                end
            otherwise
                disp('labelIdx out of range');
        end
    end

    % 绘制矩形框
    grayOutWithBox = grayOut;
    if is_process_rgb
        rgbOutWithBox = rgbOut;
    end
    position = zeros(objectNum,4);
    label_str = cell(objectNum,1);
    color = cell(objectNum,1);
    for i = 1 : objectNum
        position(i,1:4) = object_info(i,4:7);
        switch object_info(i,1)
            case 1
                label_str{i} = 'homofilt';
                color{i} = 'cyan';
            case 2
                label_str{i} = 'medianfilt';
                color{i} = 'blue';
            case 3
                label_str{i} = 'addnoise';
                color{i} = 'green';
            case 4
                label_str{i} = 'histeq';
                color{i} = 'magenta';
            case 5
                label_str{i} = 'gaussfilt';
                color{i} = 'black';
            case 6
                label_str{i} = 'sharp';
                color{i} = 'red';
            case 7
                label_str{i} = 'resampling';
                color{i} = 'white';
            case 8
                label_str{i} = 'gamma';
                color{i} = 'black';
            otherwise
                disp('class out of range');
        end
    end
    grayOutWithBox = insertObjectAnnotation(grayOutWithBox, 'rectangle', position, label_str,'color', color, 'textcolor', 'black', 'LineWidth', 1);
    if is_process_rgb
        rgbOutWithBox = insertObjectAnnotation(rgbOutWithBox, 'rectangle', position, label_str,'color', color, 'textcolor', 'black', 'LineWidth', 1);
    end
    
    % 20210122绘制平行四边形
    if is_parallelogram == logical(true)
        for i = 1 : objectNum
            grayOutWithBox = draw_line_by_two_point(grayOutWithBox,pg_point_set(i,1),pg_point_set(i,2),pg_point_set(i,3),pg_point_set(i,4));
            grayOutWithBox = draw_line_by_two_point(grayOutWithBox,pg_point_set(i,3),pg_point_set(i,4),pg_point_set(i,5),pg_point_set(i,6));
            grayOutWithBox = draw_line_by_two_point(grayOutWithBox,pg_point_set(i,5),pg_point_set(i,6),pg_point_set(i,7),pg_point_set(i,8));
            grayOutWithBox = draw_line_by_two_point(grayOutWithBox,pg_point_set(i,7),pg_point_set(i,8),pg_point_set(i,1),pg_point_set(i,2));
        end
        if is_process_rgb
            for i = 1 : objectNum
                rgbOutWithBox = draw_line_by_two_point(rgbOutWithBox,pg_point_set(i,1),pg_point_set(i,2),pg_point_set(i,3),pg_point_set(i,4));
                rgbOutWithBox = draw_line_by_two_point(rgbOutWithBox,pg_point_set(i,3),pg_point_set(i,4),pg_point_set(i,5),pg_point_set(i,6));
                rgbOutWithBox = draw_line_by_two_point(rgbOutWithBox,pg_point_set(i,5),pg_point_set(i,6),pg_point_set(i,7),pg_point_set(i,8));
                rgbOutWithBox = draw_line_by_two_point(rgbOutWithBox,pg_point_set(i,7),pg_point_set(i,8),pg_point_set(i,1),pg_point_set(i,2));
            end
        end
    end

    % 保存图像文件
    imwrite(grayOutWithBox,picGrayWithBoxOutPath{1});
    imwrite(imgGray, picGrayPath{1}, 'Compression','none');%jpg存在压缩，考虑png无压缩保存
    imwrite(grayOut, picGrayOutPath{1}, 'Compression','none');
    imwrite(img_gray_mask(:,:,end), picMask{1},'Compression','none');
    if is_process_rgb
        imwrite(rgbOutWithBox,picRgbWithBoxOutPath{1});
        imwrite(imgRgb, picRgbPath{1}, 'Compression','none');
        imwrite(rgbOut, picRgbOutPath{1}, 'Compression','none');
        imwrite(rgbOut, picRgbJpgOutPath{1});
    end
    
    % 保存文本文件
    txt_yolo_path = strcat(imgDataOutPath,'\','yolo_label_txt','\',imgDataDir(picCount).name);
    txt_yolo_path = strrep(txt_yolo_path, '.jpg', '.txt');
    voc_label_xml = strcat(imgDataOutPath,'\','voc_label_xml','\',imgDataDir(picCount).name);
    voc_label_xml = strrep(voc_label_xml, '.jpg', '.xml');
    voc_label_xml_pg = strcat(imgDataOutPath,'\','voc_label_xml_pg','\',imgDataDir(picCount).name);
    voc_label_xml_pg = strrep(voc_label_xml_pg, '.jpg', '.xml');
    xlsx_all_info_path = strcat(imgDataOutPath,'\','xlsx_all_info','\',imgDataDir(picCount).name);
    xlsx_all_info_path = strrep(xlsx_all_info_path, '.jpg', '.xlsx');
    txt_yolo_data = zeros(objectNum, 5);
    for i = 1 : objectNum
        txt_yolo_data(i,1) = object_info(i,1);
        txt_yolo_data(i,2:5) = object_info(i,13:16);
    end
    dlmwrite(txt_yolo_path, txt_yolo_data, 'delimiter',' ');
    xlswrite(xlsx_all_info_path, object_info);
    % 接下来写xml
    if is_parallelogram == logical(true)
        write_xml_pg(voc_label_xml_pg, [cols,rows,3], object_info, labelStrSet)
    end
    write_xml(voc_label_xml, [cols,rows,3], object_info, labelStrSet)
    
    % 结束了单张图片处理
%     disp('endok');
    % 调试显示
%     figure (2)
%     subplot(1,2,1)
%     imshow(rgbOutWithBox);
%     close 2; %关闭figure
    
    % 显示速度进程
    if mod(picCount, 10) == 0
        disp(['n:', num2str(picCount), '/', num2str(imgCountTotal)]);
        % 暂停0.1s
        pause(0.05);
    end
    
end %结束了所有图片处理

% 调用python脚本，生成darknet yolo需要的txt label
disp('图片和部分标签生成成功，接下来调用python脚本，生成darknet yolo需要的txt label，把所有图片标注信息放到一个txt文件中......');
disp('script 1 ...');
[status1,cmdout1]=system('python.exe D:\\Research\\My_tamper_detect_dataset_generate\\script\\get_darknet_yolo_txt.py');
disp('script 2 ...');
[status2,cmdout2]=system('python.exe D:\\Research\\My_tamper_detect_dataset_generate\\script\\read_all_pic_name_to_a_txt.py');
disp('script 3 ...');
[status3,cmdout3]=system('python.exe D:\\Research\\My_tamper_detect_dataset_generate\\script\\copy_file_to_vocdataset_and_cocodataset.py');
disp('script 4 ...');
[status4,cmdout4]=system('python.exe D:\\Research\\My_tamper_detect_dataset_generate\\script\\get_jpg_path_and_xml_path_to_voc_txt.py');
disp('script 5 ...');
[status5,cmdout5]=system('python.exe D:\\Research\\My_tamper_detect_dataset_generate\\script\\voc_to_coco2.py');
disp('script 6 ...');
[status6,cmdout6]=system('python.exe D:\\Research\\My_tamper_detect_dataset_generate\\script\\delete_label_list_first_line.py');

% 结束
toc;
fprintf('即时间：%f h\n', toc/3600);
disp('end');
