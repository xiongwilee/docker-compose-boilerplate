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

cd $capp_path/$cur_mode;

# 安装依赖
rm -rf node_modules;
npm install --registry=https://registry.npm.taobao.org;

# 编译文件
npm run build;

# 复制到对应目录
# 截取 cur_mode 去除后面的-fe字符
match_mode=${cur_mode%-fe};
cp -r $capp_path/$cur_mode/dist/* $capp_path/$match_mode/;

cd -;
