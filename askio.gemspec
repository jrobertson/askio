Gem::Specification.new do |s|
  s.name = 'askio'
  s.version = '0.1.0'
  s.summary = 'Interacts with an HTTP service used to respond to an Amazon Alexa Skill request.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/askio.rb']
  s.signing_key = '../privatekeys/askio.pem'
  s.add_runtime_dependency('rest-client', '~> 2.0', '>=2.0.2')
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/askio'
end
