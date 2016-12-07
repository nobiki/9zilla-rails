FROM debian:jessie
MAINTAINER Naoaki Obiki
RUN apt-get update
ARG username="9zilla"
ARG password="9zilla"
RUN apt-get install -y sudo
RUN mkdir /home/$username
RUN useradd -s /bin/bash -d /home/$username $username && echo "$username:$password" | chpasswd
RUN echo ${username}' ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/$username
RUN mkdir -p /home/$username/ci/
RUN chown -R $username:$username /home/$username
RUN mkdir /var/workspace/
RUN ln -s /var/workspace/ /home/$username/workspace
RUN chown $username:$username /home/$username/workspace
RUN apt-get install -y make gcc g++ lsb-release
RUN apt-get install -y vim git tig bzip2 unzip tree sed bash-completion dbus openssl curl wget expect cron
RUN apt-get install -y vim dnsutils procps siege pandoc locales dialog htop inetutils-traceroute iftop bmon iptraf nload slurm sl toilet lolcat
RUN locale-gen ja_JP.UTF-8
RUN localedef -f UTF-8 -i ja_JP ja_JP
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:jp
ENV LC_ALL ja_JP.UTF-8
RUN cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN apt-get install -y chrony
RUN sed -ri "s/^server 0.debian.pool.ntp.org/#server 0.debian.pool.ntp.org/" /etc/chrony/chrony.conf
RUN sed -ri "s/^server 1.debian.pool.ntp.org/#server 1.debian.pool.ntp.org/" /etc/chrony/chrony.conf
RUN sed -ri "s/^server 2.debian.pool.ntp.org/#server 2.debian.pool.ntp.org/" /etc/chrony/chrony.conf
RUN sed -ri "s/^server 3.debian.pool.ntp.org/#server 3.debian.pool.ntp.org/" /etc/chrony/chrony.conf
RUN echo "server ntp0.jst.mfeed.ad.jp" >> /etc/chrony/chrony.conf
RUN echo "server ntp1.jst.mfeed.ad.jp" >> /etc/chrony/chrony.conf
RUN echo "server ntp2.jst.mfeed.ad.jp" >> /etc/chrony/chrony.conf
RUN echo "allow 172.18/12" >> /etc/chrony/chrony.conf
RUN systemctl enable chrony
RUN sudo -u $username mkdir -p /home/$username/gitwork/bitbucket/dotfiles/
RUN sudo -u $username git clone "https://nobiki@bitbucket.org/nobiki/dotfiles.git" /home/$username/gitwork/bitbucket/dotfiles/
RUN sudo -u $username cp /etc/bash.bashrc /home/$username/.bashrc
RUN sudo -u $username cp /home/$username/gitwork/bitbucket/dotfiles/.bash_profile /home/$username/.bash_profile
RUN sudo -u $username cp /home/$username/gitwork/bitbucket/dotfiles/.gitconfig /home/$username/.gitconfig
RUN sudo -u $username mkdir -p /home/$username/.ssh/
RUN sudo -u $username cp /home/$username/gitwork/bitbucket/dotfiles/.ssh/config /home/$username/.ssh/config
RUN curl -o /usr/local/bin/hcat "https://raw.githubusercontent.com/nobiki/bash-hcat/master/hcat"
RUN chmod +x /usr/local/bin/hcat
RUN curl -o /usr/local/bin/jq "http://stedolan.github.io/jq/download/linux64/jq"
RUN chmod +x /usr/local/bin/jq
ADD archives/peco_linux_amd64/peco /usr/local/bin/
RUN chmod +x /usr/local/bin/peco
RUN git clone "https://github.com/b4b4r07/enhancd.git" /usr/local/src/enhancd
RUN chmod +x /usr/local/src/enhancd/init.sh
RUN echo 'source /usr/local/src/enhancd/init.sh' >> /home/$username/.bash_profile
RUN echo 'if [ -e $HOME/.anyenv/bin ]; then' >> /home/$username/.bash_profile
RUN echo '  export PATH="$HOME/.anyenv/bin:$PATH"' >> /home/$username/.bash_profile
RUN echo '  eval "$(anyenv init -)"' >> /home/$username/.bash_profile
RUN echo 'fi' >> /home/$username/.bash_profile
RUN apt-get install -y xvfb
RUN echo "Xvfb :99 -screen 0 1920x1200x24 > /dev/null &" > /usr/local/bin/selenium-xvfb
RUN chmod +x /usr/local/bin/selenium-xvfb
RUN wget -q -O - "https://dl-ssl.google.com/linux/linux_signing_key.pub" | apt-key add -
RUN echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update
RUN apt-get install -y google-chrome-stable
RUN apt-get install -y firefox-esr
RUN apt-get install -y php5 php5-curl php5-imagick imagemagick
RUN systemctl disable apache2
RUN curl -sS "https://getcomposer.org/installer" | php -- --install-dir=/usr/local/bin
RUN mkdir -p /home/$username/.composer
RUN chown $username:$username /home/$username/.composer
RUN apt-get install -y default-jdk
ADD archives/selenium-server-standalone.jar /usr/local/bin/
RUN echo "DISPLAY=:99 java -jar /usr/local/bin/selenium-server-standalone.jar -Dwebdriver.chrome.driver=/usr/local/lib/selenium/chromedriver" > /usr/local/bin/selenium
RUN chmod +x /usr/local/bin/selenium
RUN mkdir /usr/local/lib/selenium
ADD archives/chromedriver /usr/local/lib/selenium/
RUN mkdir -p /usr/local/lib/behat/
ADD settings/behat/composer.json /usr/local/lib/behat/
ADD settings/behat/behat.yml /usr/local/lib/behat/
RUN chown -R $username:$username /usr/local/lib/behat/
RUN ln -s /usr/local/lib/behat/bin/behat /usr/local/bin/behat
RUN ln -s /usr/local/lib/behat/ /home/$username/ci/behat
RUN apt-get install -y nginx
ADD settings/nginx/nginx.conf /etc/nginx/nginx.conf
RUN chmod 755 /var/log/nginx/
RUN systemctl enable nginx
RUN apt-get install -y libssl-dev libreadline-dev zlib1g-dev
RUN apt-get install -y mariadb-client libmysqlclient-dev
