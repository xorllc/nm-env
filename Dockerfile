# Dockerfile to install NoMachine with suckless tools.
FROM debian:buster


ENV DEBIAN_FRONTEND=noninteractive

RUN \
          apt-get update \
      &&  apt-get upgrade -y \
      &&  apt-get install -y \
            gcc make vim curl git \
            libxinerama-dev libx11-dev libxft-dev \
            pkg-config libfontconfig1-dev libfreetype6-dev \
            apt-utils pulseaudio \
            libgtk-3-dev libglib2.0-dev webkit2gtk-4.0 \
            feh \
            man

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

# Compile user tools and add dotfiles.
WORKDIR /home/nomachine/

# Suckless' terminal.
COPY --chown=nomachine st/ st/
RUN  cd st && make install && cd -

# Suckless' window manager.
COPY --chown=nomachine dwm/ dwm/
RUN cd dwm/ && make install && cd -

# A modal web browser.
COPY --chown=nomachine vimb/ vimb/
RUN cd vimb/ && make PREFIX=/usr && make PREFIX=/usr install && cd -

# Install wallpapers.
COPY wallpapers/ wallpapers/

# Other dotfiles.
COPY --chown=nomachine .xsessionrc .xsessionrc
COPY --chown=nomachine .fehbg .fehbg
COPY --chown=nomachine .vim/ .vim/
COPY --chown=nomachine .vimrc .vimrc
COPY --chown=nomachine .bashrc .bashrc
COPY --chown=nomachine .bash_profile .bash_profile
COPY --chown=nomachine Inconsolata-g.ttf .local/share/fonts/Inconsolata-g.ttf

WORKDIR /
ADD nxserver.sh /

ENTRYPOINT ["/nxserver.sh"]
