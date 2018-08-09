# docker-compose-boilerplate

基于docker-compose实现的测试环境部署方案，主要特性包括：

1. 快捷部署多人nginx+php的开发测试环境，不依赖K8S/Swarm
2. 无需繁杂的机器配置，一键添加开发测试角色
3. 容器镜像创建之后无需更新，常驻服务

## Getting Started

**注意：** 快速开始前，请确保当前环境已经安装了：
- `Docker`
- `Docker-compose`
- `git`

### 1、下载代码

```
$ git clone https://github.com/xiongwilee/docker-compose-boilerplate.git
```

### 2、添加测试用户`demo`
```
$ cd docker-compose-boilerplate
$ sh build.sh -u demo
```
此时，在`app/`会创建`demo`目录，在`nginx/conf.d`会创建`demo.conf`文件。

### 3、启动服务
```
$ docker-compose up -d
```
此时，再执行`docker-compose ps`会发现创建了三个镜像；访问：http://sample.demo.testdomain.com 返回`phpinfo()`信息，说明创建成功。

## Instructions

### 1、

## Configure

### 1、开发测试环境泛域名解析

### 2、`docker-compose.yml`配置说明

### 3、模块配置

#### 1）部署脚本`build.sh`

#### 2）PHP模块

`app/Dockerfile`文件说明：

`app/sample`目录说明：

##### a. 仓储配置

- `.gitaddress`：声明当前模块的远程仓储地址

##### b. 钩子

- `onAdd.sh`：创建角色时下载PHP模块代码完成之后的回调钩子

##### c. 示例目录`app/sample/sample`：

#### 3）Nginx配置

##### a. `nginx/conf.d`目录

##### b. `nginx/log`目录

#### 4）Jenkins配置方案

## TODO

- [ ] 前端代码部署方案
- [ ] 独立的数据库方案
- [ ] 添加secret参数配置
- [ ] 使nignx平滑reload而不是暴力restart