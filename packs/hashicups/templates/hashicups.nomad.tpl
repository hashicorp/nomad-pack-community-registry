job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]

  type = "service"

  group "hashicups" {
    network {
      port "db" { 
        static = 5432
      }
      port "product-api" {
        static = [[ var "product_api_port" . ]]
      }
      port "frontend" {
        static = [[ var "frontend_port" . ]]
      }
      port "payments-api" {
        static = [[ var "payments_api_port" . ]]
      }
      port "public-api" {
        static = [[ var "public_api_port" . ]]
      }
      port "nginx" {
        static = [[ var "nginx_port" . ]]
      }
    }

    task "db" {
      driver = "docker"
      meta {
        service = "database"
      }
      config {
        image = "hashicorpdemoapp/product-api-db:[[ var "product_api_db_version" . ]]"
        ports = ["db"]
      }
      env {
        POSTGRES_DB       = [[ var "postgres_db" . | quote ]]
        POSTGRES_USER     = [[ var "postgres_user" . | quote ]]
        POSTGRES_PASSWORD = [[ var "postgres_password" . | quote ]]
      }
    }

    task "product-api" {
      driver = "docker"
      meta {
        service = "product-api"
      }
      config {
        image = "hashicorpdemoapp/product-api:[[ var "product_api_version" . ]]"
        ports = ["product-api"]
      }
      env {
        DB_CONNECTION = "host=${NOMAD_IP_db} port=${NOMAD_PORT_db} user=[[ var "postgres_user" . ]] password=[[ var "postgres_password" . ]] dbname=[[ var "postgres_db" . ]] sslmode=disable"
        BIND_ADDRESS  = "0.0.0.0:${NOMAD_PORT_product-api}"
      }
    }

    task "payments-api" {
      driver = "docker"
      meta {
        service = "payments-api"
      }
      config {
        image = "hashicorpdemoapp/payments:[[ var "payments_version" . ]]"
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
        image = "hashicorpdemoapp/public-api:[[ var "public_api_version" . ]]"
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
        NEXT_PUBLIC_PUBLIC_API_URL = "/"
        PORT = "${NOMAD_PORT_frontend}"
      }
      config {
        image = "hashicorpdemoapp/frontend:[[ var "frontend_version" . ]]"
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
  server {{ env "NOMAD_IP_frontend" }}:[[ var "frontend_port" . ]];
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
    proxy_pass http://{{ env "NOMAD_IP_frontend" }}:[[ var "public_api_port" . ]];
  }
}
        EOF
        destination = "local/default.conf"
      }
    }
  }
}
