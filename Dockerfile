FROM centos:7

COPY . /workdir

WORKDIR /workdir

RUN yum install -y bison-devel readline-devel zlib-devel openssl-devel wget \
  && yum groupinstall -y 'Development Tools' \
  && ./configure --with-blocksize=32 --with-wal-blocksize=32 \
  && make && make all && make install
