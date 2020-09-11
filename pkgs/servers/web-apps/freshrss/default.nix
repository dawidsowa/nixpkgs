{ config, lib, pkgs, fetchFromGitHub, stdenv, ... }:

stdenv.mkDerivation rec {
  pname = "freshrss";
  version = "1.16.2";

  src = fetchFromGitHub {
    owner = "FreshRSS";
    repo = "FreshRSS";
    rev = version;
    sha256 = "10kqlhy8rs68zcibp4j435nbj9gh0w184ij74w51hl8j3v5zc3d0";
  };

  patchPhase = ''
    substituteInPlace constants.php  \
      --replace "safe_define('DATA_PATH', FRESHRSS_PATH . '/data');" "safe_define('DATA_PATH', getenv('FRESHRSS_DATA') . '/data');"
  '';

  installPhase = ''
    mkdir $out/
    cp -R ./* $out
  '';

  meta = with lib; {
    description = "Self-hosted RSS feed aggregator";
    homepage = "https://freshrss.org/";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ dawidsowa ];
    platforms = platforms.all;
  };
}
