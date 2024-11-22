#!/bin/sh

qemu-system-x86_64 \
  -name windows-kvm \
  -enable-kvm \
  -m 16G \
  -smp 8 \
  -cpu host,kvm=on \
  -device vfio-pci,host=10:00.0,x-vga=on \
  -device vfio-pci,host=10:00.1 \
  -boot order=d \
  -vga none \
  -nographic \
  -drive if=pflash,format=raw,readonly=on,file=/run/libvirt/nix-ovmf/OVMF_CODE.fd \
  -drive if=pflash,format=raw,file=/home/frank/ovmf_vars_win11.fd \
  -device ahci,id=ahci \
  -device ide-hd,drive=disk,bus=ahci.0 \
  -device ide-hd,drive=linux-disk,bus=ahci.1 \
  -device ide-hd,drive=extra-disk,bus=ahci.2 \
  -drive id=disk,file=/dev/sdc,if=none,media=disk,format=raw \
  -drive id=linux-disk,file=/dev/sdb,if=none,media=disk,format=raw,snapshot=on \
  -drive id=extra-disk,file=/dev/sda,if=none,media=disk,format=raw,snapshot=on \
  -netdev user,id=hostnet0 \
  -device e1000,netdev=hostnet0 \
  -device qemu-xhci,id=xhci \
  -device usb-host,hostbus=1,hostport=5 \
  -display none

#  -device usb-host,hostbus=1,hostaddr=16 \
#  -device usb-host,hostbus=1,hostaddr=17 \
