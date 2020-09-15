{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-steal-my-focus";
  version = "2017-02-22";

  src = fetchFromGitHub {
    owner = "Ninlives";
    repo = "gnome-shell-extension-stealmyfocus";
    rev = "06da2000d37d1eb9e9c421987b7baaf7fb58d3c2";
    sha256 = "0x7knd4dzzcpdw1xl4m5ivqg57q9bkhizxw8jzirxrwsp52rfxya";
  };

  uuid = "steal-my-focus@kagesenshi.org";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions/${uuid}
    cp ${src}/* $out/share/gnome-shell/extensions/${uuid}
    runHook postInstall
  '';

  meta = with stdenv.lib; {
    description = "It removes the 'Window is ready' notification and puts the window immediately into focus instead";
    homepage = "https://github.com/nunofarruca/WindowIsReady_Remover";
    maintainers = with maintainers; [ dawidsowa ];
  };
}
