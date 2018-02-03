Pod::Spec.new do |s|
    s.name         = "AMMeterView"
    s.version      = "1.0"
    s.summary      = "AMMeterView is a view can select value."
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.homepage     = "https://github.com/adventam10/AMMeterView"
    s.author       = { "am10" => "adventam10@gmail.com" }
    s.source       = { :git => "https://github.com/adventam10/AMMeterView.git", :tag => "#{s.version}" }
    s.platform     = :ios, "9.0"
    s.requires_arc = true
    s.source_files = 'AMMeter/*.{swift}'
    s.swift_version = "4.0"
end
