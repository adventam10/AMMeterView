//
//  ViewController.swift
//  SampleAMMeter
//
//  Created by am10 on 2018/01/08.
//  Copyright © 2018年 am10. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mView1: AMMeterView!
    @IBOutlet weak var mView2: AMMeterView!
    @IBOutlet weak var mView3: AMMeterView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    let meterList1 = ["0", "5", "10", "15", "20", "30"]
    let meterList2 = ["A", "B", "C", "D", "E", "F", "G", "H"]
    let meterList3 = ["りんご", "バナナ", "メロン", "グレープ\nフルーツ", "ドラゴン\nフルーツ"]
    let colors: [UIColor] = [.black, .red, .blue, .magenta, .purple, .orange, .brown, .white]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mView1.delegate = self
        mView2.delegate = self
        mView3.delegate = self
        mView1.dataSource = self
        mView2.dataSource = self
        mView3.dataSource = self
        
        label1.text = "selected value: " + meterList1[mView1.selectedIndex]
        label2.text = "selected value: " + meterList2[mView2.selectedIndex]
        label3.text = "selected value: " + meterList3[mView3.selectedIndex]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func getMeterList(meterView: AMMeterView) -> [String] {
        if meterView == mView2 {
            return meterList2
        } else if meterView == mView3 {
            return meterList3
        }
        return meterList1
    }
}

extension ViewController: AMMeterViewDelegate, AMMeterViewDataSource {
    func numberOfValue(in meterView: AMMeterView) -> Int {
        return getMeterList(meterView: meterView).count
    }
    
    func meterView(_ meterView: AMMeterView, titleForValueAtIndex index: Int) -> String {
        return getMeterList(meterView: meterView)[index]
    }
    
    func meterView(_ meterView: AMMeterView, didSelectAtIndex index: Int) {
        let list = getMeterList(meterView: meterView)
        if meterView == mView1 {
            label1.text = "selected value: " + list[index]
        } else if meterView == mView2 {
            label2.text = "selected value: " + list[index]
        } else if meterView == mView3 {
            label3.text = "selected value: " + list[index].replacingOccurrences(of: "\n", with: "")
            mView1.selectValue(at: 3)
        }
    }
    
    func meterView(_ meterView: AMMeterView, textColorForValueAtIndex index: Int) -> UIColor {
        return meterView == mView2 ? colors[index] : .black
    }
    
    func meterView(_ meterView: AMMeterView, textFontForValueAtIndex index: Int) -> UIFont {
        if meterView != mView3 {
            return .systemFont(ofSize: 15)
        }
        return  index == 4 ? .boldSystemFont(ofSize: 10) : .systemFont(ofSize: 15)
    }
}

