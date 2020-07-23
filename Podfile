source 'https://github.com/cosmos33/MMSpecs.git'
source 'https://cdn.cocoapods.org/'


use_frameworks!

platform :ios, '10.0'

target 'MMBeautyKitDemo' do

  #pod 'MMBeautyKit', :path => '../MMBeautyKit-iOS'
  #pod 'MMBeautyMedia', :path => '../MMBeautyMedia-iOS'
  pod 'MMBeautyKit', '1.1.0'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|

        target.build_configurations.each do |config|
            config.build_settings['PROVISIONING_PROFILE'] = ''
            config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
            config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
        end
    end
end
