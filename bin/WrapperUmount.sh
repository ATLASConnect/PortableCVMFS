#!/bin/bash

# Make certain we got here via a source
#if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
#  echo "You must execute via \"source ${BASH_SOURCE[0]}\""
#  exit
#fi

# Find the root of the PortableCVMFS installation
_CVMFS_ROOT="$(readlink -f $(dirname $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )))"

# Load up some usefull functions
source ${_CVMFS_ROOT}/bin/functions.sh


# Root of all the CVMFS mount points

if [[ -n "${1}" ]]; then
  _CVMFS_MOUNT_DIR=${1}
else
  _CVMFS_MOUNT_DIR=/cvmfs
fi

# Expand the path
_CVMFS_MOUNT_DIR="$(readlink -f ${_CVMFS_MOUNT_DIR})"


# Location of the cache, sockets, etc to be removed
# If none is specified, the cache will remain
if [[ -n "${2}" ]]; then
  _CVMFS_SCRATCH="$(readlink -f ${2})"
else
  _CVMFS_SCRATCH=''
fi

# Create a list of mounted repositories at the given mount directory
_CVMFS_MOUNT_LIST=$(grep "^cvmfs2.$(whoami) ${_CVMFS_MOUNT_DIR}" /proc/mounts | cut -f2 -d' ')

for _CVMFS_MOUNT_REPO in ${_CVMFS_MOUNT_LIST}; do
  f_echo "Umounting CVMFS repository at ${_CVMFS_MOUNT_REPO}"
  fusermount -u -z ${_CVMFS_MOUNT_REPO}
  [[ $? -eq 0 ]] && rmdir ${_CVMFS_MOUNT_REPO}
done


# Check if any repositories are still mounted
_CVMFS_MOUNT_LIST=$(grep "^cvmfs2.$(whoami) ${_CVMFS_MOUNT_DIR}" /proc/mounts)

if [[ $? -eq 0 ]]; then

  f_echo
  f_echo "Aborting PortableCVMFS cleanup because repositories remain mounted"
  f_echo
  f_echo "${_CVMFS_MOUNT_LIST}"
  f_echo 

else

  # Remove the CVMFS cache from the local disk if requested
  if [[ -n "${_CVMFS_SCRATCH}" ]]; then
    f_echo "Removing CVMFS cache at ${_CVMFS_SCRATCH}/cvmfs2.$(whoami)"
    rm -rf ${_CVMFS_SCRATCH}/cvmfs2.$(whoami)
  fi

fi
