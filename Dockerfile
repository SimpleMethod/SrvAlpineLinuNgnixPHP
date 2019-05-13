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
	DISPLAY_WIDTH=1920 \
	DISPLAY_HEIGHT=1080 \
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
	openjdk8 \
	maven \
	gradle

RUN apk --no-cache add php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype \
    php7-mbstring php7-gd nginx 
	
# Clone noVNC from Github
RUN ln -s /root/noVNC/vnc_lite.html /root/noVNC/index.html 

#Changing the configuration of the xfce4-terminal
RUN curl -l https://raw.githubusercontent.com/SimpleMethod/Alpine-noVNC/master/xfce4-terminal/terminalrc --create-dirs  -o /root/.config/xfce4/terminal/terminalrc
RUN chmod +x /etc/php_package.sh
RUN chmod +x /etc/supervisor/conf.d/exec.sh

#Copying the configuration for supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf



# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/tmp/nginx && \
  chown -R nobody.nobody /var/log/nginx

# Setup document root
RUN mkdir -p /var/www/html

VOLUME ["/sys/fs/cgroup", "/root/.mozilla", "/var/lib/"]

#Starting the supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]