# -----------------------------------------------------------------------------
# VPC module
# - 1 VPC
# - N public subnets (1 per AZ) — for the ALB and the single NAT Gateway
# - N private subnets (1 per AZ) — for EKS nodes/pods and RDS
# - Single NAT Gateway (cost guardrail — not one per AZ)
# - Subnet tags required for EKS + AWS Load Balancer Controller auto-discovery
# -----------------------------------------------------------------------------
locals {
  az_count = length(var.azs)
  # /20s carved out of the /16 VPC CIDR: public subnets first, then private.
  public_subnet_cidrs  = [for i in range(local.az_count) : cidrsubnet(var.cidr_block, 4, i)]
  private_subnet_cidrs = [for i in range(local.az_count) : cidrsubnet(var.cidr_block, 4, i + 8)]
}
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.name
  }
}
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-igw"
  }
}
# ---- Public subnets ---------------------------------------------------------
resource "aws_subnet" "public" {
  count                   = local.az_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name                                        = "${var.name}-public-${var.azs[count.index]}"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "${var.name}-public-rt"
  }
}
resource "aws_route_table_association" "public" {
  count          = local.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---- Single NAT Gateway (cost guardrail) ------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.name}-nat-eip"
  }
}
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # single NAT in the first public subnet
  tags = {
    Name = "${var.name}-nat"
  }
  depends_on = [aws_internet_gateway.this]
}
# ---- Private subnets ---------------------------------------------------------
resource "aws_subnet" "private" {
  count             = local.az_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = {
    Name                                        = "${var.name}-private-${var.azs[count.index]}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
# All private subnets share one route table pointing at the single NAT GW.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = {
    Name = "${var.name}-private-rt"
  }
}
resource "aws_route_table_association" "private" {
  count          = local.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}