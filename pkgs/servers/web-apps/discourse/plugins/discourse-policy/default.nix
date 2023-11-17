{ lib, mkDiscoursePlugin, fetchFromGitHub }:

mkDiscoursePlugin {
  name = "discourse-policy";
  src = fetchFromGitHub {
    owner = "discourse";
    repo = "discourse-policy";
    rev = "109f6ec1031bae6eeaf8e26dab13881440a0be3e";
    sha256 = "sha256-Rhicr5ixR7K/5A8WR2Emz/Qo2hMvh0HzHpqpKVHg8AE=";
  };
  meta = with lib; {
    homepage = "https://github.com/discourse/discourse-policy";
    maintainers = with maintainers; [ willibutz ];
    license = licenses.mit;
    description = "Confirm your users have seen or done something with reminders";
  };
}
