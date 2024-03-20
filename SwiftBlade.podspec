Pod::Spec.new do |s|
  s.name             = 'SwiftBlade'
  s.version          = '0.6.18'
  s.summary          = 'Swift Blade SDK for iOS Apps'
  s.description      = <<-DESC
                       Swift Blade is Swift library that allows developers to interact with Hedera Hashgraph and Ethereum smart contracts from within a Swift based app such as iOS. It provides a set of methods such as creating accounts, checking balances, transferring tokens, calling smart contracts, and more
                       DESC
  s.homepage         = 'https://github.com/Blade-Labs/swift-blade'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Blade Labs' => 'https://bladelabs.io' }
  s.source           = { :git => 'https://github.com/Blade-Labs/swift-blade', :tag => s.version.to_s }
  s.platforms        = { :ios => '13.0' }
  s.swift_version    = '5.1'

  s.source_files = 'Sources/SwiftBlade/*.swift'

  s.resource_bundles = {
    'SwiftBlade_SwiftBlade' => ['Sources/SwiftBlade/JS/*.*']
  }

  s.frameworks = 'Foundation'
  
  s.dependency 'BigInt', '~> 5.0.0'
  s.dependency 'FingerprintPro', '~> 2.4'
end
