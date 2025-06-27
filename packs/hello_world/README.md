# Hello World Service

This pack is a simple Nomad job that runs as a service and can be accessed via HTTP.

## Changing the Message

To change the message this server responds with, change the "message" variable when running the pack.

```
nomad-pack run hello_world --var message="Hola Mundo!"
```

This tells Nomad Pack to tweak the `MESSAGE` environment variable that the service reads from.

## Variables

- `message` (string:"Hello World!") - The message your application will respond with
- `count` (number:2) - The number of app instances to deploy
- `job_name` (string) - The name to use as the job name which overrides using
  the pack name
- `datacenters` (list of strings:["*"]) - A list of datacenters in the region which
  are eligible for task placement
- `region` (string) - The region where jobs will be deployed
- `register_service` (bool: true) - If you want to register a Nomad service
  for the job
- `service_tags` (list of string) - The service tags for the hello_world application
- `service_name` (string) - The service name for the hello_world application
