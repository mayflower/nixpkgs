{ cert, group, groups, user, service }: {
  assertion = cert.group == group || builtins.any (u: u == user) groups.${cert.group}.members || builtins.elem cert.group service.serviceConfig.SupplementaryGroups;
  message = "Group for certificate ${cert.domain} must be ${group}, or user ${user} must be a member of group ${cert.group}";
}
