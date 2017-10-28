Pod::Spec.new do |s|
  s.name             = 'HearthAssets'
  s.version          = '0.0.1'
  s.license          = 'MIT'
  s.summary          = 'Assets from Hearthstone'
  s.homepage         = 'https://github.com/HearthSim/HearthAssets'
  s.authors          = { 'Benjamin Michotte' => 'bmichotte@gmail.com', 'Istvan Fehervari' => 'gooksl@gmail.com' }
  s.source           = { :git => 'https://github.com/HearthSim/HearthAssets.git' }

  s.osx.deployment_target     = '10.10'

  s.ios.framework = 'Foundation'

  s.source_files = 'Sources/**/*.swift'
  s.requires_arc = true
end
