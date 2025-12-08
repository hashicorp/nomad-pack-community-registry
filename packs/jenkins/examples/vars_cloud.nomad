# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

docker_jenkins_env_vars = {
  "java_opts": "-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false",
}
jasc_config = <<EOF
jenkins:
  agentProtocols:
  - "JNLP4-connect"
  - "Ping"
  clouds:
  - nomad:
      name: "nomad"
      nomadUrl: "http://{{ env "attr.unique.network.ip-address" }}:4646"
      prune: true
      templates:
      - idleTerminationInMinutes: 10
        jobTemplate: |-
          {
            "Job": {
              "Region": "global",
              "ID": "%WORKER_NAME%",
              "Type": "batch",
              "Datacenters": [
                "dc1"
              ],
              "TaskGroups": [
                {
                  "Name": "jenkins-worker-taskgroup",
                  "Count": 1,
                  "RestartPolicy": {
                    "Attempts": 0,
                    "Interval": 10000000000,
                    "Mode": "fail",
                    "Delay": 1000000000
                  },
                  "Tasks": [
                    {
                      "Name": "jenkins-worker",
                      "Driver": "docker",
                      "Config": {
                        "image": "jenkins/inbound-agent"
                      },
                      "Env": {
                        "JENKINS_URL": "http://{{ env "NOMAD_ADDR_http" }}",
                        "JENKINS_AGENT_NAME": "%WORKER_NAME%",
                        "JENKINS_SECRET": "%WORKER_SECRET%",
                        "JENKINS_TUNNEL": "{{ env "NOMAD_ADDR_jnlp" }}"
                      },
                      "Resources": {
                        "CPU": 500,
                        "MemoryMB": 256
                      }
                    }
                  ],
                  "EphemeralDisk": {
                    "SizeMB": 300
                  }
                }
              ]
            }
          }
        labels: "nomad"
        numExecutors: 1
        prefix: "jenkins"
        reusable: true
      tlsEnabled: false
      workerTimeout: 1
  numExecutors: 0
jobs:
  - script: >
      job('nomad') {
        label('nomad')
        steps {
            shell('whoami')
        }
      }
EOF
plugins = ["configuration-as-code", "hashicorp-vault-plugin", "job-dsl", "nomad"]
register_consul_service = true
volume_name = "jenkins"
