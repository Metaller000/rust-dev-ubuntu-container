ARG UBUNTU_VER=24.04
FROM ubuntu:${UBUNTU_VER} as dev
ARG CODE_VER=4.92.2

RUN apt update 
RUN apt install -y \
	apt-utils \
	tzdata \
	locales \
	git \
	curl \	
	bash-completion \
	net-tools \
	language-pack-ru \
    nano

# Настрока локали и времени
ENV TZ=Europe/Moscow
ENV DEBIAN_FRONTEND=noninteractive
ENV LANGUAGE ru_RU.UTF-8
ENV LANG ru_RU.UTF-8
ENV LC_ALL ru_RU.UTF-8
RUN locale-gen ru_RU.UTF-8 && dpkg-reconfigure locales

# Настройка терминала
ENV TERM=xterm-256color
RUN echo "PS1='\e[92m\u\e[0m:\e[35m\w\e[0m> '" >> /root/.bashrc
RUN echo 'echo -e -n "\x1b[\x35 q"' >> /root/.bashrc
RUN echo "if [ -f /etc/bash_completion ]; then . /etc/bash_completion; fi" >> /root/.bashrc

# Установка rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y

# Настройка vscode web.
ENV CODE_VER=${CODE_VER}
RUN curl -fOL https://github.com/coder/code-server/releases/download/v${CODE_VER}/code-server_${CODE_VER}_amd64.deb \ 
 && dpkg -i code-server_${CODE_VER}_amd64.deb \
 && rm code-server_${CODE_VER}_amd64.deb \
 && code-server --install-extension ms-ceintl.vscode-language-pack-ru

RUN echo "bind-addr: localhost:666" > /root/.config/code-server/config.yaml \
 && echo "cert: true" >> /root/.config/code-server/config.yaml \
 && echo '{ "workbench.colorTheme": "Default Dark Modern", "workbench.sideBar.location": "right" }' > /root/.local/share/code-server/User/settings.json
RUN openssl req -x509 -nodes -newkey rsa:2048 -keyout localhost.key -out localhost.crt -days 365 -subj "/CN=localhost"
RUN echo '"terminal.integrated.shellArgs.osx": ["--cert","/localhost.cer","--key","/localhost.key"]' >> /root/.local/share/code-server/User/settings.json

WORKDIR /app
ENTRYPOINT code-server --disable-workspace-trust --auth none --locale ru --open /app