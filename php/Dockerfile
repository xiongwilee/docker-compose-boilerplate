FROM php:7.0-fpm

# 更新apt-get源 使用阿里云的源
#RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
#	echo "deb http://mirrors.aliyuncs.com/debian stretch main contrib non-free" > /etc/apt/sources.list && \
#	echo "deb http://mirrors.aliyuncs.com/debian stretch-proposed-updates main contrib non-free" >> /etc/apt/sources.list && \
#	echo "deb http://mirrors.aliyuncs.com/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list && \
#	echo "deb http://mirrors.aliyuncs.com/debian stretch-backports main contrib non-free" >> /etc/apt/sources.list && \
#	echo "deb-src http://mirrors.aliyuncs.com/debian stretch main contrib non-free" >> /etc/apt/sources.list && \
#	echo "deb-src http://mirrors.aliyuncs.com/debian stretch-proposed-updates main contrib non-free" >> /etc/apt/sources.list && \
#	echo "deb-src http://mirrors.aliyuncs.com/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list && \
#	echo "deb-src http://mirrors.aliyuncs.com/debian stretch-backports main contrib non-free" >> /etc/apt/sources.list && \
#	echo "deb http://mirrors.aliyuncs.com/debian-security/ stretch/updates main non-free contrib" >> /etc/apt/sources.list && \
#	echo "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable" >> /etc/apt/sources.list && \
#	echo "deb-src http://mirrors.aliyuncs.com/debian-security/ stretch/updates main non-free contrib" >> /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y iputils-ping \
    && docker-php-ext-install mysqli \
    && docker-php-ext-enable mysqli \
    && docker-php-ext-install pdo_mysql