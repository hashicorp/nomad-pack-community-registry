# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://www.sonarqube.org/"
  author = "SonarSource"
}

pack {
  name        = "sonarqube"
  description = "SonarQube is an open-source platform developed by SonarSource for continuous inspection of code quality to perform automatic reviews with static analysis of code to detect bugs, code smells, and security vulnerabilities on 20+ programming languages."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/sonarqube"
  version     = "0.0.1"
}

integration {
  identifier = "nomad/hashicorp/sonarqube"
  name       = "SonarQube"
}
