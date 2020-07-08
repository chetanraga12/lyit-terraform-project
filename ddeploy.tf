#Docker provider
provider "docker" {
  host = "tcp://127.0.0.1:2376/"
}

#Docker images
resource "docker_image" "iptables" {
  name = "paulczar/iptables:master"
}

resource "docker_image" "mysql-server" {
  name = "mysql-server:latest"
}

resource "docker_image" "phpmyadmin" {
  name = "phpmyadmin:latest"
}

#Docker network
resource "docker_network" "private_network" {
  name = "dbnet"
  driver = "bridge"
  options = "com.docker.network.bridge.name=dbnet"
  subnet = "172.20.0.0/16"
}

#iptables - Alpine Linux-based firewall container
resource "docker_container" "iptables" {
  name = "firewall"
  image = "${docker_image.iptables.master}"
  restart = "always"
  network = "host"
  env {
    TCP_PORTS = "8080,3306"
    HOSTS = "172.20.0.0/16"
  }
  capabilities {
    add = "NET_ADMIN"
  }
  command = ["/bin/ash", "iptables -A INPUT -i dbnet -j ACCEPT"]
}

#MySQL Server- database server container
resource "docker_container" "mysql-server" {
  name = "mysql_server"
  image = "${docker_image.mysql-server.latest}"
  restart = "always"
  network = "dbnet"
  env {
    MYSQL_ROOT_HOST = "%"
    MYSQL_DATABASE = "db"
    MYSQL_ROOT_PASSWORD = "root"
    MYSQL_USER = "user1"
    MYSQL_PASSWORD = "user1pass"
  }
  mounts {
    source = "mysql_db"
    target = "/var/lib/mysql"
    type = "volume"
  }
  ports {
    internal = 3306
    external = 3306
  }
}

#phpMyAdmin - php-based web-accessible database frontend container
resource "docker_container" "phpmyadmin" {
  name = "php_admin"
  image = "${docker_image.phpmyadmin.latest}"
  restart = "always"
  network = "dbnet"
  env {
    PMA_HOST = "mysql_server"
  }
  ports {
      internal = 8080
      external = 80
  }
}  
