%
% ���ɼ��������ݼ����������ݼ��Ƿ��д������ɵ�Ŀ������������
% author: ganyongdong <1141951289@qq.com> 2021.4.2
%

clc; clear; close all;

% �û�ѡ����
is_process_rgb = logical(true); % �Ƿ���RGBͼ��
is_allow_objects_to_overlap = logical(false); % �Ƿ�����object�غϣ�ָ����Ŀ�겻��������û���غϣ�����ܻ����غϵ�
the_region_of_opera = "irregular"; %���в�����������״����ѡ"irregular"��"retangle"��
% �ֱ������ɲ������������;��β������򣬿����Լ�д����������������generate_irregular_areas_based_on_one_point.m��
% generate_retangle_areas_based_on_one_point.m
Maximum_number_of_targets = 8; % ÿ��ͼƬ���Ŀ�����
Maximum_proportion_of_target_in_image = 0.4; % Ŀ��ռͼ��������
imgDataPath = 'D:\Dataset\PASCAL_VOC\VOCtrainval_2012\VOC2012\JPEGImages'; %Դͼ��Ŀ¼
imgDataOutPath = 'D:\Research\My_tamper_detect_dataset_generate\dataset_tmp'; %���ͼ��Ŀ¼
kernel_range = [3,3]; %��ֵ�˲�����ֵ�˲��͸�˹�˲�ѡ����в������ں˳ߴ緶Χ��һ�����У�С����ǰ������ں���Ⱦ��ǹ̶���С
saltAndPepper_density = 0.03; %���������ܶ�
homo_d0 = 0.008; %̬ͬ�˲���D0����ֵ
sharp_factor = 0.7; %�񻯳̶�[0,1]
step_range_control_the_size_of_object = [25,45]; %�������ɵ�Ŀ���С�Ĳ������ܹ���ſ���,��Ⱦ��Ǽ����̶���С
factor_of_imgSrc_zoom = 0.6; %��Դͼ�����ű��������Կ������ͼ��ߴ磬�ӿ첿������ѵ���ٶȡ������ڽ��в���֮ǰ���ţ���Ӱ�����������
is_parallelogram = logical(true); %�Ƿ�����ƽ���ı��α�ǩ��������ξ��α�ǩ��Ĭ�ϻ�����

% ��ʱ��ʼ
tic;
% ȫ�ּ���
count = 1;
% Ԥ��label��ѡ�������
labelStrSet = ["homofilt"; "medianfilt"; "awgn"; "histeq"; "gaussfilt"; "sharp"; "resampling"; "gamma"];
% ���ձ����lable������box����

% дlabel_list�ļ�
label_list_txt = strcat(imgDataOutPath, '\voc_dataset\label_list.txt');
label_list = cellstr(labelStrSet);
T = cell2table(label_list);
writetable(T,label_list_txt);
clear label_list_txt label_list T;

% �Բ�ͬͼ��ѭ��
imgDataDir = dir(imgDataPath);
imgCountTotal = size(imgDataDir,1) - 2;
for picCount = 1:length(imgDataDir) % ��������ͼƬ�ļ�

    % for picCount = 1:20 % ���������ļ�
    if(isequal(imgDataDir(picCount).name,'.') || isequal(imgDataDir(picCount).name,'..'))
        % ȥ��ϵͳ�Դ����������ļ���
        continue;
    end
    
    % ��ȡ����ͼ��·��
    picPath = strcat(imgDataPath,'\',imgDataDir(picCount).name);
    
    % �������ͼ��·��
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
    
    % �������yolo��׼��ǩ�ļ�·��
    nameTmp1 = imgDataDir(picCount).name;
    nameTmp2 = strsplit(nameTmp1,'.');
    nemeTmp3 = strcat(nameTmp2(1,1), '.txt');
    saveTxtPathOflabelWithBoxFile2 = strcat(imgDataOutPath,'\','label','\', nemeTmp3);
    saveTxtPathOflabelWithBoxFile = saveTxtPathOflabelWithBoxFile2{1};
    nemeTmp3 = strcat(nameTmp2(1,1), '.xlsx');
    saveTxtPathOflabelWithBoxXlsxFile2 = strcat(imgDataOutPath,'\','label','\', nemeTmp3);
    saveTxtPathOflabelWithBoxXlsxFile = saveTxtPathOflabelWithBoxXlsxFile2{1};
    
    % ���ձ����lable������box����
    labelArrIdx = [];
    labelArrStr = "str";
    boxArr = [];
    labelWithBoxFile = [];
    
    % ��ȡ����ͼ��
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
        disp('��ͨ��ͼ����');
    end
    clear imgSrc;
    imgGrayWithBox = imgGray;
    imgGrayOut = imgGray;

    % ������ɺ˳ߴ磬��ͼ��Χ��
    kernelVal = randi(kernel_range);
    if mod(kernelVal, 2) == 0 %�ں˳ߴ����Ϊ����
        kernelVal = kernelVal + 1;
    end
        
    % ����9����ͬ������ͼ�񣬺�߶�Ӧ�����ľʹ���ȡͼ��
    img_gray_homoFilter = uint8((1*255/8)*ones(size(imgGray)));
    img_gray_medfilt = uint8((2*255/8)*ones(size(imgGray)));
    img_gray_awgn = uint8((3*255/8)*ones(size(imgGray)));
    img_gray_histeq = uint8((4*255/8)*ones(size(imgGray)));
    img_gray_gausFilter = uint8((5*255/8)*ones(size(imgGray)));
	img_gray_prewittSharp = uint8((6*255/8)*ones(size(imgGray)));
    img_gray_resampling = uint8((7*255/8)*ones(size(imgGray)));
    img_gray_gammaCorrect = uint8((8*255/8)*ones(size(imgGray)));
    if is_process_rgb %�������ͨ��ͼ��
        img_rgb_homoFilter = uint8((1*255/8)*ones(size(imgRgb)));
        img_rgb_homoFilter(:,:,1) = uint8(2*255/8);
        img_rgb_homoFilter(:,:,2) = uint8(3*255/8);
        img_rgb_medfilt = uint8((2*255/8)*ones(size(imgRgb)));
        img_rgb_medfilt(:,:,1) = uint8(3*255/8);
        img_rgb_medfilt(:,:,2) = uint8(4*255/8);
        img_rgb_awgn = uint8((3*255/8)*ones(size(imgRgb)));
        img_rgb_awgn(:,:,1) = uint8(4*255/8);
        img_rgb_awgn(:,:,2) = uint8(5*255/8);
        img_rgb_histeq = uint8((4*255/8)*ones(size(imgRgb)));
        img_rgb_histeq(:,:,1) = uint8(5*255/8);
        img_rgb_histeq(:,:,2) = uint8(6*255/8);
        img_rgb_gausFilter = uint8((5*255/8)*ones(size(imgRgb)));
        img_rgb_gausFilter(:,:,1) = uint8(6*255/8);
        img_rgb_gausFilter(:,:,2) = uint8(7*255/8);
        img_rgb_prewittSharp = uint8((6*255/8)*ones(size(imgRgb)));
        img_rgb_prewittSharp(:,:,1) = uint8(7*255/8);
        img_rgb_prewittSharp(:,:,2) = uint8(8*255/8);
        img_rgb_resampling = uint8((7*255/8)*ones(size(imgRgb)));
        img_rgb_resampling(:,:,1) = uint8(8*255/8);
        img_rgb_resampling(:,:,2) = uint8(1*255/8);
        img_rgb_gammaCorrect = uint8((8*255/8)*ones(size(imgRgb)));
        img_rgb_gammaCorrect(:,:,1) = uint8(1*255/8);
        img_rgb_gammaCorrect(:,:,2) = uint8(2*255/8);
    end
    
    % ��ʾ����
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
    close 1; %�ر�figure
    %}

    % ������� ��ǰͼƬ��Ҫ���м��β���
    objectNum = randi([1, Maximum_number_of_targets]);
        
    % ������ɶ��ֲ�������(Ŀ�����)�Լ���Ӧ����������
    labelSet = zeros(objectNum,1);
    seedCoordinateSet = zeros(objectNum,2, 'gpuArray');
    for i = 1 : objectNum
        labelSet(i,1) = randi([1, 8]);
%         labelSet(i,1) = 4;
        seedCoordinateSet(i,1) = randi([5, cols-5]);%��Ҫ̫������
        seedCoordinateSet(i,2) = randi([5, rows-5]);
    end
    
    % ��ͼ������ӵ��������
    img_gray_mask = zeros([size(imgGray),objectNum+1]);%����������ɵ�Ŀ������ģ������һ���ϳ�ģ��mask
    for i = 1 : objectNum
        step = randi(step_range_control_the_size_of_object);
        if the_region_of_opera == "irregular"
            img_gray_mask(:,:,i) = generate_irregular_areas_based_on_one_point(img_gray_mask(:,:,i), seedCoordinateSet(i,1:2), step);
        elseif the_region_of_opera == "retangle"
            img_gray_mask(:,:,i) = generate_retangle_areas_based_on_one_point(img_gray_mask(:,:,i), seedCoordinateSet(i,1:2), step);
        end
    end
    
    % ���������Ŀ���غϣ����д���
    overlapIdxSet = zeros(1,objectNum); %����غ������mask����
    if ~is_allow_objects_to_overlap
        for i = 2 : objectNum %ð�ݴ���
            for j = 1 : i-1
            	[img_gray_mask(:,:,j), img_gray_mask(:,:,i), is_overlap] = eliminate_overlap(img_gray_mask(:,:,j), img_gray_mask(:,:,i));
                if is_overlap == true
                    overlapIdxSet(1,i) = 1;
                end
            end
        end
    end
    
    % ɾ���غ���Ч������
    overlapIdx = find(overlapIdxSet == 1);
    objectNum = objectNum - size(overlapIdx,2);
    img_gray_mask(:,:,overlapIdx) = [];
    
    % ����mask����
    for i = 1 : objectNum
        img_gray_mask(:,:,end) = img_gray_mask(:,:,end) + img_gray_mask(:,:,i);
    end
    
    % ����ÿ���Ŀ���
    object_info = zeros(objectNum,21);
    pg_point_set = zeros(objectNum, 8);
    for i = 1 : objectNum
        object_info(i,1) = labelSet(i,1);
        object_info(i,2:3) = [cols,rows];
        % [left,top,w,h,cx,cy,right,bottom,area, cx_rate, cy_rate, w_rate, h_rate]
        [left,top,w,h,cx,cy,right,bottom,area,cx_rate,cy_rate,w_rate,h_rate] = get_box_of_object(img_gray_mask(:,:,i)); 
        object_info(i,4:16) = [left,top,w,h,cx,cy,right,bottom,area,cx_rate,cy_rate,w_rate,h_rate];
        
        % 20210122 ÿ������mask�������ռ��ƽ���ı��μ���
        [pg_x, pg_y, pg_side1, pg_side2, pg_theta, p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y] = Parallelogram_det(img_gray_mask(:,:,i));
        
        [top_left_x, top_left_y, bottom_right_x, bottom_right_y] = get_top_left_and_bottom_right(p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y);
        % object_info(i,17:21) = [pg_x, pg_y, pg_side1, pg_side2, pg_theta];
        object_info(i,17:21) = [top_left_x, top_left_y, bottom_right_x, bottom_right_y, pg_theta];
        pg_point_set(i,1:8) = [p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y];
    end
    clear left top w h cx cy right bottom area;
    
    % �����ͼ���ϵ��Ӹ�����
    grayOut = imgGray;
    if is_process_rgb
        rgbOut = imgRgb;
    end
    for i = 1 : objectNum
        region = regionprops(img_gray_mask(:,:,i), 'PixelList'); %��ȡ��������
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
                % ����ͼֱ��ͼ���⻯��Ȼ��ȡ����������
                for j = 1 : size(pixel_list,1)
                    grayOut(pixel_list(j,2),pixel_list(j,1)) = img_gray_histeq(pixel_list(j,2),pixel_list(j,1));
                    if is_process_rgb
                        rgbOut(pixel_list(j,2),pixel_list(j,1),:) = img_rgb_histeq(pixel_list(j,2),pixel_list(j,1),:);
                    end
                end
                % ��ȡ����������, Ȼ��ֲ�ֱ��ͼ���⻯
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

    % ���ƾ��ο�
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
                label_str{i} = 'awgn';
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
    
    % 20210122����ƽ���ı���
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

    % ����ͼ���ļ�
    imwrite(grayOutWithBox,picGrayWithBoxOutPath{1});
    imwrite(imgGray, picGrayPath{1}, 'Compression','none');%jpg����ѹ��������png��ѹ������
    imwrite(grayOut, picGrayOutPath{1}, 'Compression','none');
    imwrite(img_gray_mask(:,:,end), picMask{1},'Compression','none');
    if is_process_rgb
        imwrite(rgbOutWithBox,picRgbWithBoxOutPath{1});
        imwrite(imgRgb, picRgbPath{1}, 'Compression','none');
        imwrite(rgbOut, picRgbOutPath{1}, 'Compression','none');
        imwrite(rgbOut, picRgbJpgOutPath{1});
    end
    
    % �����ı��ļ�
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
    % ������дxml
    if is_parallelogram == logical(true)
        write_xml_pg(voc_label_xml_pg, [cols,rows,3], object_info, labelStrSet)
    end
    write_xml(voc_label_xml, [cols,rows,3], object_info, labelStrSet)
    
    % �����˵���ͼƬ����
%     disp('endok');
    % ������ʾ
%     figure (2)
%     subplot(1,2,1)
%     imshow(rgbOutWithBox);
%     close 2; %�ر�figure
    
    % ��ʾ�ٶȽ���
    if mod(picCount, 10) == 0
        disp(['n:', num2str(picCount), '/', num2str(imgCountTotal)]);
        % ��ͣ0.1s
        pause(0.05);
    end
    
end %����������ͼƬ����

% ����python�ű�������darknet yolo��Ҫ��txt label
disp('ͼƬ�Ͳ��ֱ�ǩ���ɳɹ�������������python�ű�������darknet yolo��Ҫ��txt label��������ͼƬ��ע��Ϣ�ŵ�һ��txt�ļ���......');
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

% ����
toc;
fprintf('��ʱ�䣺%f h\n', toc/3600);
disp('end');