job "hashicups" {
  type   = "service"
  region = "[[ .hashicups.region ]]"
  datacenters = [[ .hashicups.datacenters | toStringList ]]
  node_pool = [[ var "node_pool" . | quote ]]

  group "hashicups" {
    network {
      port "db" { 
        static = 5432
      }
      port "product-api" {
        static = [[ .hashicups.product_api_port ]]
      }
      port "frontend" {
        static = [[ .hashicups.frontend_port ]]
      }
      port "payments-api" {
        static = [[ .hashicups.payments_api_port ]]
      }
      port "public-api" {
        static = [[ .hashicups.public_api_port ]]
      }
      port "nginx" {
        static = [[ .hashicups.nginx_port ]]
      }
    }

    task "db" {
      driver = "docker"
      meta {
        service = "database"
      }
      config {
        image   = "hashicorpdemoapp/product-api-db:[[ .hashicups.product_api_db_version ]]"
        ports = ["db"]
      }
      env {
        POSTGRES_DB       = "[[ .hashicups.postgres_db ]]"
        POSTGRES_USER     = "[[ .hashicups.postgres_user ]]"
        POSTGRES_PASSWORD = "[[ .hashicups.postgres_password ]]"
      }
    }

    task "product-api" {
      driver = "docker"
      meta {
        service = "product-api"
      }
      config {
        image   = "hashicorpdemoapp/product-api:[[ .hashicups.product_api_version ]]"
        ports = ["product-api"]
      }
      env {
        DB_CONNECTION = "host=${NOMAD_IP_db} port=${NOMAD_PORT_db} user=[[ .hashicups.postgres_user ]] password=[[ .hashicups.postgres_password ]] dbname=[[ .hashicups.postgres_db ]] sslmode=disable"
        BIND_ADDRESS = "0.0.0.0:${NOMAD_PORT_product-api}"
      }
    }

    task "payments-api" {
      driver = "docker"
      meta {
        service = "payments-api"
      }
      config {
        image   = "hashicorpdemoapp/payments:[[ .hashicups.payments_version ]]"
        ports = ["payments-api"]
        mount {
          type   = "bind"
          source = "local/application.properties"
          target = "/application.properties"
        }
      }
      template {
        data = <<EOF
server.port={{ env "NOMAD_PORT_payments-api" }}
        EOF
        destination = "local/application.properties"
      }
    }
    
    task "public-api" {
      driver = "docker"
      meta {
        service = "public-api"
      }
      config {
        image   = "hashicorpdemoapp/public-api:[[ .hashicups.public_api_version ]]"
        ports = ["public-api"]
      }
      env {
        BIND_ADDRESS = ":${NOMAD_PORT_public-api}"
        PRODUCT_API_URI = "http://${NOMAD_ADDR_product-api}"
        PAYMENT_API_URI = "http://${NOMAD_ADDR_payments-api}"
      }
    }
    
    task "frontend" {
      driver = "docker"
      meta {
        service = "frontend"
      }
      env {
        NEXT_PUBLIC_PUBLIC_API_URL= "/"
        PORT = "${NOMAD_PORT_frontend}"
      }
      config {
        image   = "hashicorpdemoapp/frontend:[[ .hashicups.frontend_version ]]"
        ports = ["frontend"]
      }
    }

    task "nginx" {
      driver = "docker"
      meta {
        service = "nginx-reverse-proxy"
      }
      config {
        image = "nginx:alpine"
        ports = ["nginx"]
        mount {
          type   = "bind"
          source = "local/default.conf"
          target = "/etc/nginx/conf.d/default.conf"
        }
      }
      template {
        data =  <<EOF
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=STATIC:10m inactive=7d use_temp_path=off;
upstream frontend_upstream {
  server {{ env "NOMAD_IP_frontend" }}:[[ .hashicups.frontend_port ]];
}
server {
  listen {{ env "NOMAD_PORT_nginx" }};
  server_name  {{ env "NOMAD_IP_nginx" }};
  server_tokens off;
  gzip on;
  gzip_proxied any;
  gzip_comp_level 4;
  gzip_types text/css application/javascript image/svg+xml;
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection 'upgrade';
  proxy_set_header Host $host;
  proxy_cache_bypass $http_upgrade;
  location /_next/static {
    proxy_cache STATIC;
    proxy_pass http://frontend_upstream;
    # For testing cache - remove before deploying to production
    add_header X-Cache-Status $upstream_cache_status;
  }
  location /static {
    proxy_cache STATIC;
    proxy_ignore_headers Cache-Control;
    proxy_cache_valid 60m;
    proxy_pass http://frontend_upstream;
    # For testing cache - remove before deploying to production
    add_header X-Cache-Status $upstream_cache_status;
  }
  location / {
    proxy_pass http://frontend_upstream;
  }
  location /api {
    proxy_pass http://{{ env "NOMAD_IP_frontend" }}:[[ .hashicups.public_api_port ]];
  }
}
        EOF
        destination = "local/default.conf"
      }
    }
  }
}
