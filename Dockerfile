FROM scratch
ADD x86_64/alpine-minirootfs-3.9.4-x86_64.tar.gz /

LABEL org.label-schema.name="SVR Alpine Linux OpenJDK"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.description="Alpine system witch OpenJDK 1.8.0_212"
LABEL org.label-schema.maintainer="m.mlodawski@simplemethod.io"
LABEL org.label-schema.build-date="13.05.2019"
LABEL org.label-schema.url="https://github.com/SimpleMethod/SrvAlpineLinuxNgnixPHP"

ENV DEBIAN_FRONTEND=noninteractive \
	HOME=/root \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8 \
	LC_ALL=C.UTF-8 \
	DISPLAY=:0 \
	DISPLAY_WIDTH=1280 \
	DISPLAY_HEIGHT=720 \
	SHELL=/bin/bash 

CMD ["/bin/sh"]

# Installation of the applications
RUN	apk	--update --no-cache	add	bash \
	openrc \
	socat \
	git \
	supervisor \
	xvfb \
	xfce4-terminal \
	gtk+2.0 \
	x11vnc \
	sudo \
	curl \
	htop \
	procps \
	openbox \
	gnome-icon-theme \
	lxappearance \
	tint2 \
	feh \
	lxappearance-obconf \
	ttf-freefont \
	dbus-x11 \
	unzip \
	mc \
	nano \
	vim \
	geany \
	thunar \
	firefox-esr \
	python \
	py-pip \
	nginx

	
# Clone noVNC from Github
RUN ln -s /root/noVNC/vnc_lite.html /root/noVNC/index.html 

#Changing the configuration of the xfce4-terminal
RUN curl -l https://raw.githubusercontent.com/SimpleMethod/SrvAlpineLinuxNgnix/master/terminalrc --create-dirs  -o /root/.config/xfce4/terminal/terminalrc
RUN chmod +x /etc/html_package.sh
RUN chmod +x /etc/supervisor/conf.d/exec.sh

# Configure nginx
COPY config/default.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /run/nginx

RUN chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/tmp/nginx && \
  chown -R nobody.nobody /var/log/nginx

# Setup document root
RUN mkdir -p /var/www/html

RUN chown -R nobody.nobody /var/www/html

#Copying the configuration for supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["/sys/fs/cgroup", "/root/.mozilla", "/var/lib/"]

#Starting the supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
