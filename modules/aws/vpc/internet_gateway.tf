################################################################################
# AWS Internet Gateway Resource
################################################################################

resource "aws_internet_gateway" "this" {
  count = var.create_igw ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    var.igw_tags,
    {
      Name = coalesce(var.igw_name, "${var.name}-igw")
    }
  )

  dynamic "timeouts" {
    for_each = var.igw_timeouts != null ? [var.igw_timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }
}
