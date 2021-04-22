# First stage
FROM ubuntu:20.04 as install
ENV VERSION 14
# cheating for now
COPY bin-exclude/stata-installed-${VERSION}.tgz /root/stata.tgz
RUN cd / && tar xzf $HOME/stata.tgz \
    && rm $HOME/stata.tgz 

# Final build
FROM ubuntu:20.04
RUN apt-get update \
    && apt-get install -y locales libncurses5  \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV libpng http://ppa.launchpad.net/linuxuprising/libpng12/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1.1+1~ppa0~focal_amd64.deb
RUN apt-get update \
    && apt-get install -y wget \
    && wget -O libpng.deb "${libpng}" \
    && dpkg --install libpng.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f libpng.deb
ENV LANG en_US.utf8
ENV VERSION 14

# copying from first stage
COPY --from=install /usr/local/stata${VERSION}/ /usr/local/stata${VERSION}/
COPY stata.lic.${VERSION} /usr/local/stata${VERSION}/stata.lic
RUN ln -s /usr/local/stata${VERSION} /usr/local/stata \
    && echo "export PATH=/usr/local/stata:${PATH}" >> /root/.bashrc
ENV PATH "$PATH:/usr/local/stata" 
WORKDIR /code

# if you wanted to make this a project specific image,
# do the following:
#
#  COPY setup.do /code
#  RUN cd /code && stata -b do setup.do
#

# For licensing reasons, remove the license
# We can mount it at runtime for now

RUN rm /usr/local/stata${VERSION}/stata.lic


ENTRYPOINT ["stata-mp"]
