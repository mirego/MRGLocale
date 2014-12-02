Pod::Spec.new do |s|
  s.name     = 'MRGLocale'
  s.version  = ‘0.2.0’
  s.license  = 'BSD 3-Clause'
  s.summary  = 'Easily manage your localizations by adding dynamic (remote) refs to be able to update them without an app update'
  s.homepage = 'https://github.com/mirego/MRGLocale'
  s.authors  = { 'Mirego' => 'info@mirego.com' }
  s.source   = { :git => 'https://github.com/mirego/MRGLocale.git', :tag => s.version.to_s }
  s.source_files = 'MRGLocale/*.{h,m}'
  s.requires_arc = true
  s.ios.deployment_target = '5.0'
  
  s.dependency 'MRGControlPanel', '~> 0.0.4'
end

