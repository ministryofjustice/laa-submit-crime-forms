require 'aws-sdk-s3'

Aws.config.update({
                    region: ENV.fetch('AWS_REGION', nil),
                    credentials: Aws::Credentials.new(ENV.fetch('AWS_ACCESS_KEY_ID', nil), ENV.fetch('AWS_SECRET_ACCESS_KEY', nil))
                  })

S3_BUCKET = Aws::S3::Resource.new.bucket(ENV.fetch('S3_BUCKET', nil))