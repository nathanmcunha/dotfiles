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
      # Local dev mode: iterate on ~/.config/emacs without pushing upstream.
      url = "path:/home/nathanmcunha/.config/emacs";
      flake = false;
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
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

    superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };
    oh-my-pi = {
      url = "github:can1357/oh-my-pi";
    };

    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      emacs-overlay,
      oh-my-pi,
      nixpkgs-wayland,
      nix-gaming,
      nur,
      ...
    }:
    let
      system = "x86_64-linux";
      overlays = [
        emacs-overlay.overlays.default
        (import ./overlays/rtk.nix)
        nixpkgs-wayland.overlays.default
        nix-gaming.overlays.default
        nur.overlays.default
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
        config = {
          allowUnfree = true;
          allowUnsupportedSystem = false;
        };
      };
      homeConfig = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = {
          inherit
            inputs
            system
            oh-my-pi
            ;
        };
      };
      nixosConfig = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          lib = nixpkgs.lib;
        };
        modules = [
          ./hosts/nathanmcunha-nixos/configuration.nix
          { nixpkgs.overlays = overlays; }
        ];
      };
    in
    {
      homeConfigurations."nathanmcunha" = homeConfig;
      checks.${system} = {
        home-configuration = homeConfig.activationPackage;
        nixos-configuration = nixosConfig.config.system.build.toplevel;
      };

      nixosConfigurations."nathanmcunha-nixos" = nixosConfig;
    };
}
