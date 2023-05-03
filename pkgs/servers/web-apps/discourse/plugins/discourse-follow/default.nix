{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-follow";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-follow";
    rev = "bae520c491b27e23cc1b7b0b6987191fa0a7e514";
    sha256 = "sha256-0ytXoWCKqhQAwq42EjEvGBlRXcThLwLfDrC2s/4dsFE=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-follow";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.gpl2;
    description = "Allows you to follow other users, list the latest topics involving them and receive notifications when they post";
  };
}
