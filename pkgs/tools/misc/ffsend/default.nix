{ stdenv, fetchFromGitLab, rustPlatform, cmake, pkgconfig, openssl
, darwin, installShellFiles

, x11Support ? stdenv.isLinux || stdenv.hostPlatform.isBSD
, xclip ? null, xsel ? null
, preferXsel ? false # if true and xsel is non-null, use it instead of xclip
}:

let
  usesX11 = stdenv.isLinux || stdenv.hostPlatform.isBSD;
in

assert (x11Support && usesX11) -> xclip != null || xsel != null;

with rustPlatform;

buildRustPackage rec {
  pname = "ffsend";
  version = "0.2.61";

  src = fetchFromGitLab {
    owner = "timvisee";
    repo = "ffsend";
    rev = "v${version}";
    sha256 = "1d0rx5gcp9z06kxjknqa1r2b4m5c4vrhp4a9spkawvgiky5a9x07";
  };

  cargoSha256 = "1bmyhg1y4gz719nsfdfjf4y73f9l6aag17dx9iazfzwnwwaq46m9";

  nativeBuildInputs = [ cmake pkgconfig installShellFiles ];
  buildInputs = [ openssl ]
  ++ stdenv.lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices Security AppKit ])
  ;

  preBuild = stdenv.lib.optionalString (x11Support && usesX11) (
    if preferXsel && xsel != null then ''
      export XSEL_PATH="${xsel}/bin/xsel"
    '' else ''
      export XCLIP_PATH="${xclip}/bin/xclip"
    ''
  );

  postInstall = ''
    installShellCompletion contrib/completions/ffsend.{bash,fish} --zsh contrib/completions/_ffsend
  '';
  # There's also .elv and .ps1 completion files but I don't know where to install those

  meta = with stdenv.lib; {
    description = "Easily and securely share files from the command line. A fully featured Firefox Send client";
    longDescription = ''
      Easily and securely share files and directories from the command line through a safe, private
      and encrypted link using a single simple command. Files are shared using the Send service and
      may be up to 2GB. Others are able to download these files with this tool, or through their
      web browser.
    '';
    homepage = "https://gitlab.com/timvisee/ffsend";
    license = licenses.gpl3;
    maintainers = with maintainers; [ lilyball equirosa ];
    platforms = platforms.unix;
  };
}
