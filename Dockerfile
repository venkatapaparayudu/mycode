FROM centos:latest
MAINTAINER yugandhar

RUN yum repolist

RUN yum -y install httpd

EXPOSE 80

RUN echo "httpd" >> /root/.bashrc

CMD ["/bin/bash"]
