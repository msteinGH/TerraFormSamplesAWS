# if no default, tf will ask for value to be entered
# variable "my_variable_input" {}

variable "region" {
    default = "us-east-1"
}

variable "availability_zone" {
    default = "us-east-1a"
}

variable "bucket_name" {
    default = "mynewbucket1234"
}

# no default asking for value on command line
#variable "bucket_name" {}

