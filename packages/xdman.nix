{ lib, stdenv, fetchurl, autoPatchelfHook, makeWrapper, wrapGAppsHook3,
  zstd, gtk3, glib, cairo, pango, atk, gdk-pixbuf, libappindicator-gtk3,
  openssl, zlib, ffmpeg, xdg-utils }:

let
  runtimeLibraries = [
    gtk3 glib cairo pango atk gdk-pixbuf libappindicator-gtk3 openssl
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "xdman";
  version = "8.0.29";

  src = fetchurl {
    url = "https://github.com/subhra74/xdm/releases/download/${finalAttrs.version}/xdman_gtk-${finalAttrs.version}-1-x86_64.pkg.tar.zst";
    hash = "sha256-ffFONhkbc41FhI1Wes+aifAmv1KQME/lA3pSoeTEKuw=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper wrapGAppsHook3 zstd ];
  buildInputs = runtimeLibraries ++ [ stdenv.cc.cc.lib zlib ];
  sourceRoot = ".";
  dontBuild = true;
  dontWrapGApps = true;
  # ponytail: LTTng-трассировка .NET недоступна; добавить совместимую библиотеку, если понадобится профилирование.
  autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/xdman" "$out/bin" "$out/share/applications" "$out/share/icons/hicolor/scalable/apps"
    cp -r opt/xdman/. "$out/lib/xdman/"
    install -m644 usr/share/applications/xdm-app.desktop "$out/share/applications/"
    install -m644 opt/xdman/xdm-logo.svg "$out/share/icons/hicolor/scalable/apps/xdman.svg"
    substituteInPlace "$out/share/applications/xdm-app.desktop" \
      --replace-fail 'Exec=env GTK_USE_PORTAL=1 /opt/xdman/xdm-app' "Exec=$out/bin/xdman" \
      --replace-fail 'Icon=/opt/xdman/xdm-logo.svg' 'Icon=xdman'
    runHook postInstall
  '';

  # GtkSharp и встроенный .NET загружают библиотеки через dlopen.
  preFixup = ''
    makeWrapper "$out/lib/xdman/xdm-app" "$out/bin/xdman" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}" \
      --prefix PATH : "${lib.makeBinPath [ ffmpeg xdg-utils ]}" \
      --set GTK_USE_PORTAL 1 \
      "''${gappsWrapperArgs[@]}"
  '';

  meta = {
    description = "Download accelerator and video downloader";
    homepage = "https://xtremedownloadmanager.com/";
    license = lib.licenses.gpl2Plus;
    mainProgram = "xdman";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
