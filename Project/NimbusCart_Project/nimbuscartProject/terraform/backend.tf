terraform {
  backend "s3" {
    bucket         = "nimbuscart-tf-state-500692702174"
    key            = "nimbuscart/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "nimbuscart-tf-lock"
    encrypt        = true
  }
}
