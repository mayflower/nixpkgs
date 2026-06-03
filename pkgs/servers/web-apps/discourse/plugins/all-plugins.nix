{ mkDiscoursePlugin, newScope, ... }@args:
let
  callPackage = newScope args;
in
{
  discourse-adplugin = callPackage ./discourse-adplugin { };
  discourse-akismet = callPackage ./discourse-akismet { };
  discourse-apple-auth = callPackage ./discourse-apple-auth { };
  discourse-assign = callPackage ./discourse-assign { };
  discourse-bbcode-color = callPackage ./discourse-bbcode-color { };
  discourse-cakeday = callPackage ./discourse-cakeday { };
  discourse-calendar = callPackage ./discourse-calendar { };
  discourse-chat-integration = callPackage ./discourse-chat-integration { };
  discourse-data-explorer = callPackage ./discourse-data-explorer { };
  discourse-docs = callPackage ./discourse-docs { };
  discourse-events = callPackage ./discourse-events { };
  discourse-follow = callPackage ./discourse-follow { };
  discourse-gamification = callPackage ./discourse-gamification { };
  discourse-github = callPackage ./discourse-github { };
  discourse-graphviz = callPackage ./discourse-graphviz { };
  discourse-ldap-auth = callPackage ./discourse-ldap-auth { };
  discourse-linkedin-auth = callPackage ./discourse-linkedin-auth { };
  discourse-lti = callPackage ./discourse-lti { };
  discourse-math = callPackage ./discourse-math { };
  discourse-migratepassword = callPackage ./discourse-migratepassword { };
  discourse-oauth2-basic = callPackage ./discourse-oauth2-basic { };
  discourse-openid-connect = callPackage ./discourse-openid-connect { };
  discourse-patreon = callPackage ./discourse-patreon { };
  discourse-policy = callPackage ./discourse-policy { };
  discourse-prometheus = callPackage ./discourse-prometheus { };
  discourse-reactions = callPackage ./discourse-reactions { };
  discourse-saml = callPackage ./discourse-saml { };
  discourse-saved-searches = callPackage ./discourse-saved-searches { };
  discourse-solved = callPackage ./discourse-solved { };
  discourse-subscriptions = callPackage ./discourse-subscriptions { };
  discourse-tooltips = callPackage ./discourse-tooltips { };
  discourse-whos-online = callPackage ./discourse-whos-online { };
  discourse-yearly-review = callPackage ./discourse-yearly-review { };
}
