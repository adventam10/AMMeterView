//
//  AMMeterView.swift
//  AMMeterView, https://github.com/adventam10/AMMeterView
//
//  Created by am10 on 2017/12/29.
//  Copyright © 2017年 am10. All rights reserved.
//

import UIKit

public protocol AMMeterViewDataSource: AnyObject {
    func numberOfValue(in meterView: AMMeterView) -> Int
    func meterView(_ meterView: AMMeterView, valueForIndex index: Int) -> String
}

public protocol AMMeterViewDelegate: AnyObject {
    func meterView(_ meterView: AMMeterView, didSelectAtIndex index: Int)
}

@IBDesignable public class AMMeterView: UIView {

    override public var bounds: CGRect {
        didSet {
            reloadMeter()
        }
    }

    weak public var dataSource: AMMeterViewDataSource?
    weak public var delegate: AMMeterViewDelegate?
    
    @IBInspectable public var meterBorderLineWidth: CGFloat = 5
    @IBInspectable public var valueIndexWidth: CGFloat = 2.0
    @IBInspectable public var valueHandWidth: CGFloat = 3.0
    @IBInspectable public var meterBorderLineColor: UIColor = .black
    @IBInspectable public var meterColor: UIColor = .clear
    @IBInspectable public var valueHandColor: UIColor = .red
    @IBInspectable public var valueLabelTextColor: UIColor = .black
    @IBInspectable public var valueIndexColor: UIColor = .black
    
    private let meterSpace: CGFloat = 10
    private let meterView = UIView()
    
    private var numberOfValue: Int = 0
    private var drawLayer: CAShapeLayer?
    private var valueHandLayer: CAShapeLayer?
    private var panLayer: CAShapeLayer?
    private var isEditing = false
    private var nowAngle: Float = 0.0
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
        var length = (frame.width < frame.height) ? frame.width : frame.height
        length -= meterSpace * 2
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
        
        var angle = Float(Double.pi/2 + Double.pi)
        var smallRadius = radius - (radius/10 + meterBorderLineWidth)
        let length = radius/4
        smallRadius -= length/2
        
        let angleUnit = (numberOfValue > 0) ? Float(Double.pi*2) / Float(numberOfValue) : 0.0
        
        // draw line (from center to out)
        for index in 0..<numberOfValue {
            let label = makeLabel(length: length)
            label.text = dataSource.meterView(self, valueForIndex: index)
            label.font = adjustFont(rect: label.frame)
            meterView.addSubview(label)
            let point = CGPoint(x: meterCenter.x + smallRadius * CGFloat(cosf(angle)),
                                y: meterCenter.y + smallRadius * CGFloat(sinf(angle)))
            label.center = point
            angle += angleUnit
        }
    }
    
    private func makeLabel(length: CGFloat) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: length, height: length))
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = valueLabelTextColor
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
        
        var angle: Float = Float(Double.pi/2 + Double.pi)
        let smallRadius = radius - (radius/10 + meterBorderLineWidth)
        
        let path = UIBezierPath()
        let angleUnit = (numberOfValue > 0) ? Float(Double.pi*2) / Float(numberOfValue) : 0.0
        
        // draw line (from center to out)
        for _ in 0..<numberOfValue {
            let start = CGPoint(x: meterCenter.x + radius * CGFloat(cosf(angle)),
                                y: meterCenter.y + radius * CGFloat(sinf(angle)))
            path.move(to: start)
            let end = CGPoint(x: meterCenter.x + smallRadius * CGFloat(cosf(angle)),
                              y: meterCenter.y + smallRadius * CGFloat(sinf(angle)))
            path.addLine(to: end)
            
            angle += angleUnit
        }
        
        layer.lineWidth = valueIndexWidth
        layer.path = path.cgPath
        return layer
    }
    
    private func makeValueHandLayer() -> CAShapeLayer {
        let valueHandLayer = CAShapeLayer()
        valueHandLayer.frame = drawLayer!.bounds
        valueHandLayer.strokeColor = valueHandColor.cgColor
        valueHandLayer.fillColor = UIColor.clear.cgColor
        
        let angle = Float(Double.pi/2 + Double.pi)
        valueHandLayer.lineWidth = valueHandWidth
        valueHandLayer.path = makeHandPath(angle: angle).cgPath
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
                                               width: radius * 2,
                                               height: radius * 2))
        
        let panLayer = CAShapeLayer()
        panLayer.frame = drawLayer!.bounds
        panLayer.strokeColor = UIColor.clear.cgColor
        panLayer.fillColor = meterColor.cgColor
        panLayer.path = path.cgPath
        return panLayer
    }
    
    //MARK:- Gesture Action
    @objc func panAction(gesture: UIPanGestureRecognizer) {
        guard let panLayer = panLayer else {
            return
        }
        
        let point = gesture.location(in: meterView)
        if gesture.state == .began {
            isEditing = UIBezierPath(cgPath: panLayer.path!).contains(point)
        } else {
            if !isEditing {
                isEditing = UIBezierPath(cgPath: panLayer.path!).contains(point)
            } else {
                editValue(point: point)
            }
        }
    }
    
    private func editValue(point: CGPoint) {
        let radian = calculateRadian(point: point)
        let angle = calculateValueAngle(radian: radian)
        
        if angle == nowAngle {
            return
        }
        
        nowAngle = angle
        drawValueHandLayer(angle: angle)
        
        let index = (radian - Float(Double.pi/2 + Double.pi)) / (Float(Double.pi*2) / Float(numberOfValue))
        delegate?.meterView(self, didSelectAtIndex: Int(index))
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
    
    // MARK:- Calculate
    private func calculateValueAngle(radian: Float) -> Float {
        let index = Int((radian - Float(Double.pi/2 + Double.pi)) / (Float(Double.pi*2) / Float(numberOfValue)))
        let angle: Float = (Float(Double.pi*2) / Float(numberOfValue)) * Float(index)
        return angle + Float(Double.pi/2 + Double.pi)
    }
    
    private func calculateRadian(point: CGPoint) -> Float {
        // origin(view's center)
        let radius = meterView.frame.width/2
        let centerPoint = CGPoint(x: radius, y: radius)
        
        // Find difference in coordinates.Since the upper side of the screen is the Y coordinate +, the Y coordinate changes the sign.
        let x: Float = Float(point.x - centerPoint.x)
        let y: Float = -Float(point.y - centerPoint.y)
        var radian: Float = atan2f(y, x)
        
        // To correct radian(3/2π~7/2π: 0 o'clock = 3/2π)
        radian = radian * -1
        if radian < 0 {
            radian += Float(2*Double.pi)
        }
        
        if radian >= 0 && radian < Float(Double.pi/2 + Double.pi) {
            radian += Float(2*Double.pi)
        }
        
        return radian
    }
    
    private func calculateAngle(index: Int) -> Float {
        let angle = (Float(Double.pi*2) / Float(numberOfValue)) * Float(index)
        return angle + Float(Double.pi/2 + Double.pi)
    }
    
    private func adjustFont(rect: CGRect) -> UIFont {
        let length = (rect.width > rect.height) ? rect.height : rect.width
        return .systemFont(ofSize: length * 0.8)
    }
    
    // MARK:- Clear/Reload
    private func clear() {
        meterView.subviews.forEach{$0.removeFromSuperview()}
        meterView.removeFromSuperview()
        drawLayer?.removeFromSuperlayer()
        drawLayer = nil
        
        valueHandLayer = nil
        panLayer = nil
    }
    
    public func reloadMeter() {
        clear()
        
        if let dataSource = dataSource {
            numberOfValue = dataSource.numberOfValue(in: self)
        }
        
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
    
    public func select(index: Int) {
        let angle = calculateAngle(index: index)
        nowAngle = angle
        drawValueHandLayer(angle: angle)
    }
}
