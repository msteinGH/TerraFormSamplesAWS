

# create an S3 bucket 
resource "aws_s3_bucket" "tf-my-first-aws-s3-bucket" {
  bucket = "${var.bucket_name}"
  tags = {
    Name = "${var.bucket_name}"
  }
}


## acl sometimes not allowed when using OReilly

resource "aws_s3_bucket_acl" "tf-my-first-aws_s3_bucket_acl" {
  bucket = aws_s3_bucket.tf-my-first-aws-s3-bucket.id
  # acl    = "private"
  # acl    = "public-read"
}

# Upload test file to S3 bucket
resource "aws_s3_object" "tf-generically-uploaded-file" {

  bucket = aws_s3_bucket.tf-my-first-aws-s3-bucket.id
  key    = "S3BucketTestFile.txt"
  # acl    = "private"
  # acl    = "public-read" 
   source = "SampleData/S3BucketTestFile.txt"

  etag = filemd5("SampleData/S3BucketTestFile.txt")

}

# create empty folder in S3 bucket
resource "aws_s3_object" "tf-my-test-upload-folder-name" {
    provider = aws
    bucket = aws_s3_bucket.tf-my-first-aws-s3-bucket.id
    # acl    = "public-read" 
    key    = "tf-my-test-upload-folder-name/"
    # content_type seemingly irrelevant 
    # trailing "/" seems to be sole indicator to create a folder
    # content_type = "application/x-directory"
}

# create folder and upload files into it in one go
resource "aws_s3_object" "tf-my-test-upload-folder-name-incl-files" {
for_each = fileset("SampleData/TestFilesForUpload/", "*")
bucket = aws_s3_bucket.tf-my-first-aws-s3-bucket.id
key    = "tf-my-test-upload-folder-name-incl-files/${each.value}"
source = "SampleData/TestFilesForUpload/${each.value}"

etag = filemd5("SampleData/TestFilesForUpload/${each.value}")
}

