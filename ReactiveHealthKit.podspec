Pod::Spec.new do |s|
  s.name             = "ReactiveHealthKit"
  s.version          = "0.1.1"
  s.summary          = "ReactiveCocoa extensions for HealthKit"
  s.homepage         = "https://github.com/kerryknight/ReactiveHealthKit"
  s.license          = 'MIT'
  s.author           = { "Kerry Knight" => "kerry.a.knight@gmail.com" }
  s.source           = { :git => "https://github.com/kerryknight/ReactiveHealthKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/KerryAKnight'

  s.ios.deployment_target = '8.0'
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'ReactiveHealthKit'

  s.dependency 'ReactiveCocoa', '~> 2.1'
end
