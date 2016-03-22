Pod::Spec.new do |s|
  s.name         = "mailgun"
  s.version      = "1.1"
  s.summary      = "The Mailgun SDK allows your Mac OS X or iOS application to connect with the programmable email platform."
  s.homepage     = "https://github.com/KomodoHQ/objc-mailgun"
  s.license      = 'MIT'
  s.author       = { "Jay Baird" => "jay.baird@rackspace.com" }
  s.source       = { :git => "https://github.com/KomodoHQ/objc-mailgun", :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.source_files = 'Classes', 'Classes/*.{h,m}'
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 3.0.4'
end
