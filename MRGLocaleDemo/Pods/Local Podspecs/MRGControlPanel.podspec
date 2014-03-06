Pod::Spec.new do |s|
  s.name     = 'MRGControlPanel'
  s.version  = '0.0.4'
  s.license  = 'BSD 3-Clause'
  s.summary  = 'Library to created backdoor control panel for your application.'
  s.homepage = 'https://github.com/mirego/MRGControlPanel'
  s.authors  = { 'Mirego' => 'info@mirego.com' }
  s.source   = { :git => 'https://github.com/mirego/MRGControlPanel.git', :tag => s.version.to_s }
  s.source_files = 'MRGControlPanel/**/*.{h,m}'
  s.requires_arc = true
  s.frameworks = 'MessageUI'

  s.platform = :ios, '7.0'
end
