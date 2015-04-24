Pod::Spec.new do |s|

  s.name         = "APLUrlTextView"
  s.version      = "0.0.2"
  s.summary      = "A simple extension of UITextView allowing to add links and getting informed when one of them has been touched."

  s.description  = <<-DESC
                   A simple UITextView extensions allowing to add URLs and getting informed 
                   when the user selects one of these URLs. You can use the 'linkTextAttributtes' 
                   of UITextView in order to define the styling of the links being embeded.
                   DESC

  s.homepage     = "https://github.com/apploft/APLUrlTextView"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Tino Rachui" => "tino.rachui@apploft.de" }
  
  s.platform     = :ios, "7.0"
  
  s.source       = { :git => "https://github.com/apploft/APLUrlTextView.git", :tag => "0.0.2" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.requires_arc = true

end
