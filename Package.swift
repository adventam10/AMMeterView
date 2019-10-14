// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  AMMeterView, https://github.com/adventam10/AMMeterView
//
//  Created by am10 on 2017/12/29.
//  Copyright © 2017年 am10. All rights reserved.
//

import PackageDescription

let package = Package(name: "AMMeterView",
                      platforms: [.iOS(.v9)],
                      products: [.library(name: "AMMeterView",
                                          targets: ["AMMeterView"])],
                      targets: [.target(name: "AMMeterView",
                                        path: "Source")],
                      swiftLanguageVersions: [.v5])
