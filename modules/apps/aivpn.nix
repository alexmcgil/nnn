{ pkgs, inputs, ... }:

let
  aivpn = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.aivpn;
in
{
  environment.systemPackages = [ aivpn ];
  security.polkit.enable = true;

  # Nix store не поддерживает setcap: права клиента выдаёт системная обёртка.
  security.wrappers.aivpn-client = {
    source = "${aivpn}/bin/aivpn-client";
    owner = "root";
    group = "users";
    permissions = "u+rx,g+rx,o-rwx";
    capabilities = "cap_net_admin+ep";
  };
}
