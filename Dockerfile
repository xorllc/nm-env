# Dockerfile to install NoMachine with suckless tools.
FROM debian:buster

ENV NM_USER=nomachine
ENV NM_GROUP=nomachine
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
            pkg-config libncursesw5-dev libreadline-dev \
            feh \
            man \
      &&  apt-get clean -y \
      &&  apt-get autoclean -y \
      &&  apt-get autoremove -y

ENV NOMACHINE_VERSION 6.9
ENV NOMACHINE_PACKAGE_NAME nomachine_6.9.2_1_amd64.deb
ENV NOMACHINE_MD5 86fe9a0f9ee06ee6fce41aa36674f727

RUN curl -fSL "http://download.nomachine.com/download/${NOMACHINE_VERSION}/Linux/${NOMACHINE_PACKAGE_NAME}" -o nomachine.deb \
&& echo "Expected MD5:" ${NOMACHINE_MD5} \
&& echo "${NOMACHINE_MD5} *nomachine.deb" | md5sum -c - \
&& dpkg -i nomachine.deb \
&& groupadd -r ${NM_GROUP} -g 433 \
&& useradd -u 431 -r -g ${NM_GROUP} -d /home/${NM_USER} -s /bin/bash -c "NoMachine" ${NM_USER} \
&& mkdir /home/${NM_USER} \
&& chown -R ${NM_USER}:${NM_USER} /home/${NM_USER} \
&& echo "${NM_USER}:${NM_USER}" | chpasswd

# Compile user tools and add dotfiles.
WORKDIR /home/${NM_USER}/

# Suckless' terminal.
COPY --chown=${NM_USER} st/ st/
RUN  cd st && make install && cd -

# Suckless' window manager.
COPY --chown=${NM_USER} dwm/ dwm/
RUN cd dwm/ && make install && cd -

# A modal web browser.
COPY --chown=${NM_USER} vimb/ vimb/
RUN cd vimb/ && make PREFIX=/usr && make PREFIX=/usr install && cd -

# NNN, a file browser.
COPY --chown=${NM_USER} nnn/ nnn/
RUN cd nnn/ && make PREFIX=/usr strip install && cd -

# File browser with vim-like navigation.
RUN apt-get install -y ranger

# Install wallpapers.
COPY wallpapers/ wallpapers/

# Other dotfiles.
COPY --chown=${NM_USER} .xinitrc .xinitrc
RUN  ln -s .xinitrc .xsessionrc
COPY --chown=${NM_USER} .fehbg .fehbg
COPY --chown=${NM_USER} .vim/ .vim/
COPY --chown=${NM_USER} .vimrc .vimrc
COPY --chown=${NM_USER} .bashrc .bashrc
COPY --chown=${NM_USER} .bash_profile .bash_profile
COPY --chown=${NM_USER} Inconsolata-g.ttf .local/share/fonts/Inconsolata-g.ttf

# NES emulator(s).
COPY --chown=${NM_USER} bjne/ bjne/
RUN apt-get install scons libsdl1.2-dev libboost-all-dev build-essential -y
RUN cd bjne/ && scons && cd -

COPY --chown=${NM_USER} LaiNES/ LaiNES/
RUN apt-get install clang scons libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev -y
RUN cd LaiNES/ && scons && cd -

# Instructions to make caps-lock a control key.
RUN apt-get install -y x11-xserver-utils
COPY .xmod .

WORKDIR /
ADD nxserver.sh /

ENTRYPOINT ["/nxserver.sh"]
