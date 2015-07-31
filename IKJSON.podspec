Pod::Spec.new do |spec|
  spec.name         = 'IKJSON'
  spec.version      = '1.1.2'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/iankeen/'
  spec.authors      = { 'Ian Keen' => 'iankeen82@gmail.com' }
  spec.summary      = 'Library for handling serialization and deserialization between JSON and PONSOs and NSManagedObjects.'
  spec.source       = { :git => 'https://github.com/iankeen/ikjson.git', :tag => spec.version.to_s }

  spec.source_files = 'IKJSON/**/**.{h,m}'
  
  spec.requires_arc = true
  spec.platform     = :ios
  spec.ios.deployment_target = "7.0"

  spec.dependency 'IKCore', '~> 1.0'
  spec.dependency 'IKResults', '~> 1.0'
  spec.dependency 'ISO8601'
end
