output "LB" {
  value = aws_lb.application-lb.arn

}

output "region" { 
  value = var.region-master }