#
# Be sure to run `pod lib lint NFSpotifyAuth.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NFSpotifyAuth'
  s.version          = '0.1.0'
  s.summary          = 'Spotify authenticator using WebOAuth Spotify API'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Spotify Authenticator using WebOAuth that won't require SDK. Authentication conforms to 'Authorization Code' which gives us accesstoken and a refresh token for spotify streaming.
                       DESC

  s.homepage         = 'https://github.com/nferocious76/NFSpotifyAuth'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Neil Francis Ramirez Hipona' => 'nferocious76@gmail.com' }
  s.source           = { :git => 'https://github.com/nferocious76/NFSpotifyAuth.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/nferocious76'

  s.ios.deployment_target = '13.0'
  s.swift_version = "5.0"
  s.source_files = 'NFSpotifyAuth/Classes/**/*'
  
  s.resource_bundles = {
    'NFSpotifyAuth' => ['NFSpotifyAuth/Assets/**/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.dependency 'Alamofire'
end
