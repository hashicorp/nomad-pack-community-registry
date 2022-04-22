# Consul-Lock

A pack that demonstrates a script for ensuring that a single Nomad
allocation of a job is running at one time.  Based on the Consul Learn
Guide for [application leader
elections](https://learn.hashicorp.com/tutorials/consul/application-leader-elections).

This pack runs a prestart sidecar task alongside the main task. The
prestart sidecar runs a script that obtains a lock in Consul and
periodically renews it. If the lock is successful, the script will
write a lock directory into the alloc dir. If it exits it
will release the lock (or the lock's TTL will expire).

The main task waits until this lock directory appears to execute its
application.

To adapt this script for transitioning leader elections back and forth
between allocations based on health checks, we recommend using
something other than shell scripts.

## Variables

* `job_name` (string "example") - The name of the job.
* `datacenters` (list(string) ["dc1"]) - A list of datacenters in the
  region which are eligible for task placement.
* `region` (string "global") - The region where the job should be
  placed.
* `namespace` (string "default") - The namespace for the job.
* `locker_image` (string "curlimages/curl:latest") - The container
  image for the locking script. This image needs to include `curl`.
* `locker_script_path` (string "./templates/script.sh") The path to
  the locker script.
* `locker_key` (string "leader") The key in Consul to use. If you use
  a key that's unique per client such as `${attr.unique.hostname}`,
  you can have a leader-per node.
* `application_image` (string "busybox:1") The container image for the
  main task. This image needs to include a shell at `/bin/sh`.
* `application_args` (string "httpd -v -f -p 8001 -h /local") The
  command and args for the main task's application.
* `application_port_name` (string "port") The name of the port the application listens on.
* `application_port` (number 8001) The port the application listens on.

#### `constraints` List of Objects

[Nomad job specification
constraints](https://www.nomadproject.io/docs/job-specification/constraint)
allow restricting the set of eligible nodes on which the tasks will
run. This pack automatically configures a constraint to run the tasks
on Linux hosts only.

You can set additional constraints with the `constraints` variable,
which takes a list of objects with the following fields:

* `attribute` (string) - Specifies the name or reference of the
  attribute to examine for the constraint.
* `operator` (string) - Specifies the comparison operator. The
  ordering is compared lexically.
* `value` (string) - Specifies the value to compare the attribute
  against using the specified operation.

Below is also an example of how to pass `constraints` to the CLI with
with the `-var` argument.

```bash
nomad-pack run -var 'constraints=[{"attribute":"$${meta.my_custom_value}","operator":">","value":"3"}]' packs/consul_lock
```

#### `resources` Object

* `cpu` (number 500) - Specifies the CPU required to run the main task in
  MHz.
* `memory` (number 256) - Specifies the memory required by the main
  task in MB.

## Demonstration

Run two jobs from this same pack.

```
$ nomad-pack run -var job_name=left .
  Evaluation ID: 7c8e6fc2-f0e3-8e2d-2c0a-6e7376d9b003
  Job 'left' in pack deployment 'consul_lock' registered successfully
Pack successfully deployed. Use . to manage this this deployed instance with plan, stop,
destroy, or info

$ nomad-pack run -var job_name=right .
  Evaluation ID: 404a4ead-8eee-3065-88cc-40a62f94717e
  Job 'right' in pack deployment 'consul_lock' registered successfully
Pack successfully deployed. Use . to manage this this deployed instance with plan, stop,
destroy, or info
```

The `left` job will have the lock and its `main` task will be running
the webserver.

```
$ nomad job status left
...
Allocations
ID        Node ID   Task Group  Version  Desired  Status    Created    Modified
fec2087e  9a68eb5e  group       0        run      running   1m13s ago  1m2s ago

$ nomad alloc logs -task block_for_lock fec2087e
...
got session lock 81c6852d-e8a3-4a7b-4725-c4a414b2bc6c
refreshing session every 5 seconds

$ nomad alloc exec -task main fec2087e ps
PID   USER     TIME  COMMAND
    1 root      0:00 httpd -v -f -p 8001 -h /local
   10 root      0:00 ps
```

The `right` job will have running tasks, but they'll be blocked
waiting for the tasks from the `left` job to exit.

```
$ nomad job status right
...
Allocations
ID        Node ID   Task Group  Version  Desired  Status    Created     Modified
676e2426  9a68eb5e  group       0        run      running   1m57s ago   1m45s ago

$ nomad alloc logs -task block_for_lock 676e2426
...
polling for session to be released every 5 seconds

$ nomad alloc exec -task main 676e2426 ps
PID   USER     TIME  COMMAND
    1 root      0:00 /bin/sh local/wait.sh
   18 root      0:00 sleep 1
   19 root      0:00 ps
```

Now stop the `left` job and we can see that it releases the lock. Or
you can kill the task container and the TTL will expire, which has the
same effect.

```
$ nomad job stop left
$ nomad alloc logs -task block_for_lock fec2087e
...
releasing session 81c6852d-e8a3-4a7b-4725-c4a414b2bc6c
true%
```

And the `right` job will now have the lock:

```
$ nomad alloc logs -task block_for_lock 676e2426
...
got session lock 81d031db-8866-3703-e15b-b8c2a10e26c8
refreshing session every 5 seconds

$ nomad alloc exec -task main 676e2426 ps
PID   USER     TIME  COMMAND
    1 root      0:00 httpd -v -f -p 8001 -h /local
  253 root      0:00 ps
```
