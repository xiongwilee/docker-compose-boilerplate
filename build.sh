#!/bin/bash

# 任何命令执行错误直接报错退出
set -e

# 业务路径
compose_path=`cd "$(dirname $0)"; pwd`;
app_path="$compose_path/php"
nginx_path="$compose_path/nginx"

# 当前操作的用户
cur_name=""
del_name=""

# 当前操作的模块
# 格式: web:online,service:online,tool:online
cur_mods=""

# 是否更新模块的环境变量
# 格式：web:true,service:false,tool:false
cur_envs=""

# 获取命令行参数
unset OPTIND
while getopts "u:m:e:d:" OPT; do
    case $OPT in
        u)
            cur_name="$OPTARG"
        ;;
        m)
            cur_mods="$OPTARG"
        ;;
        e)
            cur_envs="$OPTARG"
        ;;
        d)
            del_name="$OPTARG"
        ;;
    esac
done

##
# 帮助提示
##
function help() {
    echo "Example:"
    echo "  ./build.sh -u xiongwilee -m web:online,service:online,tool:online"
    echo "Usage:"
    echo "  -u 必填，用户名                       示例：default"
    echo "  -m 选填，要更新代码的业务模块         示例：web:online,service:online,tool:online"
    echo "  -e 选填，更新业务模块对应的环境变量   示例：web:true,service:false,tool:false"
    echo "  -d 选填，删除用户                     示例：default"
}

function greenEcho() {
    echo -e "\033[32m ${1} \033[0m";
}

##
# 添加钩子
# @param $1 钩子名称 add | upd
# @param $2 @sapp_path
# @param $3 @capp_path
# @param $4 @cur_name
# @param $5 @cur_mode
##
function addHook() {
    # 执行创建目录完成之后的钩子
    local hook_file=${2}/${5}/on_${1}.sh;
    if [ -f "$hook_file" ]; then
        /bin/sh ${hook_file} ${4} ${5} ${2} ${3};
    fi
}

##
# 添加App模块
# @param $1 当前用户名
##
function addApp() {
    local sapp_path=$app_path/sample;
    local capp_path=$app_path/$1;

    if [ ! -d "$capp_path" ];then
        mkdir $capp_path;
    fi

    for i in `ls ${sapp_path}`
    do
        local gitaddress=$sapp_path/$i/.gitaddress;

        if [ -f "$gitaddress" ];then
            local gitpath=`cat $gitaddress`;
            # clone代码到对应目录
            git clone $gitpath $capp_path/$i;

            greenEcho "创建仓储$gitpah成功: $capp_path/$i";
        else
            cp -r $sapp_path/$i $capp_path/;
            greenEcho "创建目录${i}成功: $capp_path/$i";
        fi

        # 执行创建目录完成之后的钩子
        addHook "add" ${sapp_path} ${capp_path} ${cur_name} ${i};
    done
}

##
# 添加nginx配置
# @param $1 当前用户名
##
function addNginx() {
    local cnginx_path=$nginx_path/conf.d/$1.conf;

    cp $nginx_path/conf.d/sample $cnginx_path;
    # TODO: 这里在MacOS下会报错
    sed -i s/\$\{name\}/$1/g $cnginx_path;

    greenEcho "创建nginx配置文件成功: $cnginx_path";

    restartNginx;
}

##
# 重启nginx
##
function restartNginx() {
    cd $compose_path;
    # 重启nginx
    # 通过以下reload方式提示会报错：the input device is not a TTY
    # 改回docker-compose restart nginx的方案
    # docker-compose exec nginx service nginx reload;
    docker-compose restart nginx;
    cd -;
}

##
# 添加角色
# @param $1 用户名
##
function addRole() {
    addNginx $1;
    addApp $1;
}

##
# 删除角色
# @param $1 当前要删除的用户名
##
function delRole() {
    rm -rf $app_path/$1;
    rm -rf $nginx_path/conf.d/$1.conf;

    restartNginx;
    greenEcho "删除用户 ${1} 成功！";
}

##
# 更新模块代码
# @param $1 模块名称
# @param $2 分支或tag名称
##
function updateMod() {
    local sapp_path=$app_path/sample;
    local capp_path=$app_path/$cur_name;

    local mod_path=$capp_path/$1;
    local branch=$2;

    cd $mod_path;

    # 清除所有untrack文件
    git clean -df
    git checkout -f && git fetch && git fetch --tags

    git checkout $branch
    git pull origin $branch

    cd -;

    addHook "upd" ${sapp_path} ${capp_path} ${cur_name} ${1};

    greenEcho "更新 ${1} 模块代码为 ${branch} 成功: ${mod_path}"
}

##
# 部署模块
##
function deployMod() {
    local sapp_path=$app_path/sample;
    local capp_path=$app_path/$cur_name;
    local cnginx_path=$nginx_path/conf.d/$cur_name.conf;

    if [ ! -d "$capp_path" -o ! -f "$cnginx_path" ]; then
        greenEcho "当前用户 ${cur_name} 尚未创建，自动创建中……";
        addRole $cur_name;
    fi

    # 获取$cur_mods参数
    # 然后每个模块更新最新代码
    OLD_IFS="$IFS"
    IFS=","
    array=($cur_mods)
    IFS="$OLD_IFS"

    for each in ${array[*]}
    do
        local cur_module=`echo $each | cut -d ":" -f1`;
        local cur_branch=`echo $each | cut -d ":" -f2`;
        if [ -n "$cur_module" ]; then
            if [ -z "$cur_branch" -o "$cur_branch"x = "null"x ]; then
                greenEcho "${cur_module} 模块分支不存在，跳过更新";
            else
                updateMod $cur_module $cur_branch;
            fi
        else
            greenEcho "无效的模块名";
        fi
    done

    # 更新环境配置的钩子
    if [ -n "$cur_envs" ];then
        OLD_IFS="$IFS"
        IFS=","
        array=($cur_envs)
        IFS="$OLD_IFS"

        for each in ${array[*]}
        do
            local cur_module=`echo $each | cut -d ":" -f1`;
            local cur_update=`echo $each | cut -d ":" -f2`;
            if [ "$cur_update"x = "true"x ]; then
                # 执行创建目录完成之后的钩子
                addHook "env" ${sapp_path} ${capp_path} ${cur_name} ${cur_module};
                greenEcho "更新 ${cur_module} 环境变量完成！"
            fi
        done
    fi
}

function main() {
    if [ -n "$del_name" ]; then
        delRole $del_name;
    elif [ -n "$cur_name" -a -z "$cur_mods" ]; then
        addRole $cur_name;
    elif [ -z "$cur_name" -o -z "$cur_mods" ]; then
        help;
    else
        deployMod;
    fi
}

main