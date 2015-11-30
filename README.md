# LGPlaceholderView

View covers everything inside view controller, and shows some alert text, progress bar or other view, when you need to hide content.
For example when you push view controller and want to load some data from server, you can prepare everything while LGPlaceholderView will show activity indicator for user.

## Preview

<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlaceholderView/Preview.gif" width="218"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlaceholderView/1.png" width="218"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlaceholderView/2.png" width="218"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlaceholderView/3.png" width="218"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlaceholderView/4.png" width="218"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlaceholderView/5.png" width="218"/>
<img src="https://raw.githubusercontent.com/Friend-LGA/ReadmeFiles/master/LGPlaceholderView/6.png" width="218"/>

## Installation

### With source code

[Download repository](https://github.com/Friend-LGA/LGPlaceholderView/archive/master.zip), then add [LGPlaceholderView directory](https://github.com/Friend-LGA/LGPlaceholderView/blob/master/LGPlaceholderView/) to your project.

### With CocoaPods

CocoaPods is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects. To install with cocoaPods, follow the "Get Started" section on [CocoaPods](https://cocoapods.org/).

#### Podfile
```ruby
platform :ios, '6.0'
pod 'LGPlaceholderView', '~> 1.0.0'
```

### With Carthage

Carthage is a lightweight dependency manager for Swift and Objective-C. It leverages CocoaTouch modules and is less invasive than CocoaPods. To install with carthage, follow the instruction on [Carthage](https://github.com/Carthage/Carthage/).

#### Cartfile
```
github "Friend-LGA/LGPlaceholderView" ~> 1.0.0
```

## Usage

In the source files where you need to use the library, import the header file:

```objective-c
#import "LGPlaceholderView.h"
```

### Initialization

You have several methods for initialization:

```objective-c
- (instancetype)initWithView:(UIView *)view; // parent view, that content you need to hide
```

More init methods you can find in [LGPlaceholderView.h](https://github.com/Friend-LGA/LGPlaceholderView/blob/master/LGPlaceholderView/LGPlaceholderView.h)

#### Notifications

Here is also some notifications, that you can add to NSNotificationsCenter:

```objective-c
kLGPlaceholderViewWillShowNotification;
kLGPlaceholderViewWillDismissNotification;
kLGPlaceholderViewDidShowNotification;
kLGPlaceholderViewDidDismissNotification;
```

### More

For more details try Xcode [Demo project](https://github.com/Friend-LGA/LGPlaceholderView/blob/master/Demo) and see [LGPlaceholderView.h](https://github.com/Friend-LGA/LGPlaceholderView/blob/master/LGPlaceholderView/LGPlaceholderView.h)

## License

LGPlaceholderView is released under the MIT license. See [LICENSE](https://raw.githubusercontent.com/Friend-LGA/LGPlaceholderView/master/LICENSE) for details.
