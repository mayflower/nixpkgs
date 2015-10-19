{ fetchzip }:

rec {
  version = "3.3.5";
  src = fetchzip {
    url = "https://www.jool.mx/download/Jool-${version}.zip";
    sha256 = "00ly17ws0dyykvljlvy0c2gyc59l5r39amhgb8plfwhcxvizapi1";
  };
}
