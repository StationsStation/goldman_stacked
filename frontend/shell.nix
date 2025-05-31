let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  packages = with pkgs; [
    nodejs
    corepack
    # Add AppImage dependencies
    xdg-utils
    fuse
    appimage-run
    appimagekit
    jdk
    # rust tools
    rustup
    cargo
    typeshare
  ];
  nativeBuildInputs =
    with pkgs;
    [
      # Rust toolchain
      rustc
      cargo
      rustup
      pkg-config
      # java
      jdk
    ]
    # Brings in most of our GTK stuff for Linux
    ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];
  buildInputs =
    with pkgs;
    [ 
      openssl
      # Add these dependencies for bundling
      xdg-utils  # Make sure it's here too for visibility
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      # Required for most applications
      glib-networking
      webkitgtk_4_1
      # AppImage dependencies
      squashfsTools
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.apple_sdk.frameworks.WebKit
    ];
  
  # Add this shellHook to ensure XDG-related environment variables are set
  shellHook = ''
    rustup default 1.85.0
    rustup component add rust-src
    export PATH=/home/$(whoami)/.cargo/bin:$PATH
    export XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS
  '';
}
