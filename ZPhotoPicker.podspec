#
# Be sure to run `pod lib lint ZPhotoPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZPhotoPicker'
  s.version          = '3.0.21'
  s.summary          = 'A short description of ZPhotoPicker.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/sapphirezzz/ZPhotoPicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zackzheng' => 'zhengzuanzhe@gmail.com' }
  s.source           = { :git => 'https://github.com/sapphirezzz/ZPhotoPicker.git', :tag => s.version.to_s }
  s.social_media_url = 'https://zackzheng.info'

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'

  s.source_files = 'ZPhotoPicker/Classes/**/*'
  s.resources = ['ZPhotoPicker/Assets/images.xcassets', 'ZPhotoPicker/Assets/en.lproj/Localizable.strings', 'ZPhotoPicker/Assets/zh-Hans.lproj/Localizable.strings']

  s.frameworks = 'UIKit', 'Photos'

end
