# for githubactions oidc provider
resource "aws_iam_openid_connect_provider" "githubactions" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}

# for githubactions iam role
resource "aws_iam_role" "githubactions" {
  name = "${var.sys_name}-${var.env_name}-githubactions"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/${var.github_repo}:*"
          }
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "githubactions_admin" {
  role       = aws_iam_role.githubactions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

#trivy:ignore:AVD-AWS-0057
resource "aws_iam_policy" "githubactions_passrole" {
  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
       "Effect": "Allow",
       "Action": [
            "iam:PassRole"
       ],
      "Resource": "*"
      }
   ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "githubactions_passrole" {
  role       = aws_iam_role.githubactions.name
  policy_arn = aws_iam_policy.githubactions_passrole.arn
}
