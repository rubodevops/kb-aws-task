output "Lamp-Main-Node-Public-IP" {
  value = aws_instance.wordpress-instance.public_ip


}

output "region" { value = var.region-master }











/*output "amiId-us-east-1" {
  value     = data.aws_ami.ubuntu.id
  sensitive = false
}*/


output "LB-DNS-NAME" {
  value = aws_lb.application-lb.dns_name
}