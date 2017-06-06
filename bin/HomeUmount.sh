#!/bin/bash

# Make certain we got here via a source
if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
  echo "You must execute via \"source ${BASH_SOURCE[0]}\""
  exit
fi

# Find out where we live
cvmfsHome="$(readlink -f $(dirname $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )))"

# Umount all the repositories
source ${cvmfsHome}/bin/UserUmount.sh

# Do some cleanup of our environment
unset CVMFS_MOUNT
unset CVMFS_TMP
