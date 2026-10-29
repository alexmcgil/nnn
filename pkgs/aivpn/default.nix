{ lib, stdenv, rustPlatform, src, pkg-config, makeWrapper, copyDesktopItems, makeDesktopItem
, openssl, wayland, libxkbcommon, vulkan-loader, libGL, libx11, libxcursor, libxi
, iproute2, iptables, nftables, coreutils, bash
}:

rustPlatform.buildRustPackage {
  pname = "aivpn";
  version = "1.2.0-unstable-${builtins.substring 0 7 src.rev}";
  inherit src;
  cargoHash = "sha256-+eoSJdvgwwe2CCijKXIJMdHbqFczW9nN1pvuO167bb4=";

  nativeBuildInputs = [ pkg-config makeWrapper copyDesktopItems ];
  buildInputs = [ openssl ];
  cargoBuildFlags = [ "-p" "aivpn-linux" "-p" "aivpn-client" ];
  buildFeatures = [ "aivpn-client/ssh-install" ];
  cargoTestFlags = [ "-p" "aivpn-client" "--bin" "aivpn-ip-helper" ];

  postCheck = ''
    cargo test --release --offline -j "$NIX_BUILD_CORES" --target ${stdenv.hostPlatform.rust.rustcTarget} \
      -p aivpn-linux nixos_rejects_missing_or_unprivileged_binary
  '';

  postPatch = ''
    # Установку через pkexec/setcap заменяет декларативный модуль NixOS.
    cp ${./privilege-nixos.rs} crates/aivpn-linux/src/app/privilege.rs
    substituteInPlace crates/aivpn-linux/src/vpn_manager.rs \
      --replace-fail 'find_sibling_binary("aivpn-client")' \
        'Ok(PathBuf::from("/run/wrappers/bin/aivpn-client"))'

    substituteInPlace crates/aivpn-client/src/tunnel.rs \
      --replace-fail '/usr/local/libexec/aivpn/aivpn-ip-helper' "$out/bin/aivpn-ip-helper" \
      --replace-fail '"/usr/sbin/ip"' '"${iproute2}/bin/ip"' \
      --replace-fail 'Command::new("pkexec")' 'Command::new("/run/wrappers/bin/pkexec")'
    # Клиент с capability запускает только сетевые утилиты из Nix store.
    substituteInPlace crates/aivpn-client/src/tunnel.rs \
      --replace-fail 'std::env::var_os("PATH")' \
        'Some(std::ffi::OsString::from("${lib.makeBinPath [ iproute2 iptables nftables ]}"))'
    substituteInPlace crates/aivpn-client/src/tunnel.rs crates/aivpn-client/src/transport_routes.rs \
      --replace-fail 'Command::new("ip")' 'Command::new("${iproute2}/bin/ip")'
    substituteInPlace crates/aivpn-client/src/bin/aivpn-ip-helper.rs \
      --replace-fail 'Command::new("ip")' 'Command::new("${iproute2}/bin/ip")'
    substituteInPlace crates/aivpn-client/src/kill_switch.rs \
      --replace-fail '/usr/sbin/nft' '${nftables}/bin/nft'
    substituteInPlace platforms/linux/polkit/com.aivpn.client.policy \
      --replace-fail '/usr/local/libexec/aivpn/aivpn-ip-helper' "$out/bin/aivpn-ip-helper"
  '';

  desktopItems = [ (makeDesktopItem {
    name = "aivpn";
    desktopName = "AIVPN";
    exec = "aivpn-linux";
    icon = "aivpn";
    categories = [ "Network" ];
    terminal = false;
  }) ];

  postInstall = ''
    install -Dm644 assets/brand/icon-1024.png $out/share/icons/hicolor/1024x1024/apps/aivpn.png
    install -Dm644 platforms/linux/polkit/com.aivpn.client.policy \
      $out/share/polkit-1/actions/com.aivpn.client.policy
  '';

  postFixup = ''
    wrapProgram $out/bin/aivpn-linux \
      --prefix PATH : ${lib.makeBinPath [ iproute2 iptables nftables coreutils bash ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ wayland libxkbcommon vulkan-loader libGL libx11 libxcursor libxi ]}
  '';

  meta = {
    description = "AIVPN Linux GUI and client";
    homepage = "https://github.com/infosave2007/aivpn";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "aivpn-linux";
  };
}
