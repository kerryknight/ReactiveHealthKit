ReactiveHealthKit
=================


ReactiveHealthKit adds simple [ReactiveCocoa](http://reactivecocoa.io/) extensions to Apple's [HealthKit](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Framework/index.html) framework to lift HealthKit's block-based APIs into the functional reactive programming world.  Check out the included [ReactiveFit](https://github.com/kerryknight/ReactiveHealthKit/tree/master/Example) project for usage examples. Pull requests welcome.

## Developer Notes

You should probably read all of Apple's [HealthKit](https://developer.apple.com/library/ios/documentation/HealthKit/Reference/HealthKit_Framework/index.html) reference prior to using ReactiveHealthKit.  ReactiveHealthKit strives to mimic the native behavior of HealthKit so it's imperative you understand the caveats that go along with a user allowing or denying access to certain HealthKit data points. For instance, HealthKit will not return an error if a user has denied access to a certain data point you're querying for (e.g. weight) and thus, it'll be up to you to ensure you check that the response's data point exists prior to use.

## Installation

ReactiveHealthKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "ReactiveHealthKit"

## Testing

ReactiveHealthKit is fully unit tested.  To run tests, clone the project or download the [project zip file](https://github.com/kerryknight/ReactiveHealthKit/archive/develop.zip) and extract.  From the root project folder:

    cd ReactiveHealthKitTests
    pod install

Once all [CocoaPods](http://cocoapods.org/) have been successfully installed, you can open the **ReactiveHealthKit.xcworkspace** file and `Cmd + U` to run the tests or, if you have [xctool](https://github.com/facebook/xctool) installed, run:

    xctool test -workspace ReactiveHealthKit.xcworkspace -scheme ReactiveHealthKit -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO

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
