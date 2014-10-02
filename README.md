ReactiveHealthKit
=================

[![CI Status](http://img.shields.io/travis/kerryknight/ReactiveHealthKit.svg?style=flat)](https://travis-ci.org/kerryknight/ReactiveHealthKit)



ReactiveHealthKit adds simple [ReactiveCocoa](http://reactivecocoa.io/) extensions to Apple's [HealthKit](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Framework/index.html) framework to lift HealthKit's block-based APIs into the functional reactive programming world.  Check out the included [ReactiveFit](https://github.com/kerryknight/ReactiveHealthKit/tree/master/Example) project for usage examples. Pull requests welcome.

Unit tests coming soon...

## Installation

ReactiveHealthKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "ReactiveHealthKit"

## Example Project 

The included example project is a direct port of Apple's [Fit sample project](https://developer.apple.com/library/ios/samplecode/Fit/Introduction/Intro.html). I've tried to modify the app and its workflow as little as possible from Apple's original design, beyond that which enables using ReactiveHealthKit in a 1-to-1 swap of Apple's block-based code.  However, this does not mean there aren't underlying issues with Apple's code or issues I've inadvertently introduced myself.  Pull requests are welcome if you come across something in need of fixing. 

To run the example project, clone the repo, and run `pod install` from the Example directory first. As noted in the Apple sample code, HealthKit-enabled projects will only run on an actual device so you must be sure to change you active build scheme to using your connected HealthKit-enabled device.

Note: If you get a warning about security when you try to run the example app on your device, see this StackOverflow answer: http://stackoverflow.com/a/25837245/1700790

## Requirements

iOS 8.0+ running on a HealthKit-compatible iPhone; HealthKit is not compatible with iPads or Macs 

## Author

Kerry Knight, kerry.a.knight@gmail.com

## License

ReactiveHealthKit is available under the MIT license. See the LICENSE file for more info.
