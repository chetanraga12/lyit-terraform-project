#Docker provider
provider "docker" {
  host = "tcp://127.0.0.1:2376/"
}

#Docker network
resource "docker_network" "private_network" {
  name = "dbnet"
  driver = "bridge"
  subnet = "192.168.0.0/16"
}

#iptables
resource "docker_image" "iptables" {
  name = "paulczar/iptables:latest"
}

resource "docker_image" "iptables" {
  name = "firewall"
  image = "${docker_image.iptables.latest}"
  restart = "always"
  network = "host"
  env {
    TCP_PORTS = 8080, 3306
    HOSTS = "192.168.0.0/16"
  }
  capabilities {
    add = "NET_ADMIN"
  }

}

#MySQL
resource "docker_image" "mysql-server" {
  name = "mysql-server:latest"
}

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

#phpmyadmin
  name = "phpmyadmin:latest"
}

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
