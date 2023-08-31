if Rails.env.production?
  Aws.config.update({
                      region: ENV.fetch('AWS_REGION', 'eu-west-2'),
                      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY']),
                    })

  S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])
end

if Rails.env.test?
  Aws.config.update(stub_responses: true)
  S3_BUCKET = Aws::S3::Resource.new.bucket('test')
end