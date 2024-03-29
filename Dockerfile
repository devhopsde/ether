FROM       centos:7
MAINTAINER fhnbg

# Update everything
RUN yum -y update && yum clean all

# Install epel-release & then the rest
RUN yum -y install epel-release     && \
    yum -y install openssl npm node && \
    yum clean all

RUN mkdir /var/lib/etherpad
WORKDIR   /var/lib/etherpad

# Get etherpad 1.7.5
RUN curl -L https://github.com/ether/etherpad-lite/tarball/1.7.5 | tar -xz --strip-components=1

# Add settings.json
COPY settings.json ./
# Add startup script
COPY docker-entrypoint.sh ./
 
# A few workarounds so we can run as non-root on openshift
RUN mkdir /.npm
COPY fix-permissions.sh ./
RUN  ./fix-permissions.sh /.npm
RUN  ./fix-permissions.sh /var/lib/etherpad

# Run as a random user. This happens on openshift by default so we
# might as well always run as a random user
USER 1001

# Listens on 9001 by default
EXPOSE 9001
ENTRYPOINT ["./docker-entrypoint.sh"]
