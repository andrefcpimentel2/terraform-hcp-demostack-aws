module "eks" {
  count = var.create_eks_cluster ? 1 : 0
  source  = "./modules/eks"

  subnet_ids = aws_subnet.demostack[*].id

}