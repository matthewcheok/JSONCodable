Pod::Spec.new do |s|
  s.name = 'JSONCodable'
  s.version = '3.0.1'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'Hassle-free JSON encoding and decoding in Swift'
  s.homepage = 'https://github.com/matthewcheok/JSONCodable'
  s.authors = { 'Matthew Cheok' => 'hello@matthewcheok.com' }
  s.source = { :git => 'https://github.com/matthewcheok/JSONCodable.git', :tag => s.version }
  s.source_files = 'JSONCodable/*.swift'
  s.requires_arc = true
end
