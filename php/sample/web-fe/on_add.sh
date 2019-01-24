#!/bin/bash

##
# git clone 完成之后的行为
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

# 第一步：clone代码
gitaddress='https://github.com/X-RU/H5-repository.git';
git clone $gitaddress $capp_path/$cur_mode;