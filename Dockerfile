FROM centos:latest
MAINTAINER yugandhar

RUN yum repolist

RUN yum -y install mysqld

EXPOSE 3306

RUN echo "mysqld" >> /root/.bashrc

CMD ["/bin/bash"]
