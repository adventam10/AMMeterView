//
//  AMMeterView.swift
//  AMMeterView, https://github.com/adventam10/AMMeterView
//
//  Created by am10 on 2017/12/29.
//  Copyright © 2017年 am10. All rights reserved.
//

import UIKit

public protocol AMMeterViewDataSource: AnyObject {
    // MARK:- Required
    func numberOfValue(in meterView: AMMeterView) -> Int
    func meterView(_ meterView: AMMeterView, titleForValueAtIndex index: Int) -> String
    // MARK:- Optional
    func meterView(_ meterView: AMMeterView, textColorForValueAtIndex index: Int) -> UIColor
}

public extension AMMeterViewDataSource {
    func meterView(_ meterView: AMMeterView, textColorForValueAtIndex index: Int) -> UIColor {
        return .black
    }
}

public protocol AMMeterViewDelegate: AnyObject {
    func meterView(_ meterView: AMMeterView, didSelectAtIndex index: Int)
}

internal class AMMeterModel {
    var numberOfValue: Int = 0
    var isEditing = false
    var currentAngle = Float(Double.pi + Double.pi/2) // 3/2π~7/2π
    var currentIndex: Int {
        let index = Int((currentAngle - angle270 + 0.00001) / angleUnit)
        precondition(numberOfValue > index && index >= 0)
        return index
    }
    var angleUnit: Float {
        precondition(numberOfValue > 0)
        return angle360 / Float(numberOfValue)
    }
    
    let angle270 = Float(Double.pi + Double.pi/2)
    let angle360 = Float(Double.pi*2)
    
    func adjustFont(rect: CGRect) -> UIFont {
        let length = (rect.width > rect.height) ? rect.height : rect.width
        return .systemFont(ofSize: length * 0.8)
    }
    
    func calculateValueAngle(point: CGPoint, radius: CGFloat) -> Float {
        let angle = calculateRadian(point: point, radius: radius)
        let index = Int((angle - angle270) / angleUnit)
        return calculateAngle(index: index)
    }
    
    func calculateAngle(index: Int) -> Float {
        return angleUnit * Float(index) + angle270
    }
    
    private func calculateRadian(point: CGPoint, radius: CGFloat) -> Float {
        // origin(view's center)
        let centerPoint = CGPoint(x: radius, y: radius)
        
        // Find difference in coordinates.Since the upper side of the screen is the Y coordinate +, the Y coordinate changes the sign.
        let x = Float(point.x - centerPoint.x)
        let y = -Float(point.y - centerPoint.y)
        var radian = atan2f(y, x)
        
        // To correct radian(3/2π~7/2π: 0 o'clock = 3/2π)
        radian = radian * -1
        if radian < 0 {
            radian += angle360
        }
        
        if radian >= 0 && radian < angle270 {
            radian += angle360
        }
        
        return radian
    }
}

@IBDesignable public class AMMeterView: UIView {

    @IBInspectable public var meterBorderLineWidth: CGFloat = 5
    @IBInspectable public var valueIndexWidth: CGFloat = 2.0
    @IBInspectable public var valueHandWidth: CGFloat = 3.0
    @IBInspectable public var meterBorderLineColor: UIColor = .black
    @IBInspectable public var meterColor: UIColor = .clear
    @IBInspectable public var valueHandColor: UIColor = .red
    @IBInspectable public var valueIndexColor: UIColor = .black
    
    weak public var dataSource: AMMeterViewDataSource? {
        didSet {
            model.numberOfValue = dataSource?.numberOfValue(in: self) ?? 0
        }
    }
    weak public var delegate: AMMeterViewDelegate?
    public var selectedIndex: Int {
        return model.currentIndex
    }
    
    override public var bounds: CGRect {
        didSet {
            reloadMeter()
        }
    }
    
    private let meterView = UIView()
    private let model = AMMeterModel()
    
    private var valueLabels = [UILabel]()
    private var drawLayer: CAShapeLayer?
    private var valueHandLayer: CAShapeLayer?
    private var panLayer: CAShapeLayer?
    private var meterCenter: CGPoint {
        return .init(x: radius, y: radius)
    }
    private var radius: CGFloat {
        return meterView.frame.width/2
    }
    private var handLength: CGFloat {
        return radius * 0.8
    }
    
    override public func draw(_ rect: CGRect) {
        reloadMeter()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    // MARK:- Prepare View
    private func prepareMeterView() {
        let length = (frame.width < frame.height) ? frame.width : frame.height
        meterView.frame = CGRect(x: frame.width/2 - length/2,
                                 y: frame.height/2 - length/2,
                                 width: length, height: length)
        meterView.backgroundColor = .clear
        addSubview(meterView)
    }

    private func prepareValueLabel() {
        guard let dataSource = dataSource else {
            return
        }
        
        var angle = model.angle270
        var smallRadius = radius - (radius/10 + meterBorderLineWidth)
        let length = radius/4
        smallRadius -= length/2
        
        // draw line (from center to out)
        for index in 0..<model.numberOfValue {
            let label = makeLabel(length: length)
            label.text = dataSource.meterView(self, titleForValueAtIndex: index)
            label.textColor = dataSource.meterView(self, textColorForValueAtIndex: index)
            label.font = model.adjustFont(rect: label.frame)
            meterView.addSubview(label)
            let point = CGPoint(x: meterCenter.x + smallRadius * CGFloat(cosf(angle)),
                                y: meterCenter.y + smallRadius * CGFloat(sinf(angle)))
            label.center = point
            angle += model.angleUnit
        }
    }
    
    private func makeLabel(length: CGFloat) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: length, height: length))
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        return label
    }
    
    // MARK:- Make Layer
    private func makeDrawLayer() -> CAShapeLayer {
        let drawLayer = CAShapeLayer()
        drawLayer.frame = meterView.bounds
        drawLayer.cornerRadius = radius
        drawLayer.masksToBounds = true
        drawLayer.borderWidth = meterBorderLineWidth
        drawLayer.borderColor = meterBorderLineColor.cgColor
        return drawLayer
    }
    
    private func makeValueIndexLayer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = drawLayer!.bounds
        layer.strokeColor = valueIndexColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = valueIndexWidth
        
        let smallRadius = radius - (radius/10 + meterBorderLineWidth)
        let path = UIBezierPath()
        var angle = model.angle270
        
        // draw line (from center to out)
        for _ in 0..<model.numberOfValue {
            let start = CGPoint(x: meterCenter.x + radius * CGFloat(cosf(angle)),
                                y: meterCenter.y + radius * CGFloat(sinf(angle)))
            path.move(to: start)
            let end = CGPoint(x: meterCenter.x + smallRadius * CGFloat(cosf(angle)),
                              y: meterCenter.y + smallRadius * CGFloat(sinf(angle)))
            path.addLine(to: end)
            angle += model.angleUnit
        }
        
        layer.path = path.cgPath
        return layer
    }
    
    private func makeValueHandLayer() -> CAShapeLayer {
        let valueHandLayer = CAShapeLayer()
        valueHandLayer.frame = drawLayer!.bounds
        valueHandLayer.strokeColor = valueHandColor.cgColor
        valueHandLayer.fillColor = UIColor.clear.cgColor
        valueHandLayer.lineWidth = valueHandWidth
        valueHandLayer.path = makeHandPath(angle: model.angle270).cgPath
        return valueHandLayer
    }
    
    private func makeHandPath(angle: Float) -> UIBezierPath {
        let path = UIBezierPath()
        let point = CGPoint(x: meterCenter.x + handLength * CGFloat(cosf(angle)),
                            y: meterCenter.y + handLength * CGFloat(sinf(angle)))
        path.move(to: meterCenter)
        path.addLine(to: point)
        return path
    }
    
    private func makePanLayer() -> CAShapeLayer {
        let path = UIBezierPath(ovalIn: CGRect(x: meterCenter.x - radius,
                                               y: meterCenter.y - radius,
                                               width: radius * 2, height: radius * 2))
        let panLayer = CAShapeLayer()
        panLayer.frame = drawLayer!.bounds
        panLayer.strokeColor = UIColor.clear.cgColor
        panLayer.fillColor = meterColor.cgColor
        panLayer.path = path.cgPath
        return panLayer
    }
    
    // MARK:- Gesture Action
    @objc func panAction(gesture: UIPanGestureRecognizer) {
        guard let panLayer = panLayer else {
            return
        }
        
        let point = gesture.location(in: meterView)
        if gesture.state == .began {
            model.isEditing = UIBezierPath(cgPath: panLayer.path!).contains(point)
        } else {
            if !model.isEditing {
                model.isEditing = UIBezierPath(cgPath: panLayer.path!).contains(point)
            } else {
                editValue(point: point)
            }
        }
    }
    
    private func editValue(point: CGPoint) {
        let angle = model.calculateValueAngle(point: point, radius: radius)
        if angle == model.currentAngle {
            return
        }
        
        model.currentAngle = angle
        drawValueHandLayer(angle: angle)
        delegate?.meterView(self, didSelectAtIndex: model.currentIndex)
    }
    
    // MARK:- Draw ValueHand
    private func drawValueHandLayer(angle: Float) {
        guard let valueHandLayer = valueHandLayer else {
            return
        }
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        valueHandLayer.path = makeHandPath(angle: angle).cgPath
        CATransaction.commit()
    }
    
    // MARK:- Clear/Reload
    private func clear() {
        meterView.subviews.forEach { $0.removeFromSuperview() }
        meterView.removeFromSuperview()
        drawLayer?.removeFromSuperlayer()
        drawLayer = nil
        
        valueHandLayer = nil
        panLayer = nil
    }
    
    public func reloadMeter() {
        clear()
        
        model.numberOfValue = dataSource?.numberOfValue(in: self) ?? 0
        
        prepareMeterView()
        
        drawLayer = makeDrawLayer()
        meterView.layer.addSublayer(drawLayer!)
        drawLayer!.addSublayer(makeValueIndexLayer())
        
        prepareValueLabel()
        
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector(self.panAction(gesture:)))
        meterView.addGestureRecognizer(pan)
        panLayer = makePanLayer()
        drawLayer!.insertSublayer(panLayer!, at: 0)
        
        valueHandLayer = makeValueHandLayer()
        drawLayer!.addSublayer(valueHandLayer!)
    }
    
    public func selectValue(at index: Int) {
        precondition(model.numberOfValue > index && index >= 0)
        model.currentAngle = model.calculateAngle(index: index)
        drawValueHandLayer(angle: model.currentAngle)
    }
}
