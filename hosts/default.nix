{ config, nixpkgs, self, inputs, users, ... }:

let 
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
  system = lib.currentSystem;
  lib = nixpkgs.lib;
in
{
  Dell = lib.nixosSystem {
    inherit system;
    specicalArgs = { inherit inputs users; };
    modules = [
      ./system.nix
      # ./laptop_minimal
    ] ++ [
      inputs.nur.nixosModules.nur
      # inputs.home-manager.nixosModules.home-manager
      #{
        # home-manager = {
        #   useGlobalPkgs = true;
        #   useUserPackages = true;
        #   extraSpecialArgs = { inherit user; };
        #   users.${user} = {
        #     imports = [
        #       (import ./laptop/wayland/home.nix)
        #       # (import ./laptop/x11/home.nix)
        #     ] ++ [
        #       inputs.hyprland.homeManagerModules.default
        #     ];
        #   };
        # };
        # nixpkgs = {
        #   overlays =
        #     [
        #       self.overlays.default
        #       inputs.neovim-nightly-overlay.overlay
        #       inputs.rust-overlay.overlays.default
        #       inputs.picom.overlays.default
        #       # inputs.lanzaboote.nixosModules.lanzaboote
        #       # inputs.disko.nixosModules.disko
        #       (import inputs.emacs-overlay)
        #     ]
        #     ++ (import ../overlays);
        # };
      #}
    ];
  };
}