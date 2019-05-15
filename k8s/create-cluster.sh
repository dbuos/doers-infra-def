eksctl create cluster --name=doers-cluster --node-type=t3.medium --nodes-min=1 --nodes-max=10 --ssh-access --ssh-public-key=doers-aws-key --region=us-east-1 --asg-access
