resource "aws_s3_bucket" "frontend" {
  bucket = var.domain
  acl = "public-read"
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}
