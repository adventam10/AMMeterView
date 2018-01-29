//
//  AMMeterView.swift
//  AMMeterView, https://github.com/adventam10/AMMeterView
//
//  Created by am10 on 2017/12/29.
//  Copyright © 2017年 am10. All rights reserved.
//

import UIKit

public protocol AMMeterViewDataSource: class {
    
    func numberOfValue(meterView: AMMeterView) -> Int
    func meterView(meterView: AMMeterView, valueForIndex index: Int) -> String
}

public protocol AMMeterViewDelegate: class {
    
    func meterView(meterView: AMMeterView, didSelectAtIndex index: Int)
}

@IBDesignable public class AMMeterView: UIView {

    override public var bounds: CGRect {
        
        didSet {
            
            reloadMeter()
        }
    }
    
    weak public var dataSource:AMMeterViewDataSource?
    weak public var delegate:AMMeterViewDelegate?
    
    @IBInspectable public var meterBorderLineWidth:CGFloat = 5
    
    @IBInspectable public var valueIndexWidth:CGFloat = 2.0
    
    @IBInspectable public var valueHandWidth:CGFloat = 3.0
    
    @IBInspectable public var meterBorderLineColor:UIColor = UIColor.black
    
    @IBInspectable public var meterColor:UIColor = UIColor.clear
    
    @IBInspectable public var valueHandColor:UIColor = UIColor.red
    
    @IBInspectable public var valueLabelTextColor:UIColor = UIColor.black
    
    @IBInspectable public var valueIndexColor:UIColor = UIColor.black
    
    private var numberOfValue:Int = 0
    
    private let meterSpace:CGFloat = 10
    
    private let meterView = UIView()
    
    private var drawLayer:CAShapeLayer?
    
    private var valueHandLayer:CAShapeLayer?
    
    private var panLayer:CAShapeLayer?
    
    private var isEditing = false
    
    private var nowAngle:Float = 0.0
    
    override public func draw(_ rect: CGRect) {
        
        reloadMeter()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        
        super.init(coder:aDecoder)
    }
    
    override public init(frame: CGRect) {
        
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    convenience init() {
        
        self.init(frame: CGRect.zero)
    }
    
    //MARK:Prepare
    private func prepareMeterView() {
        
        var length:CGFloat = (frame.width < frame.height) ? frame.width : frame.height
        length -= meterSpace * 2
        meterView.frame = CGRect(x: frame.width/2 - length/2,
                                 y: frame.height/2 - length/2,
                                 width: length,
                                 height: length)
        meterView.backgroundColor = UIColor.clear
        addSubview(meterView)
    }

    private func prepareDrawLayer() {
        
        drawLayer = CAShapeLayer()
        guard let drawLayer = drawLayer else {
            
            return
        }
        
        drawLayer.frame = meterView.bounds
        meterView.layer.addSublayer(drawLayer)
        drawLayer.cornerRadius = meterView.frame.width/2
        drawLayer.masksToBounds = true
        drawLayer.borderWidth = meterBorderLineWidth
        drawLayer.borderColor = meterBorderLineColor.cgColor
    }
    
    private func prepareValueIndexLayer() {
        
        guard let drawLayer = drawLayer else {
            
            return
        }
        
        let layer = CAShapeLayer()
        layer.frame = drawLayer.bounds
        drawLayer.addSublayer(layer)
        layer.strokeColor = valueIndexColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        
        var angle:Float = Float(Double.pi/2 + Double.pi)
        let radius = meterView.frame.width/2
        let centerPoint = CGPoint(x: radius, y: radius)
        let smallRadius = radius - (radius/10 + meterBorderLineWidth)
        
        let path = UIBezierPath()
        let angleUnit = (numberOfValue > 0) ? Float(Double.pi*2) / Float(numberOfValue) : 0.0
        
        // 中心から外への線描画
        for _ in 0..<numberOfValue {
            
            let point = CGPoint(x: centerPoint.x + radius * CGFloat(cosf(angle)),
                                y: centerPoint.y + radius * CGFloat(sinf(angle)))
            path.move(to: point)
            let point2 = CGPoint(x: centerPoint.x + smallRadius * CGFloat(cosf(angle)),
                                 y: centerPoint.y + smallRadius * CGFloat(sinf(angle)))
            path.addLine(to: point2)
            
            angle += angleUnit
        }
        
        layer.lineWidth = valueIndexWidth
        layer.path = path.cgPath
    }
    
    private func prepareValueLabel() {
        
        guard let dataSource = dataSource else {
            
            return
        }
        
        var angle:Float = Float(Double.pi/2 + Double.pi)
        let radius = meterView.frame.width/2
        let centerPoint = CGPoint(x: radius, y: radius)
        var smallRadius = radius - (radius/10 + meterBorderLineWidth)
        let length = radius/4
        smallRadius -= length/2
        
        let angleUnit = (numberOfValue > 0) ? Float(Double.pi*2) / Float(numberOfValue) : 0.0
        
        // 中心から外への線描画
        for index in 0..<numberOfValue {
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: length, height: length))
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .center
            label.textColor = valueLabelTextColor
            label.text = dataSource.meterView(meterView: self, valueForIndex: index)
            label.font = adjustFont(rect: label.frame)
            meterView.addSubview(label)
            let point = CGPoint(x: centerPoint.x + smallRadius * CGFloat(cosf(angle)),
                                y: centerPoint.y + smallRadius * CGFloat(sinf(angle)))
            label.center = point
            angle += angleUnit
        }
    }
    
    private func prepareValueHandLayer() {
        
        guard let drawLayer = drawLayer else {
            
            return
        }
        
        valueHandLayer = CAShapeLayer()
        guard let valueHandLayer = valueHandLayer else {
            
            return
        }
        
        valueHandLayer.frame = drawLayer.bounds
        drawLayer.addSublayer(valueHandLayer)
        valueHandLayer.strokeColor = valueHandColor.cgColor
        valueHandLayer.fillColor = UIColor.clear.cgColor
        
        let angle:Float = Float(Double.pi/2 + Double.pi)
        
        let radius = meterView.frame.width/2
        let length = radius * 0.8
        let centerPoint = CGPoint(x: radius, y: radius)
        
        let path = UIBezierPath()
        let point = CGPoint(x: centerPoint.x + length * CGFloat(cosf(angle)),
                            y: centerPoint.y + length * CGFloat(sinf(angle)))
        path.move(to: centerPoint)
        path.addLine(to: point)
        
        valueHandLayer.lineWidth = valueHandWidth
        valueHandLayer.path = path.cgPath
    }
    
    private func preparePanGesture() {
        
        guard let drawLayer = drawLayer else {
            
            return
        }
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(gesture:)))
        meterView.addGestureRecognizer(pan)
        let radius = meterView.frame.width/2
        let centerPoint = CGPoint(x: radius, y: radius)
        
        let path = UIBezierPath(ovalIn: CGRect(x: centerPoint.x - radius,
                                               y: centerPoint.y - radius,
                                               width: radius * 2,
                                               height: radius * 2))
        
        panLayer = CAShapeLayer()
        guard let panLayer = panLayer else {
            
            return
        }
        
        panLayer.frame = drawLayer.bounds
        drawLayer.insertSublayer(panLayer, at: 0)
        panLayer.strokeColor = UIColor.clear.cgColor
        panLayer.fillColor = meterColor.cgColor
        panLayer.path = path.cgPath
    }
    
    //MARK: Gesture Action
    @objc func panAction(gesture: UIPanGestureRecognizer) {
        
        guard let panLayer = panLayer else {
            
            return
        }
        
        let point = gesture.location(in: meterView)
        
        /// ジェスチャ開始
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
        guard let delegate = delegate else {
            
            return
        }
        
        let index = (radian - Float(Double.pi/2 + Double.pi)) / (Float(Double.pi*2) / Float(numberOfValue))
        delegate.meterView(meterView: self, didSelectAtIndex: Int(index))
    }
    
    //MARK:Draw ValueHand
    private func drawValueHandLayer(angle: Float) {
        
        guard let valueHandLayer = valueHandLayer else {
            
            return
        }
        
        let radius = meterView.frame.width/2
        let length = radius * 0.8
        let centerPoint = CGPoint(x: radius, y: radius)
        
        let path = UIBezierPath()
        let point = CGPoint(x: centerPoint.x + length * CGFloat(cosf(angle)),
                            y: centerPoint.y + length * CGFloat(sinf(angle)))
        path.move(to: centerPoint)
        path.addLine(to: point)
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        valueHandLayer.path = path.cgPath
        CATransaction.commit()
    }
    
    //MARK:Calculate
    private func calculateValueAngle(radian: Float) -> Float {
        
        let index:Int = Int((radian - Float(Double.pi/2 + Double.pi)) / (Float(Double.pi*2) / Float(numberOfValue)))
        let angle:Float = (Float(Double.pi*2) / Float(numberOfValue)) * Float(index)
        return angle + Float(Double.pi/2 + Double.pi)
    }
    
    private func calculateRadian(point: CGPoint) -> Float {
        
        // 原点　viewの中心
        let radius = meterView.frame.width/2
        let centerPoint = CGPoint(x: radius, y: radius)
        
        // 座標の差を求める 画面の上側をY座標＋とするので、Y座標は符号を入れ替える
        let x:Float = Float(point.x - centerPoint.x)
        let y:Float = -Float(point.y - centerPoint.y)
        // 角度radianを求める
        var radian:Float = atan2f(y, x)
        
        // radianに補正をする(3/2π~7/2π:0時が3/2π)
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
        
        let angle:Float = (Float(Double.pi*2) / Float(numberOfValue)) * Float(index)
        return angle + Float(Double.pi/2 + Double.pi)
    }
    
    private func adjustFont(rect: CGRect) -> UIFont {
        
        let length:CGFloat = (rect.width > rect.height) ? rect.height : rect.width
        let font = UIFont.systemFont(ofSize: length * 0.8)
        return font
    }
    
    //MARK:Clear/Reload
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
            
            numberOfValue = dataSource.numberOfValue(meterView: self)
        }
        
        prepareMeterView()
        prepareDrawLayer()
        prepareValueIndexLayer()
        prepareValueLabel()
        
        preparePanGesture()
        prepareValueHandLayer()
    }
    
    public func select(index: Int) {
        
        let angle = calculateAngle(index: index)
        nowAngle = angle
        drawValueHandLayer(angle: angle)
    }
}
