data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_secretsmanager_secret" "orders_db" {
  name        = "orders/db-credentials"
  description = "Database credentials for the orders API."

  recovery_window_in_days = 0
  tags                    = local.tags
}

# Team roles

# Team A's role trust policy -> Allow ESO Controller role to perform sts:AssumeRole
# Team B's role trust policy -> Allow ESO Controller role to perform sts:AssumeRole
# Team X's role trust policy -> Allow ESO Controller role to perform sts:AssumeRole

data "aws_iam_policy_document" "eso_team_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.eso.arn]
    }
  }
}

resource "aws_iam_role" "eso_team" {
  for_each = local.eso_teams

  name               = "${var.cluster_name}-${each.value}-secrets"
  assume_role_policy = data.aws_iam_policy_document.eso_team_trust.json
  tags               = local.tags
}

data "aws_iam_policy_document" "eso_team_read" {
  for_each = local.eso_teams

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:${each.value}/*"]
  }
}

resource "aws_iam_policy" "eso_team_read" {
  for_each = local.eso_teams

  name        = "read-${each.value}-secrets"
  description = "Read the secrets under path '${each.value}/*'"
  policy      = data.aws_iam_policy_document.eso_team_read[each.value].json
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "eso_team_read" {
  for_each = aws_iam_role.eso_team

  role       = each.value.name
  policy_arn = aws_iam_policy.eso_team_read[each.key].arn
}

# ESO Controller role

data "aws_iam_policy_document" "eso_assume_team_roles" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole", "sts:TagSession"]
    resources = values(aws_iam_role.eso_team)[*].arn
  }
}

resource "aws_iam_policy" "eso_assume_team_roles" {
  name        = "eso-assume-team-roles"
  description = "Assume team roles for secrets access."
  policy      = data.aws_iam_policy_document.eso_assume_team_roles.json
  tags        = local.tags
}

data "aws_iam_policy_document" "eso_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eso" {
  name               = "${var.cluster_name}-external-secrets"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "eso_read_orders_db" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.eso_assume_team_roles.arn
}

resource "aws_eks_pod_identity_association" "eso" {
  cluster_name    = module.cluster.cluster_name
  namespace       = "external-secrets"
  service_account = "external-secrets"
  role_arn        = aws_iam_role.eso.arn
  tags            = local.tags
}