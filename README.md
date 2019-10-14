# AMMeterView

![Pod Platform](https://img.shields.io/cocoapods/p/AMMeterView.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/AMMeterView.svg?style=flat)
[![Pod Version](https://img.shields.io/cocoapods/v/AMMeterView.svg?style=flat)](http://cocoapods.org/pods/AMMeterView)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

`AMMeterView` is a view can select value.

## Demo

![meter](https://user-images.githubusercontent.com/34936885/34903884-fb43abe2-f87d-11e7-9d9c-6c9f33a17df0.gif)

## Usage

Create meterView.

```swift
let meterView = AMMeterView(frame: view.bounds)

// customize here

meterView.delegate = self
meterView.dataSource = self
view.addSubview(meterView)
```

Conform to the protocol in the class implementation.

```swift
/// DataSource
// Required
func numberOfValue(in meterView: AMMeterView) -> Int
func meterView(_ meterView: AMMeterView, titleForValueAtIndex index: Int) -> String
// Optional
func meterView(_ meterView: AMMeterView, textColorForValueAtIndex index: Int) -> UIColor // default is black
func meterView(_ meterView: AMMeterView, textFontForValueAtIndex index: Int) -> UIFont // default is System 15.0

/// Delegate
func meterView(_ meterView: AMMeterView, didSelectAtIndex index: Int) { 
    // use selected index here
}
```

### Customization
`AMMeterView` can be customized via the following properties.

```swift
@IBInspectable public var meterBorderLineWidth: CGFloat = 5
@IBInspectable public var valueIndexWidth: CGFloat = 2.0
@IBInspectable public var valueHandWidth: CGFloat = 3.0
@IBInspectable public var meterBorderLineColor: UIColor = .black
@IBInspectable public var meterColor: UIColor = .clear
@IBInspectable public var valueHandColor: UIColor = .red
@IBInspectable public var valueIndexColor: UIColor = .black
```

![meter](https://user-images.githubusercontent.com/34936885/66727449-3db1e400-ee7a-11e9-8003-217c14ebb2ef.png)

## Installation

### CocoaPods

Add this to your Podfile.

```ogdl
pod 'AMMeterView'
```

### Carthage

Add this to your Cartfile.

```ogdl
github "adventam10/AMMeterView"
```

## License

MIT
