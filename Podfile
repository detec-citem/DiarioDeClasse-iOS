platform :ios, '9.0'

inhibit_all_warnings!

use_frameworks!

target 'SEDProfessor' do
    pod 'BetterSegmentedControl', '0.8'
    pod 'Cosmos'
    pod 'Crashlytics'
    pod 'Fabric'
    pod 'Firebase/Core'
    pod 'FSCalendar'
    pod 'GMStepper'
    pod 'IQKeyboardManagerSwift'
    pod 'MBProgressHUD'
    pod 'MZFormSheetPresentationController'
    pod 'Reachability'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'YES'
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
            config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
            if target.name == 'BetterSegmentedControl'
                config.build_settings['SWIFT_VERSION'] = '4.0'
            else
                config.build_settings['SWIFT_VERSION'] = '5.1'
            end
            if config.name == 'Release'
                config.build_settings['ASSETCATALOG_COMPILER_OPTIMIZATION'] = 'space'
                config.build_settings['GCC_FAST_MATH'] = 'YES'
                config.build_settings['GCC_OPTIMIZATION_LEVEL'] = 's'
                config.build_settings['LLVM_LTO'] = 'YES'
                config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Osize'
            else
                config.build_settings['ASSETCATALOG_COMPILER_OPTIMIZATION'] = ''
                config.build_settings['GCC_FAST_MATH'] = 'NO'
                config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '0'
                config.build_settings['LLVM_LTO'] = 'YES_THIN'
                config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
            end
        end
    end
end
