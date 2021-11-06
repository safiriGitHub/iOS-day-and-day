//
//  Texti18nViewController.swift
//  i18n-Demo
//
//  Created by safiri on 2021/11/6.
//

import UIKit

class Texti18nViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let testLabel = UILabel()
        testLabel.frame = CGRect(x: 70, y: 100, width: 200, height: 33)
        testLabel.textColor = .red
        view.addSubview(testLabel)
        
        // 中文下显示首页
        // 英文下显示Home
        testLabel.text = NSLocalizedString("首页", comment: "f")
        
        
        let testLabel2 = UILabel()
        testLabel2.frame = CGRect(x: 70, y: 222, width: 200, height: 33)
        testLabel2.textColor = .red
        view.addSubview(testLabel2)
        // 因为没有配置“哇咔咔”，故中文英文都会显示“哇咔咔”
        testLabel2.text = NSLocalizedString("哇咔咔", comment: "")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
