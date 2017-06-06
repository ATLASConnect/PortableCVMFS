#!/bin/bash

# Load the fuse module into the kernel
modprobe fuse

# Install fuse
yum -y install fuse fuse-libs

# This will allow others to access our fuse mounts
echo "user_allow_other" > /etc/fuse.conf

# Allow any group to use fuse
#chmod o+rx /bin/fusermount

# Add users to the fuse group those who will we allow to mount CVMFS repositories
#usermod -a -G fuse ddl
#usermod -a -G fuse usatlas1
#usermod -a -G fuse usatlas2
#usermod -a -G fuse usatlas3
#usermod -a -G fuse usatlas4
