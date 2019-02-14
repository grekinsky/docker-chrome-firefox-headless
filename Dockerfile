FROM node:10.15.1-stretch-slim

# Install utilities
RUN mkdir -p /usr/share/man/man1
RUN apt-get update --fix-missing && apt-get -y upgrade \
    && apt-get install -y default-jre-headless libdbus-glib-1-2 bzip2 libxt6 --no-install-recommends

# Install chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable --no-install-recommends

# Install firefox
RUN FIREFOX_VERSION=60.0.2 \
    && wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 \
    && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
    && rm /tmp/firefox.tar.bz2 \
    && mv /opt/firefox /opt/firefox-$FIREFOX_VERSION \
    && ln -fs /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox

# Install Gecko Driver
RUN GK_VERSION=0.24.0 \
    && echo "Using GeckoDriver version: "$GK_VERSION \
    && wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v$GK_VERSION/geckodriver-v$GK_VERSION-linux64.tar.gz \
    && rm -rf /opt/geckodriver \
    && tar -C /opt -zxf /tmp/geckodriver.tar.gz \
    && rm /tmp/geckodriver.tar.gz \
    && mv /opt/geckodriver /opt/geckodriver-$GK_VERSION \
    && chmod 755 /opt/geckodriver-$GK_VERSION \
    && ln -fs /opt/geckodriver-$GK_VERSION /usr/bin/geckodriver

# Clean up
RUN rm -rf /var/lib/apt/lists/* \
    && rm -rf /src/*.deb \
    && apt-get clean

# Add user and setup home dir.
RUN groupadd --system gbrowsers  \
    && useradd --system --create-home --gid gbrowsers --groups audio,video ubrowser \
    && mkdir -p /home/ubrowser/reports \
    && mkdir -p /home/ubrowser/src/app \
    && chown --recursive ubrowser:gbrowsers /home/ubrowser

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init \
    && chown --recursive ubrowser:gbrowsers /usr/local/bin/dumb-init

COPY start.sh /home/ubrowser/src/config/start.sh

RUN chmod +x /home/ubrowser/src/config/start.sh \
    && chown --recursive ubrowser:gbrowsers /home/ubrowser/src

USER ubrowser

WORKDIR /home/ubrowser/src/app

ENTRYPOINT ["dumb-init", "--"]

CMD ["/home/ubrowser/src/config/start.sh"]
