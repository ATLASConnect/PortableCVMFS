PortableCVMFS
=============

Allows a user to mount CVMFS repositories on a node using only fuse


The node must have the following addtions (see bin/fuse.sh)

	1) fuse rpm installed
	2) Fuse module loaded into the kernel (modprobe fuse)
	3) Optional: Allow others to access this mounted repository (addtion to /etc/fuse.conf)
        4) User in "fuse" group or /bin/fusermount has o+rx permissions



### Build a relocatable PortableCVMFS tarball ###

To use this product, you must first buiild a local copy of PortableCVMFS using "build_tarball.sh"

	sh build_tarball.sh


This will 

	1) Download CVMFS 2.3.5 and configuration script 2.0-1
	2) Unpack them into a temporary working directory
	3) Install the configuration and keys files for the MWT2 and Oasis repositories
	4) Setup a "default.local" to enable these repositories and squids

A tarball is then built starting with a relocatable root of "PortableCVMFS"

By default the tarball is moved to /home/www/download/PortableCVMFS. Edit the script to change this location.




### How to Use PortableCVMFS ###

To use PortableCVMFS, you must first unpack the tarball into the target location

	cd /usr/local
	tar xzf PortableCVMFS-2.3.5.tar.gz


There are several scripts located in PortableCVMFS/bin which will mount/umount the repositories

	1) UserMount.sh,    UserUmount.sh
	2) HomeMount.sh,    HomeUmount.sh
	3) RootMount.sh,    RootUmount.sh
	4) WrapperMount.sh, WrapperUmount.sh


The UserMount/UserUmount scripts will mount/umount all the repositories at a given location.
By default a temporary dirctory will be created in /tmp using "mktemp".
All CVMFS repository mount points and the CVMFS cache will be placed in this location.


To modify the scripts behavior, one can define several environment variables

	CVMFS_TMP	Root of temporary workspace			default /tmp
	CVMFS_SCRATCH	Temporary workspace (cache, sockets, mount)	default ${CVMFS_TMP}/$(mktemp)
	CVMFS_MOUNT	Location of CVMFS repository mount points	default ${CVMFS_SCRATCH}/cvmfs
	CVMFS_CACHE	Location of CVMFS cache				default ${CVMFS_SCRATCH}/cache
	CVMFS_SOCKETS	Location of CVMFS sockets			default ${CVMFS_SCRATCH}/sockets
	CVMFS_QUOTA	CVMFS Cache Quota Limit				default 25GB
	CVMFS_PROXY	HTTP Proxy					default "http://uct2-squid.mwt2.org:3128;http://mwt2-squid.campuscluster.illinois.edu:3128;http://iut2-squid.mwt2.org:3128"
	CVMFS_DEBUG	Turn on debugging				default No debug output


To mount the repositories, you first define any optional variables, then 

	source UserMount.sh

Please note that you must "source" the script otherwise required internal variables 
for the UserUmount.sh script will not be available


For example (from HomeMount.sh):

	export CVMFS_MOUNT=$HOME/cvmfs
	export CVMFS_TMP=/scratch.local/tmp
	source bin/UserMount.sh

This will put all mount points within "$HOME/cvmfs" with the cache and sockets stored on "/scratch.local/tmp"


To Unmount all the repositories

	source bin/UserUmount.sh


This will umount all the repositories, remove the temporary workspaces (cache, sockets) 
and unset all internal varaiables (those with a _CVMFS prefix)




### Example Scripts ###


The scripts HomeMount/HomeUmount.sh are provided as examples for how a user may use PortableCVMFS



The scripts RootMount/RootUmount.sh will mount all repositories at the default "/cvmfs"
with the cache located at "/tmp/cvmfs2.$(whoami)". These scripts can be used to installed CVMFS
system wide for all users without having to install the CVMFS RPMs. Fuse must still be installed.


The scripts WrapperMount/WrapperUmount.sh are intended to be called from the Connect SSH Glidein.

	./WrapperMount.sh  "MountRoot" "Scratch" "Quota" "HTTP_Proxy"
	./WrapperUmount.sh "MountRoot" "Scratch"

"MountRoot" (default "/cvmfs") is Root of all mount points.

"Scratch" (default "/tmp") is the root of the scratch area.
It will contain the "cache" and "sockets" directories


"Quota" (default 25600) is the Cache Quota Limit in MB

"Proxy" (default is MWT2 proxy list) is the CVMFS HTTP Proxy list



If WrapperUmount is invoked without specifying a "Scratch",
the area will remain on disk. If specified, the area will be removed

