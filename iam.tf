data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role" "ecsInstanceRole_tmp" {
  name = "ecsInstanceRole_tmp"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecsInstanceRole_tmp" {
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn
  role = aws_iam_role.ecsInstanceRole_tmp.name
}

resource "aws_iam_instance_profile" "ecsInstanceRole_tmp" {
  role = aws_iam_role.ecsInstanceRole_tmp.name
}

