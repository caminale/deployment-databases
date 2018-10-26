
# Create a cluster cockroach
module "cluster-cockroach" {
  source = "./cockroach"
}

# Create an instance posgres
module "instance-postgres" {
  source = "./postgres"
}



