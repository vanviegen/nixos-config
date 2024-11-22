{ config, lib, pkgs, ... }:

{
  specialisation.windows-kvm.configuration = {
    systemd.services.windows-kvm = {
      description = "Windows KVM";
      after = [ "display-manager.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "/etc/nixos/windows-kvm.nix";
        ExecStop = "kill -SIGTERM `pgrep(qemu-system-x86_64)`";
      };
    };
    
    # VFIO configuration for NVIDIA GPU
    boot.kernelParams = [
      "vfio-pci.ids=10de:1b80,10de:10f0" # Your GTX 1080 GPU and its audio controller
    ];
    boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
    boot.extraModprobeConfig = ''
      options vfio-pci ids=10de:1b80,10de:10f0
    '';

    hardware.nvidia = {
      modesetting.enable = lib.mkForce false;
    };

    # Load nvidia driver for Xorg and Wayland
    services.xserver.videoDrivers = lib.mkForce ["amdgpu"];
    
    # For the UEFI BIOS files
    virtualisation.libvirtd.enable = true;                                                                                                                                                                                                                                                                           
  };
  
}
