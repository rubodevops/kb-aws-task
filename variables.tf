variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "region-master" {
  type    = string
  default = "us-east-1"
}


variable "instance-type" {
  type    = string
  default = "t2.micro"
  #  validation {
  #    condition     = can(regex("[^t2]", var.instance-type))
  #    error_message = "Instance type cannot be anything other than t2 or t3 type and also not t3a.micro."
  #  }
}


variable "database_name" {

}
variable "database_password" {



}
variable "database_user" {

}

//variable "shared_credentials_file" {

//}
