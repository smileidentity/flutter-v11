# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint smileid.podspec` to validate before publishing.
#
package = YAML.load_file('../pubspec.yaml')
Pod::Spec.new do |s|
  s.name = 'smile_id'
  s.version = package["version"]
  s.summary = 'Official Smile ID SDK for Flutter'
  s.description = package["description"]
  s.homepage = package["homepage"]
  s.author = { 'Smile ID' => 'support@usesmileid.com' }
  s.source = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'SmileID', '11.1.7'
  # for development alongside sample/ios/Podfile uncomment the version and specify
  # tag or branch in sample/ios/Podfile
  # s.dependency "SmileID"
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'GCC_PREPROCESSOR_DEFINITIONS' => "SMILE_ID_VERSION=\\\"#{package["version"]}\\\""
  }
  s.swift_version = '5.0'
end
