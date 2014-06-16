FROM ubuntu:14.04
MAINTAINER CharlesVG

RUN apt-get update

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Installing fuse package (libreoffice-java dependency) and it's going to try to create
# a fuse device without success, due the container permissions. || : help us to ignore it. 
# Then we are going to delete the postinst fuse file and try to install it again!
# Thanks Jerome for helping me with this workaround solution! :)
# Now we are able to install the libreoffice-java package  
RUN apt-get -y install fuse  || :
RUN rm -rf /var/lib/dpkg/info/fuse.postinst
RUN apt-get -y install fuse

# Installing the environment required: xserver, xdm, flux box, roc-filer and ssh
RUN apt-get install -y xpra openssh-server pwgen xserver-xephyr xdm fluxbox sudo

# Install XRDP dependencies
RUN apt-get install -y nano vnc4server autoconf automake libtool libssl-dev libpam0g-dev libx11-dev libxfixes-dev git gcc pkg-config

RUN ln -s /usr/bin/Xorg /usr/bin/X

# Upstart and DBus have issues inside docker. We work around in order to install firefox.
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -sf /bin/true /sbin/initctl



# Installing the apps: Firefox
RUN apt-get install -y firefox

# Set locale (fix the locale warnings)
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :

# Copy the files into the container
ADD . /src

EXPOSE 22
EXPOSE 3389

# Start xdm and ssh services.
CMD ["/bin/bash", "/src/install-xrdp.sh"]

CMD ["/bin/bash", "/src/startup.sh"]
