FROM centos:7

COPY . /workdir

RUN yum install -y bison-devel readline-devel zlib-devel openssl-devel wget \
  && ./configure --with-blocksize=32 --with-wal-blocksize=32 \
  && make && make all && make install
