# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./windows-kvm.nix
    ];
  #boot.kernelPackages = pkgs.linuxPackages_6_10;
  boot.kernel.sysctl."kernel.sysrq" = 502;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "trinity"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via w  _supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  networking = {
    firewall = {
      # OpenRA default ports
      allowedTCPPorts = [ 1234 1234 ];  # Game Port
      allowedUDPPorts = [ 1234 1234 5353 ];  # Discovery Port
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

    # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "nl_NL.UTF-8/UTF-8"
  ];

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.defaultSession = "plasmax11";
  services.xserver.displayManager.sessionCommands = ''
  active_sessions=$(loginctl list-sessions --no-legend | awk -v user=$USER -v seat=$\{XDG_SEAT:-seat0} -v sid=$XDG_SESSION_ID '{gsub(/^[ \t]+/, ""); if ($3 == user && ($6 == "active" || $6 == "online") && $1 != sid) count++} END {print count}')
  if [ "$active_sessions" -gt 0 ] ; then
    zenity --error --text="User $USER is already logged in."
    exit 1
  fi

  #if [ "$XDG_SEAT" = seat1] ; then
  #  /usr/bin/env xrandr --auto || true
  #fi
  '';
  
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "euro";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser ];

  # For printing?
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.dbus.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    frank = {
      isNormalUser = true;
      description = "Frank van Viegen";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
      #  thunderbird
      ];
    };
    quin = {
      isNormalUser = true;
      description = "Quin van Viegen";
    };
    vera = {
      isNormalUser = true;
      description = "Vera van Viegen";
    };
    iris = {
      isNormalUser = true;
      description = "Iris Allijn";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    helix
    brave
    vscode
    git
    furmark
    lshw
    usbutils
    pciutils
    psmisc
    switcheroo-control
    qemu_kvm
    openra
    avahi
    gnome.zenity # for double-login message
    libreoffice-qt
    kdePackages.xdg-desktop-portal-kde
    ktouch
  ];

  programs = {
    kdeconnect = {
      enable = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remoteplay
      dedicatedServer.openFirewall = true; # Open ports in the firewall for steam server
    };
    firefox.enable = true;
    ssh.askPassword = lib.mkForce "${pkgs.ksshaskpass}/bin/ksshaskpass";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.passwordAuthentication = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
