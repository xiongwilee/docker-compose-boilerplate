# docker-compose

基于docker-compose实现nginx+php测试环境快速部署方案，主要特性包括：

1. 快捷部署多人nginx+php的开发测试环境，不依赖K8S/Swarm
2. 无需繁杂的机器配置，一键添加开发测试角色

## Getting Started

**注意：** 快速开始前，请确保当前环境已经安装了：
- Docker
- Docker-compose
- git

### 1、下载代码

```
$ git clone https://github.com/xiongwilee/docker-compose-boilerplate.git
```

### 2、添加测试用户`demo`
```
$ cd docker-compose
$ sh build.sh -u demo -m admin:master
```
此时，在`app/`会创建`demo`目录，在`nginx/conf.d`会创建`demo.conf`文件。

### 3、启动服务
```
$ docker-compose up -d
```
此时，再执行`docker-compose ps`会发现创建了三个镜像；访问：http://sample.demo.testdomain.com 返回`phpinfo()`信息，说明创建成功。

## Instructions

## Configure

### 1、开发测试环境泛域名解析

### 2、`docker-compose.yml`配置说明

### 3、模块配置

#### 1）部署脚本`build.sh`

```
Example:
  ./build.sh -u xiongweilie -m admin:online,service:online,tool:online
Usage:
  -u 必填，用户名                 示例：default
  -m 必填，要更新代码的业务模块   示例：admin:online,service:online,tool:online
  -d 选填，删除用户               示例：default
```

#### 2）PHP模块

`app/Dockerfile`文件说明：

`app/sample`目录说明：

##### a. 仓储配置

- `.gitaddress`：声明当前模块的远程仓储地址

##### b. 钩子

- `on_add.sh`：创建角色时下载PHP模块代码完成之后的回调钩子，用已更新环境变量等文件
- `on_upd.sh`：某个模块更新完成之后的回调钩子，用以编译等操作

##### c. 示例目录`app/sample/sample`：

#### 3）Nginx配置

##### a. `nginx/conf.d`目录

##### b. `nginx/log`目录

#### 4）Jenkins配置方案

##### a. 安装插件获取当前用户

##### b. Docker镜像中的Jenkins与宿主机通信

##### c. 添加job

```
echo "正在将 admin-fe:${admin_fe},admin:${admin},service:${service},tool:${tool}  部署到 ${BUILD_USER_ID} 环境"

ssh apple@{jenkins内网IP} "sh ~/docker-compose/build.sh -u ${BUILD_USER_ID} -m admin-fe:${admin_fe},admin:${admin},service:${service},tool:${tool}";
```

#### 5）Gitlab-ci/runner持续集成方案

##### a. 提交`.gitlab-ci.yml`文件

##### b. 注册gitlab runner

## TODO

- [x] 集成jenkins
- [x] 前端代码部署方案
- [ ] 独立的数据库方案
- [ ] 使nignx平滑reload而不是暴力restart
