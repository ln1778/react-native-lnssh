require "json"
version = JSON.parse(File.read("package.json"))["version"]

Pod::Spec.new do |s|
  s.name         = "Lnssh"
  s.version      = version
  s.description  = "Provide I18n to your React Native application"
  s.homepage     = "https://github.com/ln1778/react-native-lnssh"
  s.summary      = "React Native + i18n.js"
  s.license      = "MIT"
  s.author       = { "ln1778" => "465410291@qq.com" }
  s.ios.deployment_target = "11.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { git: "https://github.com/ln1778/react-native-lnssh.git", tag: "v" + s.version.to_s }
  s.source_files = "ios/**/*.{h,m}"
  s.requires_arc = true
  s.platform     = :ios, "11.0"
  s.dependency "React-Core"
  s.dependency "WHToast"
  s.dependency "MBProgressHUD"
  s.frameworks = 'SystemConfiguration','CoreTelephony'
  s.library = 'sqlite3','c++','z'
end
