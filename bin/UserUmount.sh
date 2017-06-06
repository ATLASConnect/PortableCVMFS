#!/bin/bash

# Make certain we got here via a source
if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
  echo "You must execute via \"source ${BASH_SOURCE[0]}\""
  exit
fi

# Find the root of the PortableCVMFS installation
export _CVMFS_ROOT="$(readlink -f $(dirname $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )))"

# Load up some usefull functions
source ${_CVMFS_ROOT}/bin/functions.sh


# Unmount all the repositories at the given MOUNT_DIR

if [[ -z "${_CVMFS_MOUNT_DIR}" ]]; then

  f_echo "PortableCVMFS not setup - \$_CVMFS_MOUNT_DIR not defined"

else 

  # Expand the path
  _CVMFS_MOUNT_DIR="$(readlink -f ${_CVMFS_MOUNT_DIR})"

  # Create a list of mounted repositories at the given mount directory
  _CVMFS_MOUNT_LIST=$(grep "^cvmfs2 ${_CVMFS_MOUNT_DIR}" /proc/mounts | cut -f2 -d' ')

  for _CVMFS_MOUNT_REPO in ${_CVMFS_MOUNT_LIST}; do
    f_echo "Umounting CVMFS repository at ${_CVMFS_MOUNT_REPO}"
    fusermount -u ${_CVMFS_MOUNT_REPO}
    [[ $? -eq 0 ]] && rmdir ${_CVMFS_MOUNT_REPO}
  done

  # Check if any repositories are still mounted
  _CVMFS_MOUNT_LIST=$(grep "^cvmfs2 ${_CVMFS_MOUNT_DIR}" /proc/mounts)

  if [[ $? -eq 0 ]]; then

    f_echo
    f_echo "Aborting PortableCVMFS cleanup because repositories remain mounted"
    f_echo
    f_echo "${_CVMFS_MOUNT_LIST}"
    f_echo

  else

    # Remove the temporary work area if we created one
    [[ -n "${_CVMFS_TEMP}" ]] && rm -rf ${_CVMFS_TEMP}

    # Remove all of our temp variables
    unset _CVMFS_NFILES
    unset _CVMFS_MOUNT_DIR
    unset _CVMFS_DEBUGLOG
    unset _CVMFS_RELOAD_SOCKETS
    unset _CVMFS_CACHE_BASE
    unset _CVMFS_SCRATCH
    unset _CVMFS_TEMP
    unset _CVMFS_TMP
    unset _CVMFS_ROOT

  fi

fi
