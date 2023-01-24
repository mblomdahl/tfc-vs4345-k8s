resource "aws_route53_zone" "subdomain" {
  name = "${var.route53_subdomain}.${var.route53_apex}"

  tags = {
    Origin         = var.common_origin_tag
    ResourcePrefix = var.route53_subdomain
    Owner          = var.common_owner_tag
    Purpose        = var.common_purpose_tag
    Stack          = var.common_stack_tag
  }
}

resource "aws_route53_record" "subdomain-elb-alias" {
  zone_id = aws_route53_zone.subdomain.zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = var.eks_elb_domain
    zone_id                = var.eks_elb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "subdomain-cname" {
  zone_id = aws_route53_zone.subdomain.zone_id
  name    = "*"
  type    = "CNAME"
  ttl     = "300"
  records = [var.eks_elb_domain]
}

resource "aws_route53_record" "apex-subdomain-ns" {
  zone_id = var.route53_apex_zone_id
  name    = var.route53_subdomain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.subdomain.name_servers
}
