# HashiCups

[HashiCups](https://github.com/hashicorp-demoapp) is a demo webapp of a coffee shop application. This pack is configured to run on a Nomad cluster without the use of Consul for service discovery.

## Variables

|Variable|Default Value (type)|Description|
|---|---|---|
|`datacenters`|`["dc1"]` (list of strings)|A list of datacenters in the region which are eligible for task placement.|
|`region`|`global` (string)|The region where the job should be placed.|
|`frontend_version`|`v1.0.2` (string)|Frontend Docker image version.|
|`public_api_version`|`v0.0.6` (string)|Public API Docker image version.|
|`payments_version`|`v0.0.12` (string)|Payments API Docker image version.|
|`product_api_version`|`v0.0.20` (string)|Products API Docker image version.|
|`product_api_db_version`|`v0.0.20` (string)|Products API database Docker image version.|
|`postgres_db`|`products` (string)|The Postgres database name.|
|`postgres_user`|`postgres` (string)|The Postgres database user.|
|`postgres_password`|`password` (string)|The Postgres database user's password.|
|`db_port`|`5432` (number)|The Postgres database port.|
|`product_api_port`|`9090` (number)|The products API service port.|
|`frontend_port`|`3000` (number)|The frontend service port.|
|`payments_api_port`|`8080` (number)|The payments API service port.|
|`public_api_port`|`8081` (number)|The public API service port.|
|`nginx_port`|`80` (number)|The Nginx reverse proxy port.|

## Prerequisites

- Nomad cluster (a [local dev cluster](https://learn.hashicorp.com/tutorials/nomad/get-started-run) will work) with Docker available on the node(s)
- Ability to access Nomad client on port 80

## Docker Desktop Notes
If you are running Nomad on your local machine with Docker Desktop, you'll need to bind the Nomad client to a non-loopback network interface so that the containers can communicate with each other.

```
$ nomad agent -dev -bind=0.0.0.0 -network-interface=en0
```

This will bind to the `en0` interface. You can retrieve the IP address associated with it by inspecting the interface and looking at the line starting with `inet`.

```
$ ifconfig
en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	options=400<CHANNEL_IO>
	ether 88:66:5a:44:34:e8 
	inet6 fe80::c5c:1de8:d154:9341%en0 prefixlen 64 secured scopeid 0x6 
	inet 192.168.1.6 netmask 0xffffff00 broadcast 192.168.1.255
	nd6 options=201<PERFORMNUD,DAD>
	media: autoselect
	status: active
```

With the above configuration, the Nomad UI can be accessed at `192.168.1.6:4646` and the HashiCups UI can be accessed with the same IP address on port `80` by default.

See [this FAQ page](https://www.nomadproject.io/docs/faq#q-how-to-connect-to-my-host-network-when-using-docker-desktop-windows-and-macos) for more information.