//
//  AlignmentRectViewController.swift
//  AutoLayoutDaily
//
//  Created by safiri on 2021/10/27.
//  利用 Autolayout 实现 view 间隔自动调整

import UIKit

class AlignmentRectViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "alignmentRect让view间隔自动调整"
        view.backgroundColor = .white
        
        let label1 = ARLabel()
        label1.text = "白日依山尽，黄河入海流。\n欲穷千里目，更上一层楼。"
        label1.numberOfLines = 2
        label1.backgroundColor = .red
        view.addSubview(label1)
        
        let label2 = ARLabel()
        label2.text = "红豆生南国，春来发几枝。\n愿君多采撷，此物最相思。"
        label2.numberOfLines = 0
        label2.backgroundColor = .yellow
        view.addSubview(label2)
        
        let label3 = ARLabel()
        label3.text = "千山鸟飞绝，万径人踪灭。\n孤舟蓑笠翁，独钓寒江雪。"
        label3.numberOfLines = 0
        label3.backgroundColor = .purple
        view.addSubview(label3)
        
        let label4 = ARLabel()
        label4.text = "春种一粒粟，秋收万颗子。\n四海无闲田，农夫犹饿死。"
        label4.numberOfLines = 0
        label4.backgroundColor = .brown
        view.addSubview(label4)
        
        label1.translatesAutoresizingMaskIntoConstraints = false
        label2.translatesAutoresizingMaskIntoConstraints = false
        label3.translatesAutoresizingMaskIntoConstraints = false
        label4.translatesAutoresizingMaskIntoConstraints = false
        label1.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        if #available(iOS 11.0, *) {
            label1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        } else {
            label1.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 100).isActive = true
        }
        
        label2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label2.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 0).isActive = true
        
        label3.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label3.topAnchor.constraint(equalTo: label2.bottomAnchor).isActive = true
        
        label4.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label4.topAnchor.constraint(equalTo: label3.bottomAnchor).isActive = true
    
        
        //test
//        label2.text = nil
//        label3.text = nil
    }
    
    
    
}

class ARLabel: UILabel {
    
    override var alignmentRectInsets: UIEdgeInsets {
        //希望 alignment rect 比 frame 的下边多 20 个点，可以这些写：
        return UIEdgeInsets(top: 0, left: 0, bottom: -20, right: 0)
    }
}
