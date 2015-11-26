Pod::Spec.new do |s|
  s.name     = 'MRGLocale'
  s.version  = '0.2.6'
  s.license  = 'BSD 3-Clause'
  s.summary  = 'Easily manage your localizations by adding dynamic (remote) refs to be able to update them without an app update'
  s.homepage = 'https://github.com/mirego/MRGLocale'
  s.authors  = { 'Mirego' => 'info@mirego.com' }
  s.source   = { :git => 'git@github.com:mirego/MRGLocale.git', :tag => s.version.to_s }
  s.requires_arc = true
  s.ios.deployment_target = '6.0'

  s.default_subspecs = 'Core', 'ControlPanel'

  s.subspec 'Core' do |sp|
    sp.source_files = 'MRGLocale/*.{h,m}'
  end
  
  s.subspec 'ControlPanel' do |sp|
    sp.ios.deployment_target = '6.0'
    sp.dependency 'MRGLocale/Core'
    sp.dependency 'MRGControlPanel', '~> 0.0.7'
    sp.source_files = 'MRGLocale/ControlPanel/*.{h,m}'
  end
end
