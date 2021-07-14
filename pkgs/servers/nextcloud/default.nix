{ lib, stdenv, fetchurl, nixosTests }:

let
  generic = {
    version, sha256,
    eol ? false, extraVulnerabilities ? []
  }: stdenv.mkDerivation rec {
    pname = "nextcloud";
    inherit version;

    src = fetchurl {
      url = "https://download.nextcloud.com/server/releases/${pname}-${version}.tar.bz2";
      inherit sha256;
    };

    passthru.tests = nixosTests.nextcloud;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/
      cp -R . $out/
      runHook postInstall
    '';

    meta = with lib; {
      description = "Sharing solution for files, calendars, contacts and more";
      homepage = "https://nextcloud.com";
      maintainers = with maintainers; [ schneefux bachp globin fpletz ma27 ];
      license = licenses.agpl3Plus;
      platforms = with platforms; unix;
      knownVulnerabilities = extraVulnerabilities
        ++ (optional eol "Nextcloud version ${version} is EOL");
    };
  };
in {
  nextcloud18 = throw ''
    Nextcloud v18 has been removed from `nixpkgs` as the support for it was dropped
    by upstream in 2021-01. Please upgrade to at least Nextcloud v19 by
    declaring

        services.nextcloud.package = pkgs.nextcloud19;

    in your NixOS config.

    [1] https://docs.nextcloud.com/server/18/admin_manual/release_schedule.html
  '';

  nextcloud19 = generic {
    version = "19.0.13";
    sha256 = "sha256-pc5sS7cK65c5vwG7NhKaWU2DeXHovSHH0wEmeosxIg8=";
    extraVulnerabilities = [
      "Nextcloud 19 is still supported, but CVE-2020-8259 & CVE-2020-8152 are unfixed! Please note that both CVEs only affect the file encryption module which is turned off by default. Alternatively, `pkgs.nextcloud20` can be used."
      "Nextcloud 19 is EOL!"
    ];
  };

  nextcloud20 = generic {
    version = "20.0.11";
    sha256 = "sha256-CLrJH5eNTiJJrDzfCg+re3J2qmwxFOe12nUU/QgtD6A=";
  };

  nextcloud21 = generic {
    version = "21.0.3";
    sha256 = "8adcd175c7a70c33332586fa9ce36d03ba02d1df5d4c334d1210201d3fb953ee";
  };

  nextcloud22 = generic {
    version = "22.0.0";
    sha256 = "sha256-ORHTdUw3rKfJtfOys3UTwPK1u5ea8AgWwRF7Hu28XXo=";
  };
  # tip: get she sha with:
  # curl 'https://download.nextcloud.com/server/releases/nextcloud-${version}.tar.bz2.sha256'
}
