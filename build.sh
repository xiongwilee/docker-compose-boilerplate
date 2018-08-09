#!/bin/bash

# 任何命令执行错误直接报错退出
set -e

# 业务路径
compose_path="$HOME/docker-compose"
app_path="$compose_path/app"
nginx_path="$compose_path/nginx"

# 当前操作的用户
cur_name=""
del_name=""

# 当前操作的模块
# 格式: admin:online,sercice:online,tool:online
cur_mods=""

# 获取命令行参数
unset OPTIND
while getopts "u:m:d:" OPT; do
    case $OPT in
        u)
            cur_name="$OPTARG"
        ;;
        m)
            cur_mods="$OPTARG"
        ;;
        d)
            del_name="$OPTARG"
        ;;
    esac
done

# 帮助提示
function help() {
    echo "Example:"
    echo "  ./build.sh -u xiongweilie -m admin:online,service:online,tool:online"
    echo "Usage:"
    echo "  -u 必填，用户名                 示例：default"
    echo "  -m 必填，要更新代码的业务模块   示例：admin:online,service:online,tool:online"
    echo "  -d 选填，删除用户               示例：default"
}

function greenEcho() {
    echo -e "\033[32m ${1} \033[0m";
}

# 添加App模块
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
	local on_add_hook=$sapp_path/$i/onAdd.sh;
	if [ -f "$on_add_hook" ]; then
            /bin/sh ${on_add_hook} ${cur_name} ${i} ${sapp_path} ${capp_path} ${gitpath};
	fi
    done
}

# 添加nginx配置
function addNginx() {
    local cnginx_path=$nginx_path/conf.d/$1.conf;

    cp $nginx_path/conf.d/sample $cnginx_path;
    sed -i s/\$\{name\}/$1/g $cnginx_path;

    greenEcho "创建nginx配置文件成功: $cnginx_path";

    restartNginx;
}

# 重启nginx
function restartNginx() {
    # 重启nginx
    cd $compose_path;
    docker-compose restart nginx;
    cd -;
}

# 添加角色
function addRole() {
    addNginx $1;
    addApp $1;
}

# 删除角色
function delRole() {
    rm -rf $app_path/$1;
    rm -rf $nginx_path/conf.d/$1.conf;
    restartNginx;
    greenEcho "删除用户 ${1} 成功！";
}

# 更新模块代码
function updateMod() {
    local mod_path=$app_path/$cur_name/$1;
    local branch=$2;

    cd $mod_path;

    # 清除所有untrack文件
    git clean -df
    git checkout -f && git fetch && git fetch --tags

    local branch_name=$(git branch | grep $branch)
    if [ "$branch"x = "master"x  ]; then
        git pull origin master
    elif [ "$branch"x = "online"x ]; then
        git pull origin online
    elif [ -n "$branch_name" ];then
        git branch -D $branch;
    fi

    git checkout $branch

    cd -;

    greenEcho "更新 ${1} 模块代码为 ${branch} 成功: ${mod_path}"
}

# 部署模块
function deployMod() {
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
	updateMod $cur_module $cur_branch;
    done
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
