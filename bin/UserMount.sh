#!/bin/bash


# Mount a given CVMFS repostories with the given configuration options
#
# Requires $_CVMFS_ROOT
#          $_CVMFS_MOUNT_DIR
#


function f_mount () {

  _CVMFS_REPO="${1}"
  _CVMFS_CONF="${2}"

  # Make certain the mount point exists
  mkdir -p ${_CVMFS_MOUNT_DIR}/${_CVMFS_REPO}

  # Are we in debug mode
  if [[ -n "${CVMFS_DEBUG}" ]]; then
    _CVMFS_DEBUG="-d"
    echo
    echo "$_CVMFS_REPO : $_CVMFS_CONF"
    echo
  else
    _CVMFS_DEBUG=""
  fi

  # Mount the repository with the given configuration options at the given mount point
  ${_CVMFS_ROOT}/bin/cvmfs2 ${_CVMFS_DEBUG} -o rw,fsname=cvmfs2,config=${_CVMFS_CONF} ${_CVMFS_REPO} ${_CVMFS_MOUNT_DIR}/${_CVMFS_REPO} > /dev/null 2>&1
# ${_CVMFS_ROOT}/bin/cvmfs2 ${_CVMFS_DEBUG} -o rw,fsname=cvmfs2,config=${_CVMFS_CONF} ${_CVMFS_REPO} ${_CVMFS_MOUNT_DIR}/${_CVMFS_REPO}

  _CVMFS_STATUS=$?

  if [[ ${_CVMFS_STATUS} -eq 0 ]]; then
    f_echo "Mounting repository ${_CVMFS_MOUNT_DIR}/${_CVMFS_REPO}"
  else
    f_echo "Failed to mount repository ${_CVMFS_MOUNT_DIR}/${_CVMFS_REPO} with error ${_CVMFS_STATUS}"
  fi

  return ${_CVMFS_STATUS}

}

# Make certain we got here via a source
if [[ "${0}" == "${BASH_SOURCE[0]}" ]]; then
  echo "You must execute via \"source ${BASH_SOURCE[0]}\""
  exit
fi

# Find out where we live
export _CVMFS_ROOT="$(readlink -f $(dirname $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )))"

# Load up some usefull functions
source ${_CVMFS_ROOT}/bin/functions.sh

# Add in the library to the path
f_addldlibrarypath "${_CVMFS_ROOT}/lib64"


# Use the defined TMP area, otherwise use /tmp
if [[ -n "${CVMFS_TMP}" ]]; then
  export _CVMFS_TMP="${CVMFS_TMP}"
else
  export _CVMFS_TMP="/tmp"
fi

# Expand the path
export _CVMFS_TMP="$(readlink -f ${_CVMFS_TMP})"


# Use the defined SCRATCH area, otherwise create one in _CVMFS_TMP
if [[ -n "${CVMFS_SCRATCH}" ]]; then
  export _CVMFS_SCRATCH="${CVMFS_SCRATCH}"
else
  export _CVMFS_TEMP="$(mktemp -d -p ${_CVMFS_TMP} cvmfs.XXX)"
  export _CVMFS_SCRATCH="${_CVMFS_TEMP}"
fi

# Expand the path
export _CVMFS_SCRATCH="$(readlink -f ${_CVMFS_SCRATCH})"

# Make certain the Scratch exists
mkdir -p ${_CVMFS_SCRATCH}


# Use the defined CACHE area, otherwise create one
if [[ -n "${CVMFS_CACHE}" ]]; then
  export _CVMFS_CACHE_BASE="${CVMFS_CACHE}"
else
  export _CVMFS_CACHE_BASE="${_CVMFS_SCRATCH}/cache"
fi

# Expand the path
export _CVMFS_CACHE_BASE="$(readlink -f ${_CVMFS_CACHE_BASE})"

# Make certain the Cache exists
mkdir -p ${_CVMFS_CACHE_BASE}


# Use the defined SOCKETS area, otherwise create one
if [[ -n "${CVMFS_SOCKETS}" ]]; then
  export _CVMFS_RELOAD_SOCKETS="${CVMFS_SOCKETS}"
else
  export _CVMFS_RELOAD_SOCKETS="${_CVMFS_SCRATCH}/sockets"
fi

# Expand the path
export _CVMFS_RELOAD_SOCKETS="$(readlink -f ${_CVMFS_RELOAD_SOCKETS})"

# Make certain the Sockets exists
mkdir -p ${_CVMFS_RELOAD_SOCKETS}


# Use the defined CVMFS Quota Limit or a default
if [[ -n "${CVMFS_QUOTA}" ]]; then
  export _CVMFS_QUOTA_LIMIT="${CVMFS_QUOTA}"
else
  export _CVMFS_QUOTA_LIMIT="25600"
fi


# Use the defined CVMFS Proxies or a default
if [[ -n "${CVMFS_PROXY}" ]]; then
  export _CVMFS_HTTP_PROXY="${CVMFS_PROXY}"
else
  export _CVMFS_HTTP_PROXY="http://uct2-squid.mwt2.org:3128;http://iut2-squid.mwt2.org:3128;http://mwt2-squid.campuscluster.illinois.edu:3128;DIRECT"
fi


# CVMFS debug
export _CVMFS_DEBUGLOG="${_CVMFS_SCRATCH}/debug.log"


# Use the defined MOUNT options
if [[ -n "${CVMFS_MOUNT_OPT}"  ]]; then
 export _CVMFS_MOUNT_OPT="${CVMFS_MOUNT_OPT}"
else
 export _CVMFS_MOUNT_OPT=''
fi


# Use the defined MOUNT area, otherwise create one
if [[ -n "${CVMFS_MOUNT}"  ]]; then
 export _CVMFS_MOUNT_DIR="${CVMFS_MOUNT}"
else
 export _CVMFS_MOUNT_DIR="${_CVMFS_SCRATCH}/cvmfs"
fi

# Expand the path
export _CVMFS_MOUNT_DIR="$(readlink -f ${_CVMFS_MOUNT_DIR})"


f_echo
f_echo "Maximizing ulimits for CVMFS mounts"

# Boost the limits to the maximum allowed
f_ulimit -t  hard  unlimited
f_ulimit -d  hard  unlimited
f_ulimit -f  hard  unlimited
f_ulimit -l  hard  unlimited
f_ulimit -n  hard  unlimited
f_ulimit -s  hard  unlimited
f_ulimit -m  hard  unlimited
f_ulimit -u  hard  unlimited
f_ulimit -v  hard  unlimited
f_ulimit -x  hard  unlimited

f_echo
f_echo "Executing command: ulimit -S -a"
f_echo

ulimit -S -a

f_echo


# Only use the number of file the system administrator gives us
export _CVMFS_NFILES=$(ulimit -n)
[[ ${_CVMFS_NFILES} -gt 65536 ]] && export _CVMFS_NFILES=65536

f_echo "CVMFS_MOUNT_DIR   = ${_CVMFS_MOUNT_DIR}"
f_echo "CVMFS_SCRATCH     = ${_CVMFS_SCRATCH}"
f_echo "CVMFS_QUOTA_LIMIT = ${_CVMFS_QUOTA_LIMIT}"
f_echo "CVMFS_HTTP_PROXY  = ${_CVMFS_HTTP_PROXY}"
f_echo "CVMFS_NFILES      = ${_CVMFS_NFILES}"
[[ -n "${CVMFS_DEBUG}" ]] && f_echo "CVMFS_DEBUGLOG    = ${_CVMFS_DEBUGLOG}"
f_echo


# Where all the configuration files are located
_CVMFS_LOCAL_CONFIG_DIR=${_CVMFS_ROOT}/etc/cvmfs

# Repository and Domain Configuration files locations
_CVMFS_LOCAL_DEFAULT_D=${_CVMFS_LOCAL_CONFIG_DIR}/default.d
_CVMFS_LOCAL_CONFIG_D=${_CVMFS_LOCAL_CONFIG_DIR}/config.d
_CVMFS_LOCAL_DOMAIN_D=${_CVMFS_LOCAL_CONFIG_DIR}/domain.d


# Where all the configuration files are located in the configuration repository
_CVMFS_REPO_CONFIG_DIR=${_CVMFS_MOUNT_DIR}/config-osg.opensciencegrid.org/etc/cvmfs

# Repository and Domain Configuration files locations on configuration repository
_CVMFS_REPO_DEFAULT_D=${_CVMFS_REPO_CONFIG_DIR}/default.d
_CVMFS_REPO_CONFIG_D=${_CVMFS_REPO_CONFIG_DIR}/config.d
_CVMFS_REPO_DOMAIN_D=${_CVMFS_REPO_CONFIG_DIR}/domain.d


# Default configuration for all repositories
_CVMFS_LOCAL_CONFIG_DEFAULT=${_CVMFS_LOCAL_CONFIG_DIR}/default.base:${_CVMFS_LOCAL_CONFIG_DIR}/default.conf:${_CVMFS_LOCAL_DEFAULT_D}/60-osg.conf:${_CVMFS_LOCAL_CONFIG_DIR}/default.local

# Default configuration for all repositories
_CVMFS_REPO_CONFIG_DEFAULT=${_CVMFS_LOCAL_CONFIG_DEFAULT}:${_CVMFS_REPO_CONFIG_DIR}/default.conf


# The default configuration for all CERN repositories
_CVMFS_REPO_CONFIG_DEFAULT_cern_ch=${_CVMFS_REPO_CONFIG_DEFAULT}:${_CVMFS_REPO_DOMAIN_D}/cern.ch.conf:${_CVMFS_LOCAL_DOMAIN_D}/cern.ch.local



# Mount the configuration repository
f_mount config-osg.opensciencegrid.org "${_CVMFS_LOCAL_CONFIG_DEFAULT}:${_CVMFS_LOCAL_CONFIG_D}/config-osg.opensciencegrid.org.conf:${_CVMFS_LOCAL_DOMAIN_D}/opensciencegrid.org.local"

# Mount the CERN repositories
f_mount atlas.cern.ch                  "${_CVMFS_REPO_CONFIG_DEFAULT_cern_ch}"
f_mount atlas-condb.cern.ch            "${_CVMFS_REPO_CONFIG_DEFAULT_cern_ch}"
f_mount atlas-nightlies.cern.ch        "${_CVMFS_REPO_CONFIG_DEFAULT_cern_ch}:${_CVMFS_REPO_CONFIG_DIR}/atlas-nightlies.cern.ch.conf"
f_mount cernvm-prod.cern.ch            "${_CVMFS_REPO_CONFIG_DEFAULT_cern_ch}"
f_mount cms.cern.ch                    "${_CVMFS_REPO_CONFIG_DEFAULT_cern_ch}:${_CVMFS_REPO_CONFIG_DIR}/cms.cern.ch.conf"
f_mount geant4.cern.ch                 "${_CVMFS_REPO_CONFIG_DEFAULT_cern_ch}"
f_mount grid.cern.ch                   "${_CVMFS_REPO_CONFIG_DEFAULT_cern_ch}:${_CVMFS_REPO_CONFIG_DIR}/grid.cern.ch.conf"
f_mount sft.cern.ch                    "${_CVMFS_REPO_CONFIG_DEFAULT_cern_ch}"

f_mount alice.cern.ch                  "${_CVMFS_REPO_CONFIG_DEFAULT_cern_ch}"
f_mount alice-ocdb.cern.ch             "${_CVMFS_REPO_CONFIG_DEFAULT_cern_ch}"
f_mount boss.cern.ch                   "${_CVMFS_REPO_CONFIG_DEFAULT_cern_ch}"
f_mount lhcb.cern.ch                   "${_CVMFS_REPO_CONFIG_DEFAULT_cern_ch}"
f_mount na61.cern.ch                   "${_CVMFS_REPO_CONFIG_DEFAULT_cern_ch}"


# Mount the oasis.opensciencegrid.org repository
f_mount oasis.opensciencegrid.org      "${_CVMFS_REPO_CONFIG_DEFAULT}:${_CVMFS_REPO_CONFIG_D}/oasis.opensciencegrid.org.conf:${_CVMFS_LOCAL_DOMAIN_D}/opensciencegrid.org.local"
f_mount fermilab.opensciencegrid.org   "${_CVMFS_REPO_CONFIG_DEFAULT}:${_CVMFS_LOCAL_DOMAIN_D}/opensciencegrid.org.local"
f_mount icecube.opensciencegrid.org    "${_CVMFS_REPO_CONFIG_DEFAULT}:${_CVMFS_LOCAL_DOMAIN_D}/opensciencegrid.org.local"
f_mount minos.opensciencegrid.org      "${_CVMFS_REPO_CONFIG_DEFAULT}:${_CVMFS_LOCAL_DOMAIN_D}/opensciencegrid.org.local"
f_mount nova.opensciencegrid.org       "${_CVMFS_REPO_CONFIG_DEFAULT}:${_CVMFS_LOCAL_DOMAIN_D}/opensciencegrid.org.local"
f_mount spt.opensciencegrid.org        "${_CVMFS_REPO_CONFIG_DEFAULT}:${_CVMFS_LOCAL_DOMAIN_D}/opensciencegrid.org.local"
f_mount xenon.opensciencegrid.org      "${_CVMFS_REPO_CONFIG_DEFAULT}:${_CVMFS_LOCAL_DOMAIN_D}/opensciencegrid.org.local"

# Mount the osg.mwt2.org repository
f_mount osg.mwt2.org                   "${_CVMFS_LOCAL_CONFIG_DEFAULT}:${_CVMFS_LOCAL_CONFIG_D}/osg.mwt2.org.conf"
