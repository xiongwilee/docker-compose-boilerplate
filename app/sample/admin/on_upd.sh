#!/bin/bash

##
# 更新代码完成之后的行为
##

## 参数如下
# 当前用户
cur_name=$1;
# 当前模块名称
cur_mode=$2;
# sample目录的地址
sapp_path=$3;
# 当前用户的地址
capp_path=$4;
##

# 将admin-fe里的产出文件再拷贝一次，
#   以防部署代码清除untrack文件时静态文件丢失
cp -r $capp_path/${cur_mode}-fe/dist/* $capp_path/$cur_mode/;

