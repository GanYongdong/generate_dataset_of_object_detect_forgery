%
% ����Ŀ��������ݼ�������Ŀ�����Լ����ɵ�һЩ����
% �������ȡ֤���ݼ�������ͼƬ������ȡÿһ��ͼƬ�������ȡһ�����������ȡROI���ж�Ӧ���������浱ǰ���ο�����Ͳ������ͼƬ�����浽�����ļ�
% ������Ŀǰ��5����Ӧ����ǩ1-5����΢����m�ļ����ǿ����޸�
% �������Ŀ¼��һЩ�û��������û����޸�
% author: ganyongdong <1141951289@qq.com> 2020.8.17
%

clc; clear; close all;

% �û�ѡ����
is_process_rgb = logical(true); % �Ƿ���RGBͼ��
Maximum_number_of_targets = 10; % ÿ��ͼƬ���Ŀ�����
Maximum_proportion_of_target_in_image = 0.4; % Ŀ��ռͼ��������
imgDataPath = 'D:\DataSet\VOC2012_JPEGImages'; %Դͼ��Ŀ¼
imgDataOutPath = 'D:\MyStudyProj\generate_dataset_of_object_detect_forgery\dataset'; %���ͼ��Ŀ¼

% ��ʱ��ʼ
tic;
% ȫ�ּ���
count = 1;
% Ԥ��label��ѡ�������
labelSet = ["homoFilter", "medianFiltering", "additiveNoise", "histogramEqualization", "gaussianBlurring"];
% ���ձ����lable������box����
labelArrIdxFile = [];
labelArrStrFile = ["str"];
boxArrFile = [];
% ������ļ�·��
inputPathFile = ["str"];

% �Բ�ͬͼ��ѭ��
imgDataDir = dir(imgDataPath);
imgCountTotal = size(imgDataDir,1) - 2;
for picCount = 1:length(imgDataDir) % ���������ļ�
% for picCount = 1:20 % ���������ļ�
    if(isequal(imgDataDir(picCount).name,'.') || isequal(imgDataDir(picCount).name,'..'))
        % ȥ��ϵͳ�Դ����������ļ���
        continue;
    end
    
    % ��ȡ����ͼ��·��
    picPath = strcat(imgDataPath,'\',imgDataDir(picCount).name);
    if inputPathFile(1,1) == "str"
        inputPathFile(1,1) = picPath;
    else
        inputPathFile(end+1,:) = picPath;
    end
    
    % �������ͼ��·��
    picGrayPath = strcat(imgDataOutPath,'\','gray','\',imgDataDir(picCount).name);
    picGrayOutPath = strcat(imgDataOutPath,'\','grayOut','\',imgDataDir(picCount).name);
    picGrayWithBoxOutPath = strcat(imgDataOutPath,'\','grayOutWithBox','\',imgDataDir(picCount).name);
    picRgbPath = strcat(imgDataOutPath,'\','rgb','\',imgDataDir(picCount).name);
    picRgbOutPath = strcat(imgDataOutPath,'\','rgbOut','\',imgDataDir(picCount).name);
    picRgbWithBoxOutPath = strcat(imgDataOutPath,'\','rgbOutWithBox','\',imgDataDir(picCount).name);
    
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
    labelArrStr = ["str"];
    boxArr = [];
    labelWithBoxFile = [];
    
    % ��ȡ����ͼ��
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
    
    % ѭ�����ɶ��Ŀ��
    for objectIdx = 1 : Maximum_number_of_targets
        
        % ������ɵ�ǰĿ�����
        labelIdx = randi([1, 5]);
        % labelIdx = 1 ; % ��ǰǿ�ƣ��ǵ�ע�͵����������
        label = labelSet(labelIdx);
        
        % ������ɺ˳ߴ磬��ͼ��Χ��
        kernelVal = randi([3, 11]);
        if mod(kernelVal, 2) == 0
            kernelVal = kernelVal + 1;
        end
        
        % ������ɴ�������
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
        imgRoi = imcrop(imgGray, [roiLeft,roiTop,roiWidth,roiHeight]); % ��ȡroi����
        if is_process_rgb
            imgRoiRgb = imcrop(imgSrc, [roiLeft,roiTop,roiWidth,roiHeight]); % ��ȡroi����rgb
        end
        [roiHeight, roiWidth] = size(imgRoi);
        roiRight = roiLeft + roiWidth - 1;
        roiBottom = roiTop + roiHeight - 1;
        
        % ������ʼ�����ɱ��С
        roiImgOperaRGB = [];
        coder.varsize('roiImgOperaRGB'); %�����ɱ��С
        
        % ��Ӧ���ж�Ӧ����
        switch labelIdx
            case 1 % HomoFilter
                roiImgOpera = HomoFilter(imgRoi, 2, 0.25, 1, 0.05); % ̬ͬ�˲�
                if is_process_rgb
                    channelR = imgRoiRgb(:,:,1);
                    channelG = imgRoiRgb(:,:,2);
                    channelB = imgRoiRgb(:,:,3);
                    clear roiImgOperaRGB;
                    roiImgOperaRGB(:,:,1) = HomoFilter(channelR, 2, 0.25, 1, 0.05); % ̬ͬ�˲�
                    roiImgOperaRGB(:,:,2) = HomoFilter(channelG, 2, 0.25, 1, 0.05); % ̬ͬ�˲�
                    roiImgOperaRGB(:,:,3) = HomoFilter(channelB, 2, 0.25, 1, 0.05); % ̬ͬ�˲�
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
                img = im2double(imgRoi); % ��Ϊ��Ҫ����ͼƬ��·��;im2double����һ������
                roiImgOperaDouble = imnoise(img, 'salt & pepper', 0.05); %����ܶ�Ϊ5%�Ľ�������
                roiImgOpera = im2uint8(roiImgOperaDouble); 
                if is_process_rgb
                    channelR = imgRoiRgb(:,:,1);
                    channelG = imgRoiRgb(:,:,2);
                    channelB = imgRoiRgb(:,:,3);
                    clear roiImgOperaRGB;
                    img = im2double(channelR); % ��һ������
                    roiImgOperaRGB(:,:,1) = imnoise(img, 'salt & pepper', 0.05); %����ܶ�Ϊ5%�Ľ�������
                    img = im2double(channelG); % ��һ������
                    roiImgOperaRGB(:,:,2) = imnoise(img, 'salt & pepper', 0.05); %����ܶ�Ϊ5%�Ľ�������
                    img = im2double(channelB); % ��һ������
                    roiImgOperaRGB(:,:,3) = imnoise(img, 'salt & pepper', 0.05); %����ܶ�Ϊ5%�Ľ�������
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
                gausFilter = fspecial('gaussian',[kernelVal kernelVal],1);  %��˹�˲�
                roiImgOpera = imfilter(imgRoi, gausFilter, 'replicate');      %����������������άͼ������˲�
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
                
            otherwise % ����
                disp('labelIdx must be Integer and in 1-5');
        end
        
        % ȥ����Χ�ĺڱ�
        edgeBlack = floor(kernelVal / 2);
        roiLeft = roiLeft + edgeBlack;
        roiRight = roiRight - edgeBlack;
        roiTop = roiTop + edgeBlack;
        roiBottom = roiBottom - edgeBlack;
        roiWidth = roiWidth - edgeBlack;
        roiHeight = roiHeight - edgeBlack;
        
        % ����box
        box = [roiLeft, roiRight, roiTop, roiBottom, roiWidth, roiHeight, roiCenterPointX, roiCenterPointY];
        
        % �ж��Ƿ��غϴ���
        is_process_vaild = logical(true); % �Ƿ���RGBͼ��
        for i = 1 : size(boxArr, 1)
            boxTmp = boxArr(i, :);
            boxDistance = sqrt(power((box(1,7)-boxTmp(1,7)), 2) + power((box(1,8)-boxTmp(1,8)), 2)); %��������box���ĵ����
            boxDistanceMin = sqrt(power((box(1,5)+boxTmp(1,5))/2, 2) + power((box(1,6)+boxTmp(1,6))/2, 2));
            if boxDistance < boxDistanceMin
                is_process_vaild = logical(false);
                % disp("Ŀ���غ�");
                break;
            end
        end
        
        if is_process_vaild == true
            % ����boxArr
            boxArr(end+1,:) = box;
            labelArrIdx(end+1,1) = labelIdx;
            if labelArrStr(1,1) == "str"
                labelArrStr(1,1) = labelSet(1, labelIdx);
            else
                labelArrStr(end+1,1) = labelSet(1, labelIdx);
            end
            % ����label �� box�ı�׼ѵ���ļ�
            labelWithBox = [labelIdx, roiCenterPointX/cols, roiCenterPointY/rows, roiWidth/cols, roiHeight/rows];
            labelWithBoxFile(end+1,:) = labelWithBox;
            
            % �������غ������ͼ���ںϣ��ֱ𱣴�rgb gray�� ����ͼ�ʹ�label��Ĵ���ͼ
            roiImgOpera = roiImgOpera((edgeBlack+1):roiHeight, (edgeBlack+1):roiWidth); % �˲����roiͼȥ���ڱ�
            imgGrayOut(roiTop:roiBottom, roiLeft:roiRight) = roiImgOpera; % ���˲����roiͼ�ںϽ�ԭ�Ҷ�ͼ
            imgGrayWithBox(roiTop:roiBottom, roiLeft:roiRight) = roiImgOpera;
            imgGrayWithBox = insertShape(imgGrayWithBox, 'Line', [roiLeft, roiTop, roiLeft, roiBottom], 'LineWidth', 1, 'Color', 'black');
            imgGrayWithBox = insertShape(imgGrayWithBox, 'Line', [roiLeft, roiBottom, roiRight, roiBottom], 'LineWidth', 1, 'Color', 'black');
            imgGrayWithBox = insertShape(imgGrayWithBox, 'Line', [roiRight, roiBottom, roiRight, roiTop], 'LineWidth', 1, 'Color', 'black');
            imgGrayWithBox = insertShape(imgGrayWithBox, 'Line', [roiLeft, roiTop, roiRight, roiTop], 'LineWidth', 1, 'Color', 'black');
            
            if is_process_rgb
                roiImgOperaRGB = roiImgOperaRGB((edgeBlack+1):roiHeight, (edgeBlack+1):roiWidth); % �˲����roiͼȥ���ڱ�
                imgSrcOut(roiTop:roiBottom, roiLeft:roiRight) = roiImgOperaRGB; % ���˲����roiͼ�ںϽ�ԭrgbͼ
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
        
        % ����һ����Ĵ���
        % disp('a object finish');
    end
    
    % label��ʾ
    % subplot(2,1,1)
    % imshow(imgSrcWithBox);
    % subplot(2,1,2)
    % imshow(imgGrayWithBox);
    
    % һ��ͼƬ�������ˣ���Ӧ����ͼƬ��label
    imwrite(imgGray, picGrayPath);
    imwrite(imgGrayOut, picGrayOutPath);
    imwrite(imgGrayWithBox, picGrayWithBoxOutPath);
    imwrite(imgSrc, picRgbPath);
    imwrite(imgSrcOut, picRgbOutPath);
    imwrite(imgSrcWithBox, picRgbWithBoxOutPath);
    
    % �����Ӧ�ı�ǩ�ļ�
    labelArrIdxFile(count,1:size(labelArrIdx,1)) = labelArrIdx';
    labelArrStrFile(count,1:size(labelArrStr,1)) = labelArrStr';
    boxArrFile(end+1:end+size(boxArr,1),:) = boxArr;
    
    % ����yolo��׼��ǩ�ļ�
    dlmwrite(saveTxtPathOflabelWithBoxFile, labelWithBoxFile, 'delimiter',' ');
    xlswrite(saveTxtPathOflabelWithBoxXlsxFile, labelWithBoxFile);
    
    % ��ʾ�ٶȽ���
    if mod(count,10) == 0
        disp(['n:', num2str(count), '/', num2str(imgCountTotal)]);
        % ��ͣ0.1s
        pause(0.1);
    end
    
    % ͼ�����+1
    count = count + 1;
    
end

% ȫ��ͼƬ��������������ǩ��Ӧ��txt�ļ�
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

% ��ʱ��������ʾ
toc;

% ����
disp('end');