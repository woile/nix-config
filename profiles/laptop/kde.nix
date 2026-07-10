{ pkgs, ... }:
{
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    # core
    kdePackages.kcalc
    kdePackages.kcontacts
    kdePackages.kate # text-editor
    kdePackages.kgpg
    kdePackages.merkuro # calendar
    kdePackages.okular # PDF viewer
    kdePackages.akonadi # contacts
    kdePackages.kontrast # color accessibility
    kdePackages.calligra # office suite
    kdePackages.plasma-browser-integration
    kdePackages.kirigami-gallery # examples of Kirigami components
    kdePackages.plasma-bigscreen # media center
    (pkgs.kdePackages.spectacle.override {
      tesseractLanguages = [
        "eng"
        "spa"
        "por"
        "nld"
      ];
    })
    fluffychat # matrix chat client

    foliate # e-book reader
    # Theme
    catppuccin-kde

    # art
    kdePackages.kontrast # color contrast
    pinta
    krita

    # allow customization of panel colors
    plasma-panel-colorizer

    # jellyfin client
    fladder
    gelly
  ];
}
