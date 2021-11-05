docker_jenkins_env_vars = {
  "java_opts": "-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false",
}
volume_name = "jenkins-volume"
register_consul_service = true
plugins = ["configuration-as-code", "job-dsl"]
jasc_config = <<EOF
jenkins:
  numExecutors: 2
jobs:
  - script: >
      job('jobdsl_test') {
        steps {
            shell('whoami')
        }
      }
EOF
