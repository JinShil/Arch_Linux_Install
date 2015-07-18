# clear any partitions on the hard disk
sgdisk -Z /dev/sda
sgdisk -a 2048 -o /dev/sda
sgdisk -n 0 /dev/sda
sgdisk -t 0:8300 /dev/sda

mkfs.ext4 /dev/sda1

mount /dev/sda1 /mnt

pacstrap -i /mnt base base-devel

genfstab -U -p /mnt >> /mnt/etc/fstab