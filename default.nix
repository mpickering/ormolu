let
  pkgs = import ./nix/nixpkgs;
  gitignoreSource = import ./nix/gitignore { inherit (pkgs) lib; };
  compiler = "ghc864";
  source = gitignoreSource ./.;
  cabalSrc0 = pkgs.fetchFromGitHub {
    owner = "haskell";
    repo = "Cabal";
    rev = "9616d6892862b7e082e810e2cbe74334767068db";
    sha256 = "1zj1zaagfnnlwcadlb386cfvvilnc175snz3lcjm8r3vs7i4crwy";
  };
  cabalSrc = pkgs.runCommand "extract-cabal-src" {} ''
    cp -r ${cabalSrc0}/Cabal $out
  '';
  haskellPackages = pkgs.haskell.packages.${compiler}.override {
    overrides = (self: super:
    super // {
      "ormolu" = super.callCabal2nix "ormolu" source { };
      "Cabal" = super.callCabal2nix "Cabal" cabalSrc { };
    });
  };
in {
  ormolu = haskellPackages.ormolu;
  ormolu-shell = haskellPackages.shellFor {
    packages = ps: [ ps.ormolu ];
    buildInputs = [ pkgs.cabal-install ];
  };
}
