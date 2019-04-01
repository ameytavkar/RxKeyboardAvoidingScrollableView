Pod::Spec.new do |spec|
  spec.name = "RxKeyboardAvoidingScrollableView"
  spec.version = "1.0.0"
  spec.summary = "A universal drop-in UIScrollView based solution that keeps active textfield visible when keyboard is being shown."
  spec.homepage = "https://github.com/ameytavkar/RxKeyboardAvoidingScrollableView"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Amey Tavkar" => 'amey.tavkar@gmail.com' }
  spec.social_media_url = "http://twitter.com/ameytavkar"

  spec.platform = :ios, "9.1"
  spec.swift_version = '5'
  
  spec.requires_arc = true
  spec.source = { git: "https://github.com/ameytavkar/RxKeyboardAvoidingScrollableView.git", tag: "v#{spec.version}", submodules: false }
  spec.source_files = "RxKeyboardAvoidingScrollableView/**/*.{h,swift}"

  spec.dependency "RxSwift", "~> 4.4.2"
  spec.dependency "RxCocoa", "~> 4.4.2"
end