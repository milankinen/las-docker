FROM ubuntu:xenial
MAINTAINER "Matti Lankinen mla@reaktor.com"

# parametrize dependency versions
ARG SECO_HFST_VERSION="1.1.5"
ARG SECO_LEXI_VERSION="1.5.4"
ARG TRANSDUCER_VERSION="1.4.9"

# install required libraries
RUN apt-get update && apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update
RUN apt-get install -y build-essential git-core openjdk-8-jdk maven curl wget unzip

# install sbt
RUN curl https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt > /usr/local/bin/sbt
RUN chmod 755 /usr/local/bin/sbt

# copy missing transient maven dependencies to local repo
COPY lib /tmp/lib
RUN mvn install:install-file \
       -Dfile=/tmp/lib/anna-3.6.jar \
       -DgroupId=is2 \
       -DartifactId=anna \
       -Dversion=3.6 \
       -Dpackaging=jar \
       -DgeneratePom=true
RUN mvn install:install-file \
       -Dfile=/tmp/lib/marmot-2014-10-22.jar \
       -DgroupId=marmot \
       -DartifactId=marmot \
       -Dversion=2014-10-22 \
       -Dpackaging=jar \
       -DgeneratePom=true
RUN rm -rf /tmp/lib

# checkout deps
WORKDIR /las
RUN mkdir -p /las/deps
RUN cd /las/deps && git clone https://github.com/jiemakel/seco-hfst.git && cd seco-hfst && git checkout v${SECO_HFST_VERSION}
RUN cd /las/deps && git clone https://github.com/jiemakel/seco-lexicalanalysis.git && cd seco-lexicalanalysis && git checkout v${SECO_LEXI_VERSION}

# download transducers and models
RUN cd /las/deps/seco-lexicalanalysis \
    && curl -L -o models.tar.xz https://github.com/jiemakel/seco-lexicalanalysis/releases/download/v${TRANSDUCER_VERSION}/transducers-and-models.tar.xz
RUN cd /las/deps/seco-lexicalanalysis && ls -lh && tar vxf models.tar.xz

# install seco deps
RUN cd /las/deps/seco-hfst && mvn install -Dgpg.skip
RUN cd /las/deps/seco-lexicalanalysis && mvn install -Dgpg.skip -Dproject.build.sourceEncoding=UTF-8 -DskipTests

# install play application
RUN cd /las && git clone https://github.com/jiemakel/seco-lexicalanalysis-play.git play
RUN sed -i -E "s/\"fi.seco\" % \"lexicalanalysis\" % \"[0-9.]+\"/\"fi.seco\" % \"lexicalanalysis\" % \"${SECO_LEXI_VERSION}\"/g" /las/play/build.sbt
# change log level to info in order to track the process (takes long time...)
RUN sed -i -E 's/Level.Warn/Level.Info/g' /las/play/project/plugins.sbt
RUN cd /las/play && sbt dist
RUN cd /las/play/target/universal && unzip *.zip && rm *.zip
RUN mv /las/play/target/universal/lexicalanalysis-play* /las/app

# add custom entrypoint with easy memory config via environment variables
ENV LAS_MEMORY="2048"
RUN echo "echo \"Using $LAS_MEMORY MB memory setting...\"" > /las/app/entrypoint.sh
RUN echo "/las/app/bin/lexicalanalysis-play -mem $LAS_MEMORY" >> /las/app/entrypoint.sh && chmod 755 /las/app/entrypoint.sh

# cleanup intermediate files in order to keep image size even reasonable...
RUN rm -rf /las/play /las/deps /root/.m2 /root/.ivy2

# create user so that we can run the app without root
RUN useradd -ms /bin/bash las
RUN chown -R las /las/app
RUN apt-get clean && apt-get autoclean


EXPOSE 9000
WORKDIR /las/app
USER las
ENTRYPOINT /las/app/entrypoint.sh
