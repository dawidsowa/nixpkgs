{ stdenv, fetchFromGitHub, glib }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-bluetooth-quick-connect";
  version = "13";

  src = fetchFromGitHub {
    repo = "gnome-bluetooth-quick-connect";
    owner = "bjarosze";
    rev = "v${version}";
    sha256 = "17nabca060cm6hrza25wc54w79caikg6gs624aylfjykhg5iv1k6";
  };

  buildInputs = [
    glib
  ];

  uuid = "bluetooth-quick-connect@bjarosze.gmail.com";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp -r * $out/share/gnome-shell/extensions/${uuid}
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Allows paired Bluetooth devices to be connected and disconnected via the GNOME system menu";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ dawidsowa ];
    platforms = platforms.linux;
    homepage = "https://github.com/bjarosze/gnome-bluetooth-quick-connect";
  };
}
