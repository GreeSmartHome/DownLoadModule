#
# Be sure to run `pod lib lint DownLoadModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DownLoadModule'
  s.version          = '0.1.1'
  s.summary          = '下载库组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
这是一个可以单任务和多任务一起下载的下载器组件
                       DESC

  s.homepage         = 'https://gitee.com/luojiya/DownLoadModule'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '1049646716@qq.com' => '1049646716@qq.com' }
  s.source           = { :git => 'https://gitee.com/luojiya/DownLoadModule.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  #s.source_files = 'DownLoadModule/Classes/**/*'
  s.vendored_frameworks = 'DownLoadModule/Framework/DownLoadModule.framework'
  # s.resource_bundles = {
  #   'DownLoadModule' => ['DownLoadModule/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
