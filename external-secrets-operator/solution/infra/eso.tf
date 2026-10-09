resource "aws_secretsmanager_secret" "orders_db" {
  name        = "orders/db-credentials"
  description = "Database credentials for the orders API."

  recovery_window_in_days = 0
  tags                    = local.tags
}

data "aws_iam_policy_document" "eso_read_orders_db" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.orders_db.arn]
  }
}

resource "aws_iam_policy" "eso_read_orders_db" {
  name        = "${var.cluster_name}-eso-read-orders-db"
  description = "Read the orders database credentials from Secrets Manager."
  policy      = data.aws_iam_policy_document.eso_read_orders_db.json
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
  policy_arn = aws_iam_policy.eso_read_orders_db.arn
}

resource "aws_eks_pod_identity_association" "eso" {
  cluster_name    = module.cluster.cluster_name
  namespace       = "external-secrets"
  service_account = "external-secrets"
  role_arn        = aws_iam_role.eso.arn
  tags            = local.tags
}