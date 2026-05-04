{
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    ./disko.nix
    ../../users/woile/user.nix
  ];
  boot.kernelParams = [ "console=ttyS0" ]; # for scaleway serial connection
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "/dev/vda";
  };
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  system.stateVersion = "26.01";
  networking.hostName = "amaru";

  networking.enableIPv6 = true;
  networking.useDHCP = true;
  networking.useNetworkd = true;
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
      device = "/swapfile";
      size = 2048;
    }
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.PermitRootLogin = "prohibit-password";
  };
}
