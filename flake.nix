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
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ emacs-overlay.overlays.default ];
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
          { nixpkgs.overlays = [ emacs-overlay.overlays.default ]; }
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
