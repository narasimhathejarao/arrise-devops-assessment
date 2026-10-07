# Task 3 — Account A
resource "aws_iam_group" "group1" {
  name = "group1"
}

resource "aws_iam_user" "engine" {
  name = "engine"
}

resource "aws_iam_user" "ci" {
  name = "ci"
}

resource "aws_iam_group_membership" "group1_members" {
  name  = "group1-memberships"
  group = aws_iam_group.group1.name
  users = [aws_iam_user.engine.name, aws_iam_user.ci.name]
}

resource "aws_iam_group" "group2" {
  name = "group2"
}

resource "aws_iam_user" "alice" {
  name = "alice"
}

resource "aws_iam_user" "bob" {
  name = "bob"
}

resource "aws_iam_group_membership" "group2_members" {
  name  = "group2-memberships"
  group = aws_iam_group.group2.name
  users = [aws_iam_user.alice.name, aws_iam_user.bob.name]
}

resource "aws_iam_group_policy_attachment" "group2_admin" {
  group      = aws_iam_group.group2.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "role_a" {
  name = "roleA"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${var.account_a_id}:root" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "admin_except_iam" {
  name = "AdminExceptIAMPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
      {
        Effect   = "Deny"
        Action   = ["iam:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "role_a_attach" {
  role       = aws_iam_role.role_a.name
  policy_arn = aws_iam_policy.admin_except_iam.arn
}

resource "aws_iam_role" "role_b" {
  name = "roleB"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${var.account_a_id}:root" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "role_b_assume_role_c" {
  name = "AssumeRoleCInAccountB"
  role = aws_iam_role.role_b.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = "arn:aws:iam::${var.account_b_id}:role/roleC"
    }]
  })
}

# Task 5 Fix — Account B Role C & Trust Policy
data "aws_iam_policy_document" "roleC_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::000000000000:role/roleB"]
    }
  }
}

resource "aws_iam_role" "roleC" {
  name               = "roleC"
  assume_role_policy = data.aws_iam_policy_document.roleC_trust.json
}

resource "aws_iam_role_policy" "roleC_s3" {
  name = "roleC-s3-access"
  role = aws_iam_role.roleC.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:*"
      Resource = [
        var.s3_bucket_arn_account_b,
        "${var.s3_bucket_arn_account_b}/*"
      ]
    }]
  })
}