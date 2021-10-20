# Caasperli Nomad Pack

This is a pack for [Caasperli](https://github.com/adfinis-sygroup/potz-holzoepfel-und-zipfelchape), a simple container used for demonstration purposes.

## How to Run this Nomad Pack

Start a [Nomad dev agent](https://learn.hashicorp.com/tutorials/nomad/get-started-run?in=nomad/get-started) (if needed):
```bash
$ nomad agent -dev
```

To run the pack:
```bash
$ nomad-pack run . --var static_port=8080
```

The Caasperli app can be accessed on http://127.0.0.1:8080.

To destroy the pack:
```bash
$ nomad-pack destroy .
```

## Variables

- `job_name` (string) - The name to use as the job name which overrides using the pack name
- `region` (string) - The region where jobs will be deployed
- `datacenters` (list of strings) - A list of datacenters in the region which are eligible for task placement
- `count` (number) - The number of app instances to deploy
- `static_port` (number) - The static port for exposing the app service. If defined, exposes the app service on `static_port`.