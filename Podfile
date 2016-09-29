platform :ios, '9.0'

target 'Infinity' do
  use_frameworks!

  pod 'Alamofire', '~> 3.5.0'
  pod 'AlamofireImage', '~> 2.5.0'
  pod 'AlamofireObjectMapper', '~> 3.0.2'

  target 'InfinityTests' do
    inherit! :search_paths
    pod 'Quick'
    pod 'Nimble'
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
