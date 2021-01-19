## 读取txt_file文件中文件路径名称，从data_source_dir所在目录中找到该文件，复制到data_output_dir中

import os
from pathlib import Path
import shutil

txt_file = '/home/ganyd/DataSet/dataset_irregular_area_detect_forge/val.txt'
data_source_dir = '/home/ganyd/DataSet/dataset_irregular_area_detect_forge/rgbOut'
data_output_dir = '/home/ganyd/DataSet/dataset_irregular_area_detect_forge/val'

with open(txt_file, "r") as f:  # 打开文件
    for line in f.readlines():
        line = line.strip('\n')  #去掉列表中每一个元素的换行符
        picPath = line.split(' ',1)[0]
        print(picPath)
        picPathSplit = picPath.split('/')
        targetFile = picPathSplit[len(picPathSplit)-1]
        targetFile = data_output_dir + '/' + targetFile
        print(targetFile)
        shutil.copyfile(picPath, targetFile)

