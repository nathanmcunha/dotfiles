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
      # Absolute path (Nix flakes restrict path: to self/subdirs; parent paths not allowed)
      url = "path:/home/nathanmcunha/.config/emacs";
      flake = false;
    };

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.55.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impala = {
      url = "github:pythops/impala";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia/legacy-v4";
      # url = "github:noctalia-dev/noctalia-shell/57be32b0a81471ef6c5dceff6faad23b534ec7f8";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };
    monique = {
      url = "github:ToRvaLDz/monique";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      emacs-overlay,
      monique,
      helium,
      llm-agents,
      ...
    }:
    let
      system = "x86_64-linux";
      overlays = [
        emacs-overlay.overlays.default
        (import ./overlays/bun.nix)
        monique.overlays.default
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
            helium
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
