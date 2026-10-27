{
  description = "tm's machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-homebrew,
      comin,
      ...
    }:
    {
      darwinConfigurations =
        nixpkgs.lib.genAttrs
          [
            "tiny"
            "hole"
          ]
          (
            host:
            nix-darwin.lib.darwinSystem {
              modules = [
                nix-homebrew.darwinModules.nix-homebrew
                home-manager.darwinModules.home-manager
                comin.darwinModules.comin
                ./hosts/${host}.nix
              ];
            }
          );

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
    };
}
