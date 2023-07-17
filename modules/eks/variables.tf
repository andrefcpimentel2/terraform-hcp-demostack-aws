variable "cluster_name" {
  type        = string
  default     = "demostack"

}

variable "subnet_ids" {
  type    = list(string)
  description = "Subnet Ids - list"
}