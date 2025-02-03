#!/run/current-system/sw/bin/bash

echo windows-kvm $1
export PATH=/run/wrappers/bin:/run/current-system/sw/bin

if [ "$1" = "session" ] ; then
  exec systemd-run --user --remain-after-exit /etc/nixos/windows-kvm.sh sudo
  exit 1
fi

if [ "$1" = "sudo" ] ; then
  exec sudo /etc/nixos/windows-kvm.sh linger $USER
  exit 1
fi

if [ "$1" = "linger" ] ; then
  loginctl enable-linger "$2"
fi

if [ "$1" != "stop" ] ; then
  echo Sleep
  sleep 4

  echo Kill X
  kill -9 `lsof -t /dev/dri/by-path/pci-0000:10:00.0-*`

  echo Unbind nvidia
  echo '0000:10:00.0' > /sys/bus/pci/drivers/nvidia/unbind
  # echo '0000:10:00.1' > /sys/bus/pci/drivers/nvidia/unbind

  echo Unload nvidia
  rmmod nvidia_drm nvidia_uvm nvidia_modeset nvidia

  echo Bind vfio
  modprobe vfio-pci
  echo 10de 1b80 > /sys/bus/pci/drivers/vfio-pci/new_id
  echo 10de 10f0 > /sys/bus/pci/drivers/vfio-pci/new_id
  echo "0000:10:00.0" > /sys/bus/pci/devices/0000:10:00.0/driver/unbind
  echo "0000:10:00.1" > /sys/bus/pci/devices/0000:10:00.1/driver/unbind
  echo "0000:10:00.0" > /sys/bus/pci/drivers/vfio-pci/bind
  echo "0000:10:00.1" > /sys/bus/pci/drivers/vfio-pci/bind
fi

if [ "$1" != "stop" -a "$1" != "reset" ] ; then
  echo Starting QEMU
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
    -drive if=pflash,format=raw,readonly=on,file=/run/current-system/sw/share/qemu/edk2-x86_64-code.fd \
    -drive if=pflash,format=raw,file=/home/frank/ovmf_vars_win11.fd \
    -device ahci,id=ahci \
    -device ide-hd,drive=extra-disk,bus=ahci.0 \
    -device ide-hd,drive=windows-disk,bus=ahci.1 \
    -device ide-hd,drive=linux-disk,bus=ahci.2 \
    -drive id=extra-disk,file=/dev/sdc,if=none,media=disk,format=raw \
    -drive id=windows-disk,file=/dev/sdb,if=none,media=disk,format=raw \
    -drive id=linux-disk,file=/dev/sda,if=none,media=disk,format=raw,snapshot=on \
    -netdev user,id=hostnet0 \
    -device e1000,netdev=hostnet0 \
    -device qemu-xhci,id=xhci \
    -device usb-host,hostbus=1,hostport=5.1 \
    -device usb-host,hostbus=1,hostport=5.4 \
    -display none
fi

echo Unbind vfio
echo 0000:10:00.0 > /sys/bus/pci/drivers/vfio-pci/unbind
echo 0000:10:00.1 > /sys/bus/pci/drivers/vfio-pci/unbind
echo 10de 1b80 > /sys/bus/pci/drivers/vfio-pci/remove_id
echo 10de 10f0 > /sys/bus/pci/drivers/vfio-pci/remove_id

echo Reloading nvidia
modprobe nvidia_drm nvidia_uvm nvidia_modeset nvidia
