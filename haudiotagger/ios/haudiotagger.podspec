# Download the binaries from GitHub.
version = "1.1.9"
lib_url = "https://github.com/Hirdaya-Shrestha/haudiotagger/releases/download/v#{version}/ios.zip"

`
mkdir -p Frameworks
cd Frameworks
if [ ! -d ios.zip ]; then
  curl -L "#{lib_url}" -o ios.zip
  unzip -o ios.zip -d 'haudiotagger.xcframework'
fi
cd ..
`

Pod::Spec.new do |s|
  s.name             = 'haudiotagger'
  s.version          = '1.1.9'
  s.summary          = 'A Flutter plugin for reading and writing audio metadata.'
  s.description      = <<-DESC
A Flutter plugin for reading and writing audio metadata, powered by Rust.
                       DESC
  s.homepage         = 'https://github.com/Hirdaya-Shrestha/haudiotagger'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Hirdaya Shrestha' => 'hirdaya098@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.vendored_frameworks = 'Frameworks/**/*.xcframework'
  s.static_framework = true

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
