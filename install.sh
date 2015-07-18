# clear any partitions on the hard disk
sgdisk -Z /dev/sda
sgdisk -a 2048 -o /dev/sda
sgdisk -n 0 /dev/sda
sgdisk -t 0:8300 /dev/sda

mkfs.ext4 /dev/sda1

mount /dev/sda1 /mnt

pacstrap /mnt base base-devel

genfstab -U -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
export LANG=en_US.UTF-8

ls -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
hwclock --systohc --utc

echo ArchLinux > /etc/hostname

sed -i 's/127.0.0.1\tlocalhost.localdomain\tlocalhost/127.0.0.1\tlocalhost.localdomain\tlocalhost\tArchLinux/g' /etc/hosts
sed -i 's/::1\t\tlocalhost.localdomain\tlocalhost/::1\t\tlocalhost.localdomain\tlocalhost\tArchLinux/g' /etc/hosts

# systemctl enable dhcpcd@enp0s3.service

# set root password

pacman -S --noconfirm grub-bios

grub-install /dev/sda

mkinitcpio -p linux

grub-mkconfig -o /boot/grub/grub.cfg

exit

umount /mnt
