Pod::Spec.new do |s|
  s.name     = 'MRGLocale'
  s.version  = '0.3.0'
  s.license  = 'BSD 3-Clause'
  s.summary  = 'Easily manage your localizations by adding dynamic (remote) refs to be able to update them without an app update'
  s.homepage = 'https://github.com/mirego/MRGLocale'
  s.authors  = { 'Mirego' => 'info@mirego.com' }
  s.source   = { :git => 'https://github.com/mirego/MRGLocale.git', :tag => s.version.to_s }
  s.requires_arc = true
  s.swift_version = '5.0'
  s.ios.deployment_target = '12.0'

  s.default_subspecs = 'Core', 'ControlPanel'

  s.subspec 'Core' do |sp|
    sp.source_files = 'Sources/MRGLocale/*.{h,m}', 'Sources/MRGLocaleSwift/*.swift'
  end

  s.subspec 'ControlPanel' do |sp|
    sp.dependency 'MRGLocale/Core'
    sp.dependency 'MRGControlPanel', '~> 0.1.2'
    sp.source_files = 'Sources/MRGLocaleControlPanel/*.{h,m}'
  end
end
