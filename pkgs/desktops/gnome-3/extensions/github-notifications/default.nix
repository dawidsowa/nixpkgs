{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-github-notifications";
  version = "2020-10-10";

  src = fetchFromGitHub {
    repo = "gnome-github-notifications";
    owner = "alexduf";
    rev = "214472571493101706927003c3ed71ae85dc5bae";
    sha256 = "1g0dhk16xfsfgkw6nilx1aylycwzcrp49ar4gj9bx80rbswd4m52";
  };

  uuid = "github.notifications@alexandre.dufournet.gmail.com";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp -r * $out/share/gnome-shell/extensions/${uuid}
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "Integrate github's notifications within the gnome desktop environment";
    license = licenses.gpl2;
    maintainers = with maintainers; [ dawidsowa ];
    platforms = platforms.linux;
    homepage = "https://github.com/alexduf/gnome-github-notifications";
  };
}
