# AMMeterView

`AMMeterView` is a view can select value.

## Demo

![meter](https://user-images.githubusercontent.com/34936885/34903884-fb43abe2-f87d-11e7-9d9c-6c9f33a17df0.gif)

## Variety

<img width="345" alt="meter" src="https://user-images.githubusercontent.com/34936885/34903871-c4a26bb4-f87d-11e7-9146-9f9b8d522a88.png">

## Usage

```swift
let meterView = AMMeterView(frame: view.bounds)

// customize here

meterView.delegate = self
meterView.dataSource = self
view.addSubview(meterView)
```

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
