//
//  SampleAMMeterTests.swift
//  SampleAMMeterTests
//
//  Created by am10 on 2019/10/13.
//  Copyright © 2019 am10. All rights reserved.
//

import XCTest
@testable import SampleAMMeter

class SampleAMMeterTests: XCTestCase {
    
    private let angle270 = Float(Double.pi + Double.pi/2)
    private let angle360 = Float(Double.pi*2)
    private let accuracy: Float = 0.00001
    private let radius: CGFloat = 1.0
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAngleUnit() {
        let model = AMMeterModel()
        model.numberOfValue = 1
        XCTAssertEqual(model.angleUnit, angle360, accuracy: accuracy)
        model.numberOfValue = 2
        XCTAssertEqual(model.angleUnit, angle360/2, accuracy: accuracy)
        model.numberOfValue = 3
        XCTAssertEqual(model.angleUnit, angle360/3, accuracy: accuracy)
        model.numberOfValue = 4
        XCTAssertEqual(model.angleUnit, angle360/4, accuracy: accuracy)
        model.numberOfValue = 5
        XCTAssertEqual(model.angleUnit, angle360/5, accuracy: accuracy)
        model.numberOfValue = 6
        XCTAssertEqual(model.angleUnit, angle360/6, accuracy: accuracy)
        model.numberOfValue = 7
        XCTAssertEqual(model.angleUnit, angle360/7, accuracy: accuracy)
        model.numberOfValue = 8
        XCTAssertEqual(model.angleUnit, angle360/8, accuracy: accuracy)
        model.numberOfValue = 9
        XCTAssertEqual(model.angleUnit, angle360/9, accuracy: accuracy)
        model.numberOfValue = 10
        XCTAssertEqual(model.angleUnit, angle360/10, accuracy: accuracy)
        model.numberOfValue = 100
        XCTAssertEqual(model.angleUnit, angle360/100, accuracy: accuracy)
    }
    
    func testCurrentIndex() {
        let model = AMMeterModel()
        model.numberOfValue = 7
        model.currentAngle = angle270
        XCTAssertEqual(model.currentIndex, 0)
        model.currentAngle = (angle360/7) * 1 + angle270
        XCTAssertEqual(model.currentIndex, 1)
        model.currentAngle = (angle360/7) * 2 + angle270
        XCTAssertEqual(model.currentIndex, 2)
        model.currentAngle = (angle360/7) * 3 + angle270
        XCTAssertEqual(model.currentIndex, 3)
        model.currentAngle = (angle360/7) * 4 + angle270
        XCTAssertEqual(model.currentIndex, 4)
        model.currentAngle = (angle360/7) * 5 + angle270
        XCTAssertEqual(model.currentIndex, 5)
        model.currentAngle = (angle360/7) * 6 + angle270
        XCTAssertEqual(model.currentIndex, 6)
    }
    
    func testCalculateValueAngleWithPointMethod() {
        let model = AMMeterModel()
        let count = 7
        model.numberOfValue = count
        var angle = model.calculateValueAngle(point: point(count: count, index: 0), radius: radius)
        XCTAssertEqual(angle, angle270, accuracy: accuracy)
        angle = model.calculateValueAngle(point: point(count: count, index: 1), radius: radius)
        XCTAssertEqual(angle, (angle360/7) * 1 + angle270, accuracy: accuracy)
        angle = model.calculateValueAngle(point: point(count: count, index: 2), radius: radius)
        XCTAssertEqual(angle, (angle360/7) * 2 + angle270, accuracy: accuracy)
        angle = model.calculateValueAngle(point: point(count: count, index: 3), radius: radius)
        XCTAssertEqual(angle, (angle360/7) * 3 + angle270, accuracy: accuracy)
        angle = model.calculateValueAngle(point: point(count: count, index: 4), radius: radius)
        XCTAssertEqual(angle, (angle360/7) * 4 + angle270, accuracy: accuracy)
        angle = model.calculateValueAngle(point: point(count: count, index: 5), radius: radius)
        XCTAssertEqual(angle, (angle360/7) * 5 + angle270, accuracy: accuracy)
        angle = model.calculateValueAngle(point: point(count: count, index: 6), radius: radius)
        XCTAssertEqual(angle, (angle360/7) * 6 + angle270, accuracy: accuracy)
    }
    
    func testCalculateAngleWithIndexMethod() {
        let model = AMMeterModel()
        let count = 7
        model.numberOfValue = count
        XCTAssertEqual(model.calculateAngle(index: 0), angle270, accuracy: accuracy)
        XCTAssertEqual(model.calculateAngle(index: 1), (angle360/7) * 1 + angle270, accuracy: accuracy)
        XCTAssertEqual(model.calculateAngle(index: 2), (angle360/7) * 2 + angle270, accuracy: accuracy)
        XCTAssertEqual(model.calculateAngle(index: 3), (angle360/7) * 3 + angle270, accuracy: accuracy)
        XCTAssertEqual(model.calculateAngle(index: 4), (angle360/7) * 4 + angle270, accuracy: accuracy)
        XCTAssertEqual(model.calculateAngle(index: 5), (angle360/7) * 5 + angle270, accuracy: accuracy)
        XCTAssertEqual(model.calculateAngle(index: 6), (angle360/7) * 6 + angle270, accuracy: accuracy)
    }
    
    private func angle(count: Int, index: Int) -> CGFloat {
        let angle = (angle360/Float(count)) * (Float(index)+0.0001) + angle270
        return CGFloat(angle)
    }

    private func point(count: Int, index: Int) -> CGPoint {
        return .init(x: radius + cos(angle(count: count, index: index)) * radius,
                     y: radius + sin(angle(count: count, index: index)) * radius)
    }
}
