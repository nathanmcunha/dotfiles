{
  description = "Nathan's NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-config = {
      url = "git+https://github.com/nathanmcunha/emacs-config.git?ref=main";
      flake = false;
    };

    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impala = {
      url = "github:pythops/impala";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      emacs-overlay,
      hermes-agent,
      hyprland,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ emacs-overlay.overlays.default ];
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = false;
        };
      };
    in
    {
      homeConfigurations."nathanmcunha" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = {

          inherit
            inputs
            system
            hermes-agent
            ;
        };
      };

      nixosConfigurations."nathanmcunha-nixos" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          lib = nixpkgs.lib;
        };
        modules = [
          ./hosts/nathanmcunha-nixos/configuration.nix
          { nixpkgs.overlays = [ emacs-overlay.overlays.default ]; }
        ];
      };
    };
}
