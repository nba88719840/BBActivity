#
# Be sure to run `pod lib lint BBActivity.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BBActivity'
  s.version          = '0.1.9'
  s.summary          = 'BBActivity is an Activity component'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/nba88719840/BBActivity'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nba88719840' => '1009105480@qq.com' }
  s.source           = { :git => 'https://github.com/nba88719840/BBActivity.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.swift_version = '5.9'
  s.ios.deployment_target = '13.0'

  s.source_files = 'BBActivity/Classes/**/*'
  
  s.xcconfig = { 'ARCHS' => '$(ARCHS_STANDARD)' }
  
  # s.resource_bundles = {
  #   'BBActivity' => ['BBActivity/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SnapKit'
  s.dependency 'ActiveLabel'
  s.dependency 'JXSegmentedView'
  s.dependency 'JXPagingView/Paging'
#  s.dependency 'JXPhotoBrowser'
#  s.dependency 'RxSwift'
#  s.dependency 'RxCocoa'
  s.dependency 'RxBlocking'
end
