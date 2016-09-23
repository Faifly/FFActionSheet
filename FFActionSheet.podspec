Pod::Spec.new do |spec|
spec.name = "FFActionSheet"
spec.version = "1.0.0"
spec.summary = "Simple ActionSheet."
spec.homepage = "https://github.com/Faifly/FFActionSheet"
spec.license = { type: 'MIT', file: 'LICENSE' }
spec.authors = { "Ihor Embaievskyi" => 'ihor.embaievskyi@gmail.com' }

spec.platform = :ios, "8.0"
spec.requires_arc = true
spec.source = { git: "https://github.com/Faifly/FFActionSheet"}
spec.source_files = "FFActionSheet/**/*.{h,FFActionSheet.swift}"

end
