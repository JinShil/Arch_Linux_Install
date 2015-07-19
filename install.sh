# clear any partitions on the hard disk
set -x

INSTALL_DRIVE=/dev/sda
BOOT_DRIVE=${INSTALL_DRIVE}
PARTITION_EFI_BOOT=1
PARTITION_SWAP=2
PARTITION_ROOT=3
LABEL_BOOT_EFI=bootefi
LABEL_SWAP=swap
LABEL_ROOT=root
MOUNT_PATH=/mnt
EFI_SYSTEM_PARTITION=/boot/efi

# disk prep
sgdisk -Zog ${INSTALL_DRIVE} # zap all on disk
sgdisk -a 2048 -o ${INSTALL_DRIVE} # new gpt disk 2048 alignment

# create partitions
sgdisk -n ${PARTITION_EFI_BOOT}:0:+200M ${INSTALL_DRIVE} # (UEFI BOOT), default start block, 200MB
sgdisk -n ${PARTITION_SWAP}:0:+2G ${INSTALL_DRIVE} # (SWAP), default start block, 2GB
sgdisk -n ${PARTITION_ROOT}:0:0 ${INSTALL_DRIVE}   # (LUKS), default start, remaining space

# set partition types
sgdisk -t ${PARTITION_EFI_BOOT}:ef00 ${INSTALL_DRIVE}
sgdisk -t ${PARTITION_SWAP}:8200 ${INSTALL_DRIVE}
sgdisk -t ${PARTITION_ROOT}:8300 ${INSTALL_DRIVE}

# label partitions
sgdisk -c ${PARTITION_EFI_BOOT}:"${LABEL_BOOT_EFI}" ${INSTALL_DRIVE}
sgdisk -c ${PARTITION_SWAP}:"${LABEL_SWAP}" ${INSTALL_DRIVE}
sgdisk -c ${PARTITION_ROOT}:"${LABEL_ROOT}" ${INSTALL_DRIVE}

swapoff -a
sgdisk -p /dev/sda

# make filesystems
mkfs.vfat -F32 ${INSTALL_DRIVE}${PARTITION_EFI_BOOT}
mkswap ${INSTALL_DRIVE}${PARTITION_SWAP}
swapon ${INSTALL_DRIVE}${PARTITION_SWAP}
mkfs.ext4 ${INSTALL_DRIVE}${PARTITION_ROOT}
# mkswap /dev/sda2

# mount targetmou
mkdir -p ${MOUNT_PATH}
mount ${INSTALL_DRIVE}${PARTITION_ROOT} ${MOUNT_PATH}
mkdir -p ${MOUNT_PATH}${EFI_SYSTEM_PARTITION}
mount -t vfat ${INSTALL_DRIVE}${PARTITION_EFI_BOOT} ${MOUNT_PATH}${EFI_SYSTEM_PARTITION}

pacstrap /mnt base base-devel

genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

umount ${MOUNT_PATH}${EFI_SYSTEM_PARTITION};
arch-chroot /mnt /bin/bash -x <<EOF

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
export LANG=en_US.UTF-8

ls -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
hwclock --systohc --utc

echo ArchLinux > /etc/hostname

sed -i 's/127.0.0.1\tlocalhost.localdomain\tlocalhost/127.0.0.1\tlocalhost.localdomain\tlocalhost\tArchLinux/g' /etc/hosts
sed -i 's/::1\t\tlocalhost.localdomain\tlocalhost/::1\t\tlocalhost.localdomain\tlocalhost\tArchLinux/g' /etc/hosts

systemctl enable dhcpcd@enp0s3.service

pacman -S dosfstools

mount -t vfat ${INSTALL_DRIVE}${PARTITION_EFI_BOOT} ${MOUNT_PATH}${EFI_SYSTEM_PARTITION}
bootctl --path=${MOUNT_PATH}${EFI_SYSTEM_PARTITION} install

cat > ${MOUNT_PATH}${EFI_SYSTEM_PARTITION}/loader/entries/arch.conf <<ARCH_CONF_EOF
title          Arch Linux
linux          /vmlinuz-linux
initrd         /initramfs-linux.img
options        root=${INSTALL_DRIVE}${PARTITION_ROOT} rw
ARCH_CONF_EOF

cat > ${MOUNT_PATH}${EFI_SYSTEM_PARTITION}/loader/loader.conf <<LOADER_CONF_EOF
timeout 3
default arch
LOADER_CONF_EOF

exit

EOF

umount -R /mnt
