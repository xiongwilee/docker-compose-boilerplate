#!/bin/bash

##
# 更新当前环境变量的钩子
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

# 第一步：复制.env道当前仓储
cp $sapp_path/$cur_mode/.env $capp_path/$cur_mode/;
sed -i s/\$\{name\}/$cur_name/g $capp_path/$cur_mode/.env;
