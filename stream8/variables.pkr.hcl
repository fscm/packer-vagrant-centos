# CentOS Vagrant box - Variables
#
# copyright: 2020-2021, Frederico Martins
# author: Frederico Martins <http://github.com/fscm>
# license: SPDX-License-Identifier: MIT

# variables

variables {
    disk_size_mb          = 8192
    debug                 = false
    domain                = "vagrant.local"
    hostname              = "centos"
    os_version            = "8"
    password              = "stream"
    username              = "stream"
    _boot_wait_sec        = 10
    _os_arch              = "x86_64"
    _os_codename          = "centos-stream"
    _os_type_vbox         = "RedHat_64"
    _os_type_vmware       = "centos8_64Guest"
    _ssh_port             = 22
    _ssh_wait_timeout_sec = 3600
    _system_memory_mb     = 1024
    _timezone             = "Etc/UTC"
}

# locals

locals {
    _boot_command     = [
        "<tab>",
        " inst.text",
        " inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/kickstart.cfg",
        " inst.kdump_addon=off",
        " inst.nosave=all",
        " inst.selinux=0",
        " selinux=0", # https://forums.rockylinux.org/t/setting-of-root-password-value-fails-during-kickstart/3173
        "<enter>"
    ]
    _headless         = "${!var.debug}"
    _iso_checksum     = "file:http://centos.mirror.ptisp.pt/centos/${var.os_version}-stream/isos/${var._os_arch}/CHECKSUM"
    _iso_target_path  = "${abspath(path.root)}/../builds/cache/CentOS-Stream-${var.os_version}-${var._os_arch}-latest-boot.iso"
    _iso_urls         = [
        "${abspath(path.root)}/../builds/isos/CentOS-Stream-${var.os_version}-${var._os_arch}-latest-boot.iso",
        "http://centos.mirror.ptisp.pt/centos/${var.os_version}-stream/isos/${var._os_arch}/CentOS-Stream-${var.os_version}-${var._os_arch}-latest-boot.iso"
    ]
    _output           = "${abspath(path.root)}/../builds/providers/{{.Provider}}/${var._os_codename}${var.os_version}-${var._os_arch}.box"
    _output_directory = "${abspath(path.root)}/../builds/sandbox"
    #_kickstart_file   = "${abspath(path.root)}/kickstart.cfg"
    _kickstart_tpl    = "${abspath(path.root)}/kickstart.cfg.pkrtpl.hcl"
    _provisioner_file = "${abspath(path.root)}/provisioner.sh"
    _vagrantfile      = "${abspath(path.root)}/../builds/cache/${var._os_codename}${var.os_version}-Vagrantfile"
    _vagrantfile_tpl  = "${abspath(path.root)}/Vagrantfile.pkrtpl.hcl"
    _vm_name          = "${var._os_codename}${var.os_version}-${var._os_arch}-${formatdate("YYYYMMDDhhmmss", timestamp())}"
}
