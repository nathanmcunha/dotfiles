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

    oh-my-openagent = {
      url = "github:code-yeongyu/oh-my-openagent";
      flake = false;
    };

    superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };

  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      emacs-overlay,
      oh-my-openagent,
      ...
    }:
    let
      system = "x86_64-linux";
      overlays = [
        emacs-overlay.overlays.default
        (import ./overlays/rtk.nix)
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
            oh-my-openagent
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
