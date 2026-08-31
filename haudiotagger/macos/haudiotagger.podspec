# Download the binary from GitHub.
version = "1.2.5"
lib_url = "https://github.com/Hirdaya-Shrestha/haudiotagger/releases/download/v#{version}/macos.zip"

`
mkdir -p Frameworks
cd Frameworks
if [ ! -d macos.zip ]; then
  curl -L "#{lib_url}" -o macos.zip
  unzip -o macos.zip -d 'haudiotagger.xcframework'
fi
cd ..
`

Pod::Spec.new do |s|
  s.name             = 'haudiotagger'
s.version = '1.2.5'
  s.summary          = 'A Flutter plugin for reading and writing audio metadata.'
  s.description      = <<-DESC
A Flutter plugin for reading and writing audio metadata, powered by Rust.
                       DESC
  s.homepage         = 'https://github.com/Hirdaya-Shrestha/haudiotagger'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Hirdaya Shrestha' => 'hirdaya098@gmail.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.vendored_frameworks = 'Frameworks/**/*.xcframework'
  s.static_framework = true
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
