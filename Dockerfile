FROM node:slim

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# -----------------------------------------------------------------------------
# Install dependencies
# -----------------------------------------------------------------------------
RUN \
  dpkg --add-architecture i386 && \
  apt-get update -qqy && \
  apt-get install -y --force-yes \
    curl \
    build-essential \
    bzip2 \
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
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true \
    | /usr/bin/debconf-set-selections && \
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
    | tee /etc/apt/sources.list.d/webupd8team-java.list && \
  echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
    | tee -a /etc/apt/sources.list.d/webupd8team-java.list && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 && \
  apt-get update -qqy && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# -----------------------------------------------------------------------------
# Install Gradle
# -----------------------------------------------------------------------------
RUN \
  cd /opt && \
  wget -q $(wget -q -O- https://gradle.org/install/ \
    | grep -o 'https://.*gradle.*bin.zip' \
    | head -n 1) && \
  unzip gradle*bin*.zip && rm gradle*bin.zip && \
  cd gradle*/bin/ && \
  ln -s "$(pwd)/gradle" /usr/local/bin/

# -----------------------------------------------------------------------------
# Install Android SDK
# -----------------------------------------------------------------------------
RUN \
  cd /opt && \
  wget -q $(wget -q -O- 'https://developer.android.com/sdk' \
    | grep -o "\"https://.*android.*tools.*linux.*\"" \
    | sed "s/\"//g") && \
  unzip -d android-sdk *tools*linux*.zip && rm *tools*linux*.zip && \
  mkdir ~/.android && touch ~/.android/repositories.cfg && \
  yes | android-sdk/tools/bin/sdkmanager "platform-tools" "platforms;android-25"

# -----------------------------------------------------------------------------
# Install ionic
# Note: Cordova package installs an outdated npm binary as a dependency.
#       We need to remove the outdated npm binary and restore the symlink
#       to the original npm version that is included in the base image.
# -----------------------------------------------------------------------------
RUN \
  yarn global add cordova ionic && \
  rm -f "$(yarn global bin)/npm" && \
  cd /usr/local/bin && \
  ln -s ../lib/node_modules/npm/bin/npm-cli.js npm
