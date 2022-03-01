#security group for ec2_pool

resource "aws_security_group" "ec2_pool" {

  provider    = aws.region-master
  vpc_id      = aws_vpc.cloudx.id
  description = "allows access for ec2 instances"



  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    from_port       = 2368
    to_port         = 2368
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.external_ip]
  }

  tags = {
    Name = "ec2_pool"
  }
}






#security group for fargate_pool

resource "aws_security_group" "fargate_pool" {

  provider    = aws.region-master
  vpc_id      = aws_vpc.cloudx.id
  description = "allows access for fargate instances"



  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  ingress {
    from_port       = 2368
    to_port         = 2368
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.external_ip]
  }

  tags = {
    Name = "fargate_pool"
  }
}


#security group for mysql

resource "aws_security_group" "mysql" {

  provider    = aws.region-master
  vpc_id      = aws_vpc.cloudx.id
  description = "defines access to ghost db"



  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ec2_pool.id}"]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.fargate_pool.id}"]
  }

  tags = {
    Name = "mysql"
  }
}



#security group for efs

resource "aws_security_group" "efs" {

  provider    = aws.region-master
  vpc_id      = aws_vpc.cloudx.id
  description = "defines access to efs mount points"



  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${aws_security_group.fargate_pool.id}"]
  }

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ec2_pool.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.10.0.0/16"]
  }

  tags = {
    Name = "efs"
  }
}




#security group for alb

resource "aws_security_group" "alb" {

  provider    = aws.region-master
  vpc_id      = aws_vpc.cloudx.id
  description = "defines access to alb"



  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.external_ip]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.ec2_pool.id}"]
  }



  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.fargate_pool.id}"]
  }

  tags = {
    Name = "alb"
  }
}







#security group for vpc-endpoint

resource "aws_security_group" "vpc_endpoint" {

  provider    = aws.region-master
  vpc_id      = aws_vpc.cloudx.id
  description = "defines access to vpc endpoints"



  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"]
  }

  tags = {
    Name = "vpc_endpoint"
  }
}










































































