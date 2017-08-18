FROM node:slim

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# -----------------------------------------------------------------------------
# Install dependencies
# -----------------------------------------------------------------------------
RUN \
  apt-get update -qqy && \
  dpkg --add-architecture i386 && \
  apt-get update -qqy && \
  apt-get install -y --force-yes \
    curl \
    expect \
    git \
    libc6-i386 \
    libqt5widgets5 \
    lib32stdc++6 \
    lib32gcc1 \
    lib32ncurses5 \
    lib32z1 \
    python \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# -----------------------------------------------------------------------------
# Install JAVA
# -----------------------------------------------------------------------------
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list && \
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
  apt-get update -qqy && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# -----------------------------------------------------------------------------
# Install ionic
# -----------------------------------------------------------------------------
RUN yarn global add cordova ionic

# -----------------------------------------------------------------------------
# Install Android SDK
# -----------------------------------------------------------------------------
RUN cd /opt && \
    wget https://dl.google.com/android/repository/tools_r25.2.3-linux.zip && \
    unzip tools_r25.2.3-linux.zip -d android-sdk-linux && \
    rm tools_r25.2.3-linux.zip && \
    (echo y | android-sdk-linux/tools/android update sdk -u -a -t 1,2,3,6,10,14,16,23,32,33,34,35,36,38,124,160,166,167,168,169,170,171,172)
