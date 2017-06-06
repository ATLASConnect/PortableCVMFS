#!/bin/bash

# Setup Portable CVMFS to mount at "/cvmfs" with the cache on "/tmp"

# Make certain we got here via a source
if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
  echo "You must execute via \"source ${BASH_SOURCE[0]}\""
  exit
fi

# Put the mount point in our $HOME
export CVMFS_MOUNT="$(readlink -f ${HOME}/cvmfs)"

# Location of Cache and Sockets
export CVMFS_TMP="/tmp"

# Cache Quota Limit
export CVMFS_QUOTA="25000"

# MWT2 proxy list
export CVMFS_PROXY="http://uct2-squid.mwt2.org:3128;http://iut2-squid.mwt2.org:3128;http://mwt2-squid.campuscluster.illinois.edu:3128;DIRECT"


# Find out where we live
cvmfsHome="$(readlink -f $(dirname $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )))"

# Setup and mount all the repositories
source ${cvmfsHome}/bin/UserMount.sh
