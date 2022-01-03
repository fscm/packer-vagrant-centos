#!/bin/bash
#
# Shell script to provision the CentOS box.
#
# Copyright 2020-2022, Frederico Martins
#   Author: Frederico Martins <http://github.com/fscm>
#
# SPDX-License-Identifier: MIT
#
# This program is free software. You can use it and/or modify it under the
# terms of the MIT License.
#

set -e

# ----- Clear history

echo "[INFO ] Disabling 'history'."

unset HISTFILE
history -cw


# ----- Check permissions

if [[ "$(id -u)" -ne 0 ]]; then
  echo >&2 "[ERROR] This script requires privileged access to system files"
  exit 99
fi


# ----- Configure dnf

echo "[INFO ] Configuring dnf."

for srv in dnf-makecache; do
    systemctl stop ${srv}.timer
    systemctl disable ${srv}.timer
    systemctl mask ${srv}.service
done

systemctl daemon-reload

sed -i -e '/best=True/a exclude=*.i?86\ntsflags=nodocs' /etc/dnf/dnf.conf

echo '%_install_langs en_US.UTF-8:C.utf8' > /etc/rpm/macros.image-language-conf


# ----- Retrieve new lists of packages

echo "[INFO ] Updating dnf packages lists."

dnf --quiet makecache


# ----- Install virtualization tools

if lspci | grep --quiet --ignore-case virtualbox; then
    echo "[INFO ] Installing tools for the VirtualBox hypervisor."
    rpm --query --all --queryformat='%{name}\n' | sort > /tmp/dependencies.pre
    dnf --quiet --assumeyes --setopt=install_weak_deps='no' install \
        epel-release \
        > /dev/null 2>&1
    dnf --quiet --assumeyes --setopt=install_weak_deps='no' install \
        bzip2 \
        dkms \
        gcc \
        kernel-headers \
        kernel-devel \
        make \
        > /dev/null 2>&1
    rpm --query --all --queryformat='%{name}\n' | sort > /tmp/dependencies.post
    mkdir -p /media/guest_additions_cd
    mount -r VBoxGuestAdditions.iso /media/guest_additions_cd
    /media/guest_additions_cd/VBoxLinuxAdditions.run --nox11 || true
    if ! modinfo vboxsf > /dev/null 2>&1; then
        echo >&2 "[ERROR] Virtualization tools installation failled."
        exit 10
    fi
    dnf remove --quiet --assumeyes \
        $(diff --changed-group-format='%>' --unchanged-group-format='' /tmp/dependencies.pre /tmp/dependencies.post | xargs) \
        > /dev/null 2>&1
    umount /media/guest_additions_cd
    rm -rf /media/guest_additions_cd
    #rm -rf /etc/kernel/prerm.d/*
    rm -rf /tmp/dependencies.*
elif lspci | grep --quiet --ignore-case vmware; then
    echo "[INFO ] Installing tools for the VMWare hypervisor."
    dnf --quiet --assumeyes --setopt=install_weak_deps='no' install open-vm-tools > /dev/null 2>&1
    systemctl enable vgauthd.service
    systemctl enable vmtoolsd.service
else
    echo "[INFO ] UNKNOWN hypervisor, no tools will be installed."
fi


# ----- Configure sshd

echo "[INFO ] Configuring sshd."

sed -i \
    -e '/UseDNS /s/.*\(UseDNS\) .*/\1 no/' \
    -e '/GSSAPIAuthentication /s/.*\(GSSAPIAuthentication\) .*/\1 no/' \
    /etc/ssh/sshd_config

curl --silent --location https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub --output /tmp/authorized_keys
for usr in /home/*; do
    username="${usr##*/}"
    install --directory --owner="${username}" --group="${username}" --mode=0700 /home/"${username}"/.ssh
    install --owner="${username}" --group="${username}" --mode=0600 --target-directory=/home/"${username}"/.ssh /tmp/authorized_keys
done
rm -rf /tmp/authorized_keys


# ----- Configure base system

echo "[INFO ] Configuring base system."

#install -d --owner 0 --group 0 --mode 1777 /vagrant
echo 'export TZ=:/etc/localtime' > /etc/profile.d/tz.sh
echo 'export SYSTEMD_PAGER=' > /etc/profile.d/systemd.sh
sed -i \
    -e '/^GRUB_TIMEOUT=/s/=.*/=1/' \
    -e 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 cgroup_enable=memory"/' \
    /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
#update-alternatives --set editor /usr/bin/vim.tiny


# ----- System cleanup

echo "[INFO ] Cleaning up the system."

dnf --quiet clean all

#rm -rf /tmp/{..?*,.[!.]*,*}
rm -rf /usr/share/info/*
rm -rf /usr/share/man/*
rm -rf /var/cache/dnf/*
rm -rf /var/lib/dnf/history.*
rm -rf /var/log/*
rm -rf /var/tmp/{..?*,.[!.]*,*}

find /home /root -type f -not \( -name '.bashrc' -o -name '.bash_logout' -o -name '.bash_profile' -o -name 'authorized_keys' \) -delete
find /usr/share/locale -mindepth 1 -maxdepth 1 -type d -not \( -name 'en' -o -name 'en_US' \) -exec rm -r {} ';'
find /usr/share/doc -mindepth 1 -not -type d -not \( -name 'COPYING*' -o -name 'GPL' -o -name '*LICENSE*' \) -delete
find /usr/share/doc -mindepth 1 -type d -empty -delete
find /var/cache -type f -delete


# ----- Fileystem cleanup

echo "[INFO ] Cleaning up the filesystem."

sed -i -e '/ext4/s|UUID=[^ ]* |LABEL=/ |' /etc/fstab
sed -i -e '/swap/s|UUID=[^ ]* |LABEL=SWAP |' /etc/fstab

swap_part="$(swapon --show=NAME --noheadings --raw)"
swapoff "${swap_part}"
dd if=/dev/zero of="${swap_part}" > /dev/null 2>&1 || echo 'dd exit code suppressed'
mkswap -L SWAP "${swap_part}"
swapon "${swap_part}"

dd if=/dev/zero of=/EMPTY bs=1M > /dev/null 2>&1 || echo 'dd exit code suppressed'
rm -f /EMPTY

sync


# ----- System info

echo "[INFO ] System info:"

echo '--------------------------------------------------'
cat /etc/centos-release
du -sh / --exclude=/proc
echo '--------------------------------------------------'


echo "[INFO ] Provisioning finished."
exit 0
