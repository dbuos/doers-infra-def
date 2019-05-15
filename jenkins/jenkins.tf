provider "aws" {
  region     = "us-east-1"
}



resource "aws_iam_instance_profile" "adm_inst_profile" {
  name = "adm_instance_profile"
  role = "eks-admin"
}

resource "aws_security_group" "jenkins_security_group" {
  name        = "Jenkins Security Group"
  description = "Used for Jenkins Server"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "doers_key" {
  key_name   = "doers-aws-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8OPbNoeVTCSShQWQJTV1/A+CCAQB+KpL0EzNVWAKX+TnNeeRqG2s1hx2oC+VNnR2TOzoimcgBnkF9TPtk13rddMZ1rNDFrstAGvERVNAJyu4AOyMouDVFhFYcwTfdHry71kT0uyRjz2yrGOoflLZnPqq7Jw4l4sUBIgRRnsfEMPn7Vul/GZB1z9acgU/Kyo+AMxciozS8XyWfDcsy6KSyXqtI35jVbRFJtO8z1ArH1y9stSC22ZGWdD5aV49JJWjsE9cQXIGaVjgkU0cvVIPkJPn8n2EW5hbMHknC/xXcPFDnW6DCaSjODY96ysOXnGMNRw/PcEyRiBmqneRC6SLN dbustamante@localhost.localdomain"
}

resource "aws_instance" "Build_Server" {
  ami           = "ami-035be7bafff33b6b6"
  vpc_security_group_ids = ["${aws_security_group.jenkins_security_group.id}"]
  instance_type = "t3.medium"
  iam_instance_profile = "${aws_iam_instance_profile.adm_inst_profile.name}"
  key_name = "${aws_key_pair.doers_key.key_name}"

  tags {
    Name = "Jenkins Server"
  }

  root_block_device {
    volume_size = "40"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras enable corretto8",
      "sudo yum -y install java-1.8.0-amazon-corretto-devel",	
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo yum install -y jenkins",
      "sudo yum install -y docker",
      "sudo systemctl enable docker",
      "sudo systemctl enable jenkins",
      "sudo service docker start",
      "sudo service jenkins start",
      "sudo usermod -a -G docker ec2-user",
      "sudo usermod -a -G docker jenkins",
      "sudo curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -",
      "sudo yum install -y nodejs",
      "sudo yum install -y gcc-c++ make",
      "curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo",
      "sudo yum install -y yarn",
      "sudo yum install -y zsh",
      "mkdir -p ~/.kube",
      "sudo curl --silent --location -o /usr/local/bin/kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.7/2019-03-27/bin/linux/amd64/kubectl",
      "sudo chmod +x /usr/local/bin/kubectl",
      "sudo curl --silent --location -o /usr/local/bin/aws-iam-authenticator 'https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.7/2019-03-27/bin/linux/amd64/aws-iam-authenticator'",
      "sudo chmod +x /usr/local/bin/aws-iam-authenticator",
      "sudo yum -y install jq gettext",
      "curl --silent --location 'https://github.com/weaveworks/eksctl/releases/download/latest_release/eksctl_$(uname -s)_amd64.tar.gz' | tar xz -C /tmp",
      "sudo mv -v /tmp/eksctl /usr/local/bin",
      "eksctl version",
      "sudo yum install -y git"
    ]
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.Build_Server.public_ip}"
  }

}

