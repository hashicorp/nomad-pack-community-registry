prometheus_task_app_rules_yaml = <<EOF
---
groups:
- name: AllInstances
  rules:
  - alert: PrometheusAlertmanagerE2eDeadManSwitch
    expr: vector(1)
    for: 0m
    labels:
      severity: critical
EOF
