FROM alpine:latest

MAINTAINER Yiqiu Jia <yiqiujia@hotmail.com>

ARG S3FS_VERSION=1.85

RUN apk --no-cache --no-progress upgrade && \
    apk --no-cache --no-progress add bash tar alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev && \
	rm -rf /var/cache/apk/* && \
	mkdir /usr/src && \
	curl -L https://github.com/s3fs-fuse/s3fs-fuse/archive/v${S3FS_VERSION}.tar.gz | tar zxv -C /usr/src && \
	cd /usr/src/s3fs-fuse-${S3FS_VERSION} && ./autogen.sh && ./configure --prefix=/usr && make && make install && \
	mkdir /mnt/s3fs && chmod 777 /mnt/s3fs && ln -s /mnt/s3fs/ ~

ENV AccessKeyId= \
	SecretAccessKey= \
	Region=

RUN echo $(date "+%Y-%m-%d_%H:%M:%S") >> /.image_times && \
	echo $(date "+%Y-%m-%d_%H:%M:%S") > /.image_time && \
	echo "land007/s3fs" >> /.image_names && \
	echo "land007/s3fs" > /.image_name

VOLUME /mnt/s3fs

RUN echo 'echo ${AccessKeyId}:${SecretAccessKey} > /opt/s3fs_passwd && chmod 600 /opt/s3fs_passwd && nohup s3fs ${Region} /mnt/s3fs -o passwd_file=/opt/s3fs_passwd  -d -d -f -o f2 -o curldbg > /dev/null 2>&1 &' > /start.sh && chmod +x /start.sh

CMD /start.sh ; bash

#docker build -t land007/s3fs:latest .
#docker rm -f s3fs ; docker run -it --privileged --name s3fs land007/s3fs:latest
