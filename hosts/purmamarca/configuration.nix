# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ../../hardware/lenovo/yoga/7/14AHP9/hardware-configuration.nix
    ../../users/woile/user.nix
    ../../users/momo/user.nix
    ../../profiles/laptop
    ../../profiles/homelab
  ];

  # register 'pkgsUnstable' to access anywhere in the config
  # _module.args.pkgsUnstable = import inputs.nixpkgs-unstable {
  #   inherit (pkgs.stdenv.hostPlatform) system;
  #   inherit (config.nixpkgs) config;
  # };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernel.sysctl = {
    # Fair Queueing packet scheduler (required for BBR pacing)
    "net.core.default_qdisc" = "fq";

    # Enable BBR congestion control
    "net.ipv4.tcp_congestion_control" = "bbr";

    # Maximize socket buffer sizes for high BDP (Bandwidth-Delay Product)
    "net.core.rmem_max" = 16777216; # 16 MB
    "net.core.wmem_max" = 16777216; # 16 MB

    # [min, default, max] TCP memory auto-tuning (up to 16 MB)
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
  };
  boot.tmp.cleanOnBoot = true;

  networking.hostName = "purmamarca";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  # time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

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

  # Auto-login user
  services.displayManager.autoLogin = {
    enable = true;
    user = "momo";
  };
  # Set the default session to Plasma Bigscreen
  services.displayManager.sessionPackages = [ pkgs.kdePackages.plasma-bigscreen ];
  services.displayManager.defaultSession = "plasma-bigscreen-wayland";

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  # services.openssh.settings.PermitRootLogin = "yes";

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings.General.Experimental = true;

  # automatically switch to newly-connected devices, is this lenovo specific?
  services.pulseaudio.extraConfig = "load-module module-switch-on-connect";

  # Virtualization
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  services.spice-vdagentd.enable = true; # enable copy and paste between host and guest

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    inputs.temporis.packages.${stdenv.hostPlatform.system}.temporis-desktop
  ];

  networking.firewall.enable = false;
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # nixpkgs.config.cudaSupport = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.11"; # Did you read the comment?

}
