# HorizontalFloatingHeaderLayout

[![Version](https://img.shields.io/cocoapods/v/HorizontalFloatingHeaderLayout.svg?style=flat)](http://cocoapods.org/pods/HorizontalFloatingHeaderLayout)
[![License](https://img.shields.io/cocoapods/l/HorizontalFloatingHeaderLayout.svg?style=flat)](http://cocoapods.org/pods/HorizontalFloatingHeaderLayout)
[![Platform](https://img.shields.io/cocoapods/p/HorizontalFloatingHeaderLayout.svg?style=flat)](http://cocoapods.org/pods/HorizontalFloatingHeaderLayout)

![Example.gif](https://raw.githubusercontent.com/cruzdiego/HorizontalFloatingHeaderLayout/master/Pod/Assets/Example.gif)


## Installation

- Via [CocoaPods](http://cocoapods.org):

```ruby
pod "HorizontalFloatingHeaderLayout"
```

- Manually:

1. Clone this repo or download it as a .zip file
2. Drag and drop HorizontalFloatingHeaderLayout.swift to your project

##Usage

**-** From Storyboard:

**1.** On your UICollectionView's inspector, change its layout to "Custom" and type *HorizontalFloatingHeaderLayout* on the class field

![](https://raw.githubusercontent.com/cruzdiego/HorizontalFloatingHeaderLayout/master/Pod/Assets/storyboard.png)

**2.** Import framework to your UIViewController subclass...

```swift
import HorizontalFloatingHeaderLayout
```

and make it conform protocol HorizontalFloatingHeaderLayoutDelegate

```swift
class YourViewController: UIViewController, HorizontalFloatingHeaderLayoutDelegate {
```

**3.** Implement all the necessary delegate methods.

**-** Programatically:

**1.** Import framework to your UIViewController subclass

```swift
import HorizontalFloatingHeaderLayout
```

**2.** Instantiate and add to your UICollectionView object

```swift
collectionView.collectionViewLayout = HorizontalFloatingHeaderLayout()
```

**3.** Make your UIViewController subclass conform protocol HorizontalFloatingHeaderLayoutDelegate

```swift
class YourViewController: UIViewController, HorizontalFloatingHeaderLayoutDelegate {
```

**4.** Implement all the necessary delegate methods.

##Delegate methods

```swift
//Item size
func collectionView(collectionView: UICollectionView,horizontalFloatingHeaderItemSizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
```

Returns item size. Mandatory implementation.


```swift
//Header size
func collectionView(collectionView: UICollectionView, horizontalFloatingHeaderSizeForSectionAtIndex section: Int) -> CGSize
```

Returns section's header size. Mandatory implementation.

```swift
//Section Inset
optional func collectionView(collectionView: UICollectionView, horizontalFloatingHeaderSectionInsetForSectionAtIndex section: Int) -> UIEdgeInsets
```

Returns section's edge insets. Optional implementation. Default value is UIEdgeInsetsZero

```swift
//Item Spacing
optional func collectionView(collectionView: UICollectionView, horizontalFloatingHeaderItemSpacingForSectionAtIndex section: Int) -> CGFloat
```

Returns point spacing between items on the same column. Optional implementation. Default value is 0.0.

```swift
//Line Spacing
optional func collectionView(collectionView: UICollectionView,horizontalFloatingHeaderColumnSpacingForSectionAtIndex section: Int) -> CGFloat
```

Returns points spacing between columns. Optional implementation. Default value is 0.0.

##Requirements

- iOS 8.3
- Xcode 7.1 or later (Uses Swift 2.1 syntax)

## Author

Diego Cruz, diego.cruz@icloud.com

## License

HorizontalFloatingHeaderLayout is available under the MIT license. See the LICENSE file for more info.
