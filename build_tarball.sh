#!/bin/sh

# The CVMFS we are to use
cvmfsVerOSG="3.3"
cvmfsVerRPM="2.3.5"
cvmfsVerCNF="2.0-1"

# Override the default it given
[[ ! -z $1 ]] && cvmfsVerRPM=$1
[[ ! -z $2 ]] && cvmfsVerCNF=$2

cvmfsOSG=osg${cvmfsVerOSG//.}
cvmfsRPM=cvmfs-${cvmfsVerRPM}-1.${cvmfsOSG}.el6.x86_64.rpm
cvmfsCNF=cvmfs-config-osg-${cvmfsVerCNF}.${cvmfsOSG}.el6.noarch.rpm


# Where all our needed files should live
buildHome="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Tarball download location
buildDownload=/home/www/download

# Tarball we will build
buildTarball=PortableCVMFS-${cvmfsVerRPM}.tar.gz


echo "Building PortableCVMFS tarball at ${buildDownload}/PortableCVMFS/${buildTarball}"


# Create a temporary working area
tmpHome=$(mktemp -d)

# Stop now if we dont have a workspace
[[ -z ${tmpHome} ]] && exit 255


# Transfer to the working location
pushd ${tmpHome} > /dev/null

wget --quiet --no-check-certificate http://repo.grid.iu.edu/osg/${cvmfsVerOSG}/el6/release/x86_64/${cvmfsRPM}
rpm2cpio ${cvmfsRPM} | cpio -imdv 2>/dev/null
rm -f ${cvmfsRPM}

wget --quiet --no-check-certificate http://repo.grid.iu.edu/osg/${cvmfsVerOSG}/el6/release/x86_64/${cvmfsCNF}
rpm2cpio ${cvmfsCNF} | cpio -imdv 2>/dev/null
rm -f ${cvmfsCNF}


# Where we will build the portable CVMFS
cvmfsHome=${tmpHome}/PortableCVMFS

# Create the CVMFS tree we will now populate
mkdir -p ${cvmfsHome}/etc/cvmfs
mkdir -p ${cvmfsHome}/bin

# Move over the CVMFS loader and libraries
mv ${tmpHome}/usr/bin/cvmfs2                         ${cvmfsHome}/bin
mv ${tmpHome}/usr/lib64                              ${cvmfsHome}

# Move over all the configuration files and keys
mv ${tmpHome}/etc/cvmfs                              ${cvmfsHome}/etc

# Add in our local scripts
cp -pr ${buildHome}/bin                              ${cvmfsHome}

# Add in our local configuration files
cp ${buildHome}/conf/default.base                    ${cvmfsHome}/etc/cvmfs/default.base
cp ${buildHome}/conf/default.local                   ${cvmfsHome}/etc/cvmfs/default.local
cp ${buildHome}/conf/osg.mwt2.org.pub                ${cvmfsHome}/etc/cvmfs/keys/osg.mwt2.org.pub
cp ${buildHome}/conf/osg.mwt2.org.conf               ${cvmfsHome}/etc/cvmfs/config.d/osg.mwt2.org.conf
cp ${buildHome}/conf/cern.ch.local                   ${cvmfsHome}/etc/cvmfs/domain.d/cern.ch.local
cp ${buildHome}/conf/opensciencegrid.org.local       ${cvmfsHome}/etc/cvmfs/domain.d/opensciencegrid.org.local

cp ${buildHome}/README.md                            ${cvmfsHome}/README.md

# Build our pCVMFS tarball
tar czf ${buildTarball}                              PortableCVMFS

# Put a copy in a place others can wget
mkdir -p ${buildDownload}/PortableCVMFS
rm -f ${buildDownload}/PortableCVMFS/${buildTarball}
cp ${buildTarball}                                   ${buildDownload}/PortableCVMFS/${buildTarball}

# Make it current
rm -f ${buildDownload}/PortableCVMFS.tar.gz
ln -s PortableCVMFS/${buildTarball} ${buildDownload}/PortableCVMFS.tar.gz

popd >/dev/null

# Cleanup our workspace
rm -rf ${tmpHome}
