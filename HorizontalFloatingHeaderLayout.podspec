#
# Be sure to run `pod lib lint HorizontalFloatingHeaderLayout.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "HorizontalFloatingHeaderLayout"
  s.version          = "1.0.0"
  s.summary          = "Floating headers with horizontal scrolling layout for UICollectionView, inspired by iOS native Emoji Keyboard layout"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  HorizontalFLoatingHeaderLayout is a subclass of UICollectionViewLayout built with performance in mind. Born from the need for replicating UITableView's sticky headers behavior and iOS 8+ native Emoji keyboard.

For a vertical implementation, you can turn on *sectionHeadersPinToVisibleBounds* flag from UICollectionViewFlowLayout (available since iOS 9.0)
                       DESC

  s.homepage         = "https://github.com/cruzdiego/HorizontalFloatingHeaderLayout"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Diego Cruz" => "diego.cruz@icloud.com" }
  s.source           = { :git => "https://github.com/cruzdiego/HorizontalFloatingHeaderLayout.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'HorizontalFloatingHeaderLayout' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
