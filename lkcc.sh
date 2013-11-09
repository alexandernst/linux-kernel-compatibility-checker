#!/bin/bash

BASE_URL='ftp://ftp.kernel.org/pub/linux/kernel/v3.x/'
REPORTS_DIR='./reports/'
DUMPS_DIR='./dumps/'
TEMP_DIR='./temp/'
KERNEL_EXTENSION='.tar.xz'
DUMP_EXTENSION='.dump'

ABI_COMPLIANCE_CHECKER='/home/alexandernst/Proyectos/abi-compliance-checker/abi-compliance-checker.pl'
ABI_DUMPER='/home/alexandernst/Proyectos/abi-dumper/abi-dumper.pl'

#Get list of kernels
get_kernels() {
	#Download the list of available kernels, without any output
	wget --quiet --no-remove-listing $BASE_URL
	#Delete file
	rm index.html
	#Get all the lines from .listing
	#Filter the ones that contain "patch"
	#Filter the ones that don't contain ".xz"
	#Replace one or more 'whitespace' with a single space
	#Leave only the 9th column
	local kernels=`cat .listing | grep -v "patch" | grep ".xz" | sed -e 's/\s\+/ /g' | cut -d ' ' -f 9`
	#Delete file
	rm .listing
	#Replace 'whitespace' with 'new line'
	#Then natural-sort lines
	#Then replace 'new line' with 'space'
	#Then invert all the lines (the last one becomes the first one, the last-1 becomes the second one, etc...)
	local kernels=`echo $kernels | sed -e 's/\s/\n/g' | sort -V | sed -e 's/\n/ /g' | tac`
	#Return
	echo "$kernels"
}

#Download kernel
download_kernel() {
	wget --quiet --output-document="$TEMP_DIR$1$KERNEL_EXTENSION" "$BASE_URL$1$KERNEL_EXTENSION"
	echo "OK"
}

#Extract kernel
extract_kernel() {
	tar -xJf "$TEMP_DIR$1$KERNEL_EXTENSION" -C "$TEMP_DIR"
	echo "OK"
}

#Compile the kernel
compile_kernel() {
	local kdir="$TEMP_DIR$1"
	#Create a custom .config file
	make -C "$kdir" O="`pwd`/$kdir" KCONFIG_CONFIG=custom.config defconfig
	#Enable CONFIG_DEBUG_INFO
	echo "CONFIG_DEBUG_INFO=y" >> "$kdir/custom.config"
	#Make the kernel say "No" to anything that doesn't have a default setting yet
	make -C "$kdir" O="`pwd`/$kdir" KCONFIG_ALLCONFIG=custom.config allnoconfig
	ncpu=`cat /proc/cpuinfo | grep processor | wc -l`
	#Build
	make -C "$kdir" -j`expr $ncpu + 1`
	echo "OK"
}

#Generate a dump
generate_dump() {
	local kdir="$TEMP_DIR$1"
	local version=`echo $1 | sed -e 's/linux-//g'`
	"$ABI_DUMPER" "$kdir/vmlinux" -o "$kdir/vmlinux$DUMP_EXTENSION" -lver "$version"
}

#Clean
clean_temp() {
	local kdir="$TEMP_DIR$1"
	mv "$kdir/vmlinux$DUMP_EXTENSION" "$DUMPS_DIR$1_`uname -m`$DUMP_EXTENSION"
	rm -rf "$TEMP_DIR$1" "$TEMP_DIR$1$KERNEL_EXTENSION"
}

#Generate a reports
generate_reports() {
	#abi-compliance-checker -l vmlinux -old ABI-X.dump -new ABI-Y.dump -affected-limit 10
	echo TODO Logic for generating a report
}

### Main ###

kernels=$(get_kernels)

mapfile -t kernels <<< "`echo $kernels | sed -e 's/\s/\n/g'`"
for kernel in "${kernels[@]}"
do
	kernel_version=`echo $kernel | sed -e 's/.tar.xz//g'`

	#Check if a kernel version has a dump file
	if [ ! -f "$DUMPS_DIR${kernel_version}_`uname -m`$DUMP_EXTENSION" ]
	then
		echo "$kernel_version doesn't seem to have a dump!"

		echo "Downloading $kernel_version ..."
		ret=$(download_kernel "$kernel_version")

		echo "Extracting $kernel_version ..."
		ret=$(extract_kernel "$kernel_version")

		echo "Compiling $kernel_version ..."
		ret=$(compile_kernel "$kernel_version")

		echo "Generating dump for $kernel_version ..."
		ret=$(generate_dump "$kernel_version")

		echo "Cleaning temp ..."
		ret=$(clean_temp "$kernel_version")

		echo "Generating reports for $kernel_version ..."
		ret=$(generate_reports "$kernel_version")
	fi
done