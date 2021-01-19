## 统计各类回归框的数量

import os
from pathlib import Path
import shutil

#txt所在目录
txt_dir = '/home/ganyd/DataSet/dataset_irregular_area_detect_forge/yolo_label_txt'

#获取目录下所有目录与文件名称
fileNameList = os.listdir(txt_dir)

#类别数量
classCount = [0,0,0,0,0,0]

for i in range(len(fileNameList)):

    txt_file = txt_dir + '/' + fileNameList[i]
    with open(txt_file, "r") as f:  # 打开文件
        for line in f.readlines():
            strList = line.split(' ')  #空格划分
            classLabel = int(strList[0])
            classCount[classLabel] = classCount[classLabel] + 1

#统计所有回归框总数
classCount[0] = classCount[1] + classCount[2] + classCount[3] + classCount[4] + classCount[5]
##计算各类别所占比例
classCountRate = [0,0,0,0,0,0]
for i in range(len(classCountRate)):
    classCountRate[i] = classCount[i] / classCount[0]

##打印显示
print("总数量：%d\t%.3f\n第一类：%d\t%.3f\n第二类：%d\t%.3f\n第三类：%d\t%.3f\n第四类：%d\t%.3f\n第五类：%d\t%.3f" %
    (classCount[0],classCountRate[0],classCount[1],classCountRate[1],
    classCount[2],classCountRate[2],classCount[3],classCountRate[3],
    classCount[4],classCountRate[4],classCount[5],classCountRate[5]))