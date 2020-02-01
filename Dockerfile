# Dockerfile to install NoMachine free v. 6 with MATE interface
FROM debian:stretch


ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y apt-utils vim xterm pulseaudio curl

ENV NOMACHINE_VERSION 6.9
ENV NOMACHINE_PACKAGE_NAME nomachine_6.9.2_1_amd64.deb
ENV NOMACHINE_MD5 86fe9a0f9ee06ee6fce41aa36674f727


RUN curl -fSL "http://download.nomachine.com/download/${NOMACHINE_VERSION}/Linux/${NOMACHINE_PACKAGE_NAME}" -o nomachine.deb \
&& echo "Expected MD5:" ${NOMACHINE_MD5} \
&& echo "${NOMACHINE_MD5} *nomachine.deb" | md5sum -c - \
&& dpkg -i nomachine.deb \
&& groupadd -r nomachine -g 433 \
&& useradd -u 431 -r -g nomachine -d /home/nomachine -s /bin/bash -c "NoMachine" nomachine \
&& mkdir /home/nomachine \
&& chown -R nomachine:nomachine /home/nomachine \
&& echo 'nomachine:nomachine' | chpasswd

RUN apt-get install gcc libx11-dev libxft-dev make pkg-config libfontconfig1-dev libfreetype6-dev -y

COPY st/ /home/nomachine/st/

RUN \
       cd /home/nomachine/st/ \
    && make install

ADD nxserver.sh /

ENTRYPOINT ["/nxserver.sh"]
