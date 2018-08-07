#!/bin/bash

##
# git clone 完成之后的行为
##

# 当前用户
cur_name=$1;
# 当前模块名称
cur_mode=$2;
# sample目录的地址
sapp_path=$3;
# 当前用户的地址
capp_path=$4;
# git仓储的地址
gitaddress=$5;

# 第一步：复制.env道当前仓储
cp $sapp_path/$cur_mode/.env $capp_path/$cur_mode/;
# 第二步：修改storage bootstrap目录的权限
chmod -R 777 $capp_path/$cur_mode/storage;
chmod -R 777 $capp_path/$cur_mode/bootstrap;
