{ stdenv
, lib
, fetchFromGitLab
, meson
, pkg-config
, glib
, ninja
, gnome3
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-task-widget";
  version = "4";

  src = fetchFromGitLab {
    owner = "jmiskinis";
    repo = "gnome-shell-extension-task-widget";
    rev = "v${version}";
    sha256 = "07adx45cix2wrpzr5kii1wmk6g4mdib859swijmnh4z5v8hrdahn";
  };

  buildInputs = [
    meson
    pkg-config
    glib
    ninja
  ];

  uuid = "task-widget@juozasmiskinis.gitlab.io";

  meta = with stdenv.lib; {
    description = "Extension for GNOME that displays tasks next to the calendar widget";
    license = licenses.gpl2;
    maintainers = with maintainers; [ dawidsowa ];
    homepage = "https://gitlab.com/jmiskinis/gnome-shell-extension-task-widget";
  };
}
