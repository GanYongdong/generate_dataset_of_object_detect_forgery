%
% ����Ŀ��������ݼ�������Ŀ�����Լ����ɵ�һЩ�ֲ���������
% �������ȡ֤���ݼ�������ͼƬ������ȡÿһ��ͼƬ�������ȡһ�鲻�������������ȡ6�ֲ��������е�һ�ֽ��в��������浱ǰ�����ο�����Ͳ������ͼƬ�����浽�����ļ�
% ������Ŀǰ��6����Ӧ����ǩ1-6
% �������Ŀ¼��һЩ�û��������û����޸�
% 20201014���£�
% 1. �Ѿֲ�ֱ��ͼ���⻯�ĳ�ֻ��ѡ�еĲ����������ڵ����ز�����⻯������λ�����ز����룻
% 2. ��Ӹ�˹������(AGWN);
% 3. �����ز�������
% 4. ����gammaУ������
% author: ganyongdong <1141951289@qq.com> 2020.10.14
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
imgDataPath = 'D:\Dataset\VOC2012_JPEGImages'; %Դͼ��Ŀ¼
imgDataOutPath = 'D:\Research\My_tamper_detect_dataset_generate\dataset_tmp'; %���ͼ��Ŀ¼
kernel_range = [3,3]; %��ֵ�˲�����ֵ�˲��͸�˹�˲�ѡ����в������ں˳ߴ緶Χ��һ�����У�С����ǰ������ں���Ⱦ��ǹ̶���С
saltAndPepper_density = 0.03; %���������ܶ�
homo_d0 = 0.008; %̬ͬ�˲���D0����ֵ
sharp_factor = 0.7; %�񻯳̶�[0,1]
step_range_control_the_size_of_object = [25,45]; %�������ɵ�Ŀ���С�Ĳ������ܹ���ſ���,��Ⱦ��Ǽ����̶���С
factor_of_imgSrc_zoom = 0.6; %��Դͼ�����ű��������Կ������ͼ��ߴ磬�ӿ첿������ѵ���ٶȡ������ڽ��в���֮ǰ���ţ���Ӱ�����������

% ��ʱ��ʼ
tic;
% ȫ�ּ���
count = 1;
% Ԥ��label��ѡ�������
labelStrSet = ["homof"; "medif"; "aspn_"; "histe"; "gausf"; "sharp"; "awgn_"; "rsamp"];

% ���ձ����lable������box����

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
    clear strTmp1 strTmp2;
    picGrayPath = strcat(imgDataOutPath,'\','gray','\',pngFileName);
    picGrayOutPath = strcat(imgDataOutPath,'\','grayOut','\',pngFileName);
    picGrayWithBoxOutPath = strcat(imgDataOutPath,'\','grayOutWithBox','\',pngFileName);
    picRgbPath = strcat(imgDataOutPath,'\','rgb','\',pngFileName);
    picRgbOutPath = strcat(imgDataOutPath,'\','rgbOut','\',pngFileName);
    picRgbWithBoxOutPath = strcat(imgDataOutPath,'\','rgbOutWithBox','\',pngFileName);
    picMask = strcat(imgDataOutPath,'\','picMask','\',pngFileName);
    
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
    img_gray_homoFilter = HomoFilter(imgGray, 2.2, 0.25, 2, homo_d0); %1̬ͬ�˲�
    img_gray_medfilt = medfilt2(imgGray, [kernelVal, kernelVal]);%2��ֵ�˲�
    imgTmp = im2double(imgGray); % ��Ϊ��Ҫ����ͼƬ��·��;im2double����һ������
    img_gray_saltAndPepper = im2uint8(imnoise(imgTmp, 'salt & pepper', saltAndPepper_density));%3.��������
    img_gray_histeq = histeq(imgGray); %4.ֱ��ͼ���⻯
    gausFilter = fspecial('gaussian',[kernelVal kernelVal],1); %��˹�˲���
    img_gray_gausFilter = imfilter(imgGray, gausFilter, 'replicate'); %5.��˹�˲�
	img_gray_prewittSharp = imgGray + uint8(filter2(fspecial('prewitt'),imgGray)*sharp_factor); %6.prewitt��
    img_gray_awgn = awgn(double(imgGray), 30, 'measured'); %7.�Ӹ�˹������
    img_gray_resampling = imresize(imresize(imgGray, 0.5), size(imgGray)); %8.�ز���
    img_gray_gammaCorrect = gammaCorrection(imgGray, 1.02, 1.02); %9.gammaУ��
    
    if is_process_rgb %�������ͨ��ͼ��
        channelR = imgRgb(:,:,1);
        channelG = imgRgb(:,:,2);
        channelB = imgRgb(:,:,3);
        clear img_rgb_homoFilter img_rgb_medfilt img_rgb_saltAndPepper img_rgb_histeq img_rgb_gausFilter img_rgb_prewittSharp;
        % 1.̬ͬ�˲�
        img_rgb_homoFilter(:,:,1) = HomoFilter(channelR, 2, 0.25, 1, homo_d0); % ̬ͬ�˲�
        img_rgb_homoFilter(:,:,2) = HomoFilter(channelG, 2, 0.25, 1, homo_d0); % ̬ͬ�˲�
        img_rgb_homoFilter(:,:,3) = HomoFilter(channelB, 2, 0.25, 1, homo_d0); % ̬ͬ�˲�
        % 2.��ֵ�˲�
        img_rgb_medfilt(:,:,1) = medfilt2(channelR, [kernelVal, kernelVal]);
        img_rgb_medfilt(:,:,2) = medfilt2(channelG, [kernelVal, kernelVal]);
        img_rgb_medfilt(:,:,3) = medfilt2(channelB, [kernelVal, kernelVal]);
        % 3.�������
        imgTmp = im2double(channelR); % ��һ������
        img_rgb_saltAndPepper(:,:,1) = im2uint8(imnoise(imgTmp, 'salt & pepper', saltAndPepper_density)); %����ܶ�Ϊ5%�Ľ�������
        imgTmp = im2double(channelG); % ��һ������
        img_rgb_saltAndPepper(:,:,2) = im2uint8(imnoise(imgTmp, 'salt & pepper', saltAndPepper_density)); %����ܶ�Ϊ5%�Ľ�������
        imgTmp = im2double(channelB); % ��һ������
        img_rgb_saltAndPepper(:,:,3) = im2uint8(imnoise(imgTmp, 'salt & pepper', saltAndPepper_density)); %����ܶ�Ϊ5%�Ľ�������
        % 4.ֱ��ͼ���⻯
        img_rgb_histeq(:,:,1) = histeq(channelR);
        img_rgb_histeq(:,:,2) = histeq(channelG);
        img_rgb_histeq(:,:,3) = histeq(channelB);
        % 5.��˹�˲�
        img_rgb_gausFilter(:,:,1) = imfilter(channelR, gausFilter, 'replicate');
        img_rgb_gausFilter(:,:,2) = imfilter(channelG, gausFilter, 'replicate');
        img_rgb_gausFilter(:,:,3) = imfilter(channelB, gausFilter, 'replicate');
        % 6.prewitt��
        img_rgb_prewittSharp(:,:,1) = channelR + uint8(filter2(fspecial('prewitt'),channelR)*sharp_factor); %prewitt��
        img_rgb_prewittSharp(:,:,2) = channelG + uint8(filter2(fspecial('prewitt'),channelG)*sharp_factor); %prewitt��
        img_rgb_prewittSharp(:,:,3) = channelB + uint8(filter2(fspecial('prewitt'),channelB)*sharp_factor); %prewitt��
        % 7.�Ӹ�˹������
        img_rgb_awgn = awgn(double(imgRgb), 30, 'measured');
        % 8.�ز���
        img_rgb_resampling = imresize3(imresize(imgRgb, 0.5), size(imgRgb));
        
        clear channelR channelG channelB imgTmp;
    end

    % ��ʾ����
%     figure (1)
%     subplot(2,7,1)
%     imshow(imgGray);
%     subplot(2,7,2)
%     imshow(img_gray_homoFilter);
%     subplot(2,7,3)
%     imshow(img_gray_medfilt);
%     subplot(2,7,4)
%     imshow(img_gray_saltAndPepper);
%     subplot(2,7,5)
%     imshow(img_gray_histeq);
%     subplot(2,7,6)
%     imshow(img_gray_gausFilter);
%     subplot(2,7,7)
%     imshow(img_gray_prewittSharp);
%     if is_process_rgb
%         subplot(2,7,8)
%         imshow(imgRgb);
%         subplot(2,7,9)
%         imshow(img_rgb_homoFilter);
%         subplot(2,7,10)
%         imshow(img_rgb_medfilt);
%         subplot(2,7,11)
%         imshow(img_rgb_saltAndPepper);
%         subplot(2,7,12)
%         imshow(img_rgb_histeq);
%         subplot(2,7,13)
%         imshow(img_rgb_gausFilter);
%         subplot(2,7,14)
%         imshow(img_rgb_prewittSharp);
%     end
%     close 1; %�ر�figure

    % ������� ��ǰͼƬ��Ҫ���м��β���
    objectNum = randi([1, Maximum_number_of_targets]);
        
    % ������ɶ��ֲ�������(Ŀ�����)�Լ���Ӧ����������
    labelSet = zeros(objectNum,1);
    seedCoordinateSet = zeros(objectNum,2);
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
    
    % ����ÿ���Ŀ��
    object_info = zeros(objectNum,16);
    for i = 1 : objectNum
        object_info(i,1) = labelSet(i,1);
        object_info(i,2:3) = [cols,rows];
        % [left,top,w,h,cx,cy,right,bottom,area, cx_rate, cy_rate, w_rate, h_rate]
        [left,top,w,h,cx,cy,right,bottom,area,cx_rate,cy_rate,w_rate,h_rate] = get_box_of_object(img_gray_mask(:,:,i)); 
        object_info(i,4:16) = [left,top,w,h,cx,cy,right,bottom,area,cx_rate,cy_rate,w_rate,h_rate];
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
                for j = 1 : size(pixel_list,1)
                    grayOut(pixel_list(j,2),pixel_list(j,1)) = img_gray_saltAndPepper(pixel_list(j,2),pixel_list(j,1));
                    if is_process_rgb
                        rgbOut(pixel_list(j,2),pixel_list(j,1),:) = img_rgb_saltAndPepper(pixel_list(j,2),pixel_list(j,1),:);
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
%                 grayOut = histeq_in_local_irregular_area(grayOut, img_gray_mask(:,:,i));
%                 if is_process_rgb
%                     rgbOut(:,:,1) = histeq_in_local_irregular_area(rgbOut(:,:,1), img_gray_mask(:,:,i));
%                     rgbOut(:,:,2) = histeq_in_local_irregular_area(rgbOut(:,:,2), img_gray_mask(:,:,i));
%                     rgbOut(:,:,3) = histeq_in_local_irregular_area(rgbOut(:,:,3), img_gray_mask(:,:,i));
%                 end
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
                    grayOut(pixel_list(j,2),pixel_list(j,1)) = img_gray_awgn(pixel_list(j,2),pixel_list(j,1));
                    if is_process_rgb
                        rgbOut(pixel_list(j,2),pixel_list(j,1),:) = img_rgb_awgn(pixel_list(j,2),pixel_list(j,1),:);
                    end
                end
            case 8
                for j = 1 : size(pixel_list,1)
                    grayOut(pixel_list(j,2),pixel_list(j,1)) = img_gray_resampling(pixel_list(j,2),pixel_list(j,1));
                    if is_process_rgb
                        rgbOut(pixel_list(j,2),pixel_list(j,1),:) = img_rgb_resampling(pixel_list(j,2),pixel_list(j,1),:);
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
                label_str{i} = 'homoFilt';
                color{i} = 'cyan';
            case 2
                label_str{i} = 'mediFilt';
                color{i} = 'blue';
            case 3
                label_str{i} = 'addNoise';
                color{i} = 'green';
            case 4
                label_str{i} = 'histgrEq';
                color{i} = 'magenta';
            case 5
                label_str{i} = 'gausFilt';
                color{i} = 'black';
            case 6
                label_str{i} = 'prewShap';
                color{i} = 'red';
            case 7
                label_str{i} = 'awgn';
                color{i} = 'white';
            case 8
                label_str{i} = 'resampling';
                color{i} = 'red';
            otherwise
                disp('class out of range');
        end
    end
    grayOutWithBox = insertObjectAnnotation(grayOutWithBox, 'rectangle', position, label_str,'color', color, 'textcolor', 'black');
    if is_process_rgb
        rgbOutWithBox = insertObjectAnnotation(rgbOutWithBox, 'rectangle', position, label_str,'color', color, 'textcolor', 'black');
    end
    
    % ����ͼ���ļ�
    imwrite(imgGray, picGrayPath{1}, 'Compression','none');%jpg����ѹ��������png��ѹ������
    imwrite(grayOut, picGrayOutPath{1}, 'Compression','none');
    imwrite(grayOutWithBox, picGrayWithBoxOutPath{1}, 'Compression','none');
    imwrite(imgRgb, picRgbPath{1}, 'Compression','none');
    imwrite(rgbOut, picRgbOutPath{1}, 'Compression','none');
    imwrite(rgbOutWithBox, picRgbWithBoxOutPath{1}, 'Compression','none');
    imwrite(img_gray_mask(:,:,end), picMask{1}, 'Compression','none');
    
    % �����ı��ļ�
    txt_yolo_path = strcat(imgDataOutPath,'\','yolo_label_txt','\',imgDataDir(picCount).name);
    txt_yolo_path = strrep(txt_yolo_path, '.jpg', '.txt');
    xml_yolo_path = strcat(imgDataOutPath,'\','yolo_label_xml','\',imgDataDir(picCount).name);
    xml_yolo_path = strrep(xml_yolo_path, '.jpg', '.xml');
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
    write_xml(xml_yolo_path, [cols,rows,3], object_info, labelStrSet)
    
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
        pause(0.1);
    end
    
end %����������ͼƬ����

% ����python�ű�������darknet yolo��Ҫ��txt label
disp('ͼƬ�Ͳ��ֱ�ǩ���ɳɹ�������������python�ű�������darknet yolo��Ҫ��txt label......');
[status,cmdout]=system('python.exe D:\\Research\\My_tamper_detect_dataset_generate\\script\\get_darknet_yolo_txt.py');

% ����
toc;
fprintf('��ʱ�䣺%f h\n', toc/3600);
disp('end');
