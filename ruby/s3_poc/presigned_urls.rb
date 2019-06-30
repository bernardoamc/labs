require 'aws-sdk'
require 'openssl'

bucket_name = 'private-request-bucket'
object_key = 'cognitive_bias.jpeg'
region = 'us-east-1'

Aws.config[:region] = region
Aws.config[:credentials] = Aws::Credentials.new('xyz', 'abc')

resource = Aws::S3::Resource.new
obj = Aws::S3::Object.new(bucket_name, object_key)
puts obj.presigned_url(:get, expires_in: 3600)
