{
  pkgs,
  modulesPath,
  config,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    ./disks.nix
    ../../users/woile/user.nix
    ./bastion.nix
  ];
  boot.kernelParams = [ "console=ttyS0" ]; # for scaleway serial connection
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "/dev/vda";
  };
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  system.stateVersion = "26.11";

  networking.hostName = "amaru";
  networking.enableIPv6 = true;
  networking.useDHCP = true;
  networking.useNetworkd = true;

  networking.interfaces.ens2.ipv6.addresses = [
    {
      # Block assigned by Scaleway when created a Flexible IPv6
      # We make NixOS listen to all of it
      address = "2001:bc8:1d90:1f4f::";
      prefixLength = 64;
    }
  ];

  systemd.network.enable = true;
  nix.settings = {
    trusted-users = [
      "root"
      "woile"
      "@wheel"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  environment.shellAliases = {
    neofetch = "macchina";
    tig = "gitui";
    cat = "bat -pp";
    du = "dust";
    htop = "btm";
  };
  environment.systemPackages = with pkgs; [
    macchina
    dust
    gitui
    bottom
    systemctl-tui
  ];

  programs.starship.enable = true;
  programs.bash.enable = true;
  programs.bat.enable = true;

  # Do not request a password for sudo wheel members
  # DO NOT CHANGE OTHERWISE WE LOSE ACCESS TO THE VM
  security.sudo.wheelNeedsPassword = false;

  # Essential swap for 2GB RAM instance
  swapDevices = [
    {
      device = "/swap";
      size = 2048;
    }
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "prohibit-password";
  };

  users.users.root.openssh.authorizedKeys.keys = config.users.users.woile.openssh.authorizedKeys.keys;
}
