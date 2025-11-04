{ pkgs, ... }:
{
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    # kde
    kdePackages.kcalc
    catppuccin-kde
    kdePackages.kate # text-editor
    kdePackages.kgpg
    kdePackages.merkuro # calendar
    kdePackages.francis # pomodoro
    kdePackages.okular # PDF viewer
    kdePackages.kontrast # color contrast
    kdePackages.calligra # office suite
    kdePackages.akonadi # contacts
    kdePackages.plasma-browser-integration

    # allow customization of panel colors
    plasma-panel-colorizer
  ];
}
