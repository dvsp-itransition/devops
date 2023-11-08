
# terraform{
#   backend "s3" {
#     bucket = "dvsp-tf-state-s3-backet" # state file in s3 bucket
#     key = "terraform.tfstate"
#     region = "us-east-2"        
#     dynamodb_table = "dvsp-dynomodb-state-locking" # state lock implementation    
#   }
# }

# S3 backet
resource "aws_s3_bucket" "tf_state_backet" {

  bucket = "dvsp-tf-state-s3-backet"
  tags = {
    Name = "dvsp-tf-state-s3-backet"
  }
}

resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.tf_state_backet.id

  versioning_configuration {
    status = "Enabled"
  }
}

# dynamo db | enables state lock
resource "aws_dynamodb_table" "dvsp-dynomodb-state-locking" {
  name         = "dvsp-dynomodb-state-locking"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

