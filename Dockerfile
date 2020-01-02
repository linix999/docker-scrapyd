From python:3.6

MAINTAINER linix

ENV DEBIAN_FRONTEND noninteractive

# Set time zone
RUN rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN apt-get update && apt-get install -y \
    git \
    vim \
    python3-pip \
    supervisor \
    fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 \
    libnspr4 libnss3 lsb-release xdg-utils libxss1 libdbus-glib-1-2 \
    curl unzip wget \
    xvfb \
    pwgen && rm -rf /var/lib/apt/lists/*

# install chromedriver and google-chrome
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    wget https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip -d /usr/bin && \
    chmod +x /usr/bin/chromedriver && \
    rm chromedriver_linux64.zip

RUN CHROME_SETUP=google-chrome.deb && \
    wget -O $CHROME_SETUP "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" && \
    dpkg -i $CHROME_SETUP && \
    apt-get install -y -f && \
    rm $CHROME_SETUP


# install phantomjs
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
    tar -jxf phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
    cp phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs && \
    rm phantomjs-2.1.1-linux-x86_64.tar.bz2

# supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/

#celeryd user
RUN adduser --disabled-password --gecos '' myuser

#scrapyd config
ADD searchSpiders.tar.xz /Work/
WORKDIR /Work/searchSpiders/
COPY scrapyd.conf /Work/searchSpiders/
COPY scrapyd.conf /usr/local/lib/python3.6/dist-packages/scrapyd/
    
ADD requirements.txt /Work/searchSpiders/
RUN pip3 install --upgrade pip
RUN pip install -r requirements.txt

EXPOSE 6800
CMD ["/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]
