# 生成目标检测数据集，目标需要是可以代码生成的一种操作

![](https://img.shields.io/static/v1?label=matlab&message=2019&color=blue)

## 2021.3.9

当前是八种操作类型
4.m是平行四边形框
添加的write_xml_pg.m是保存平行四边形label信息的，保存的是平行四边形左上顶点和右下顶点坐标以及theta角度
将保存操作后的图片添加一种jpg格式的，但是图像质量要求要高，'Compression','none'，文档介绍是无压缩，没有验证过

## 2020.10.8

增加了prewitt锐化类别

## 2020.8.22 update

更新了生成方法，新增加了不规则区域生成，完善了用户设置方式，使用更方便，运行generate_dataset_of_object_detect_forgery2.m文件。
而不推荐generate_dataset_of_object_detect_forgery.m

## 2020.8.17 update

生成目标检测的数据集，这里目标是自己生成的一些操作
比如这个取证数据集，给定图片集，读取每一张图片，会随机取一块矩形区域，提取ROI进行对应操作，保存当前矩形框变量和操作后的图片，储存到本地文件
操作数目前是5，对应类别标签1-5，稍微看懂m文件都是可以修改  
输入输出目录和一些用户参数在用户区修改  
author: ganyongdong ***<1141951289@qq.com>***
