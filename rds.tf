resource "aws_db_instance" "drupal_db" {
identifier= "drupal-db-instance"
allocated_storage= 20
max_allocated_storage = 100
storage_type= "gp2"
engine= "mysql"
engine_version= "5.7"
instance_class= "db.t2.micro"
username= "db_user"
password= "db_password"
vpc_security_group_ids = [aws_security_group.drupal_sg.id]
parameter_group_name= "default.mysql5.7"
publicly_accessible= true
multi_az= false
backup_retention_period = 7
skip_final_snapshot= true

tags = {
Name = "drupal_db"
}
}

variable  "database_config" {
    default = {
    default = {
  "database" = "drupal_db",
  "username" = "db_user",
  "password" = "db_password",
  "host" = "drupal_db.endpoint",
  "port" = "3306",
  "driver" = "mysql",
  "prefix" = "",
  "collation" = "utf8mb4_general_ci",
}
    }
}