terraform {
backend "s3" {
   bucket  = "fin-project-bucket"
   key     = "terraform.tfstate"
   region  = "us-east-1"
  #  encrypt = true
  }
}


