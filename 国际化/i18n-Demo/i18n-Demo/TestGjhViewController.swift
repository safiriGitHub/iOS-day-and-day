//
//  TestGjhViewController.swift
//  TouchainNFT
//
//  Created by safiri on 2021/11/5.
//

import UIKit

class TestGjhViewController: UIViewController {
    @IBOutlet weak var enTestLabel: UILabel!
    @IBOutlet weak var enTestLabel2: UILabel!
    @IBOutlet weak var chTestLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // xib 国际化：
        // 此示例都选择Interface Builder CocoaTouch Xib 选项
        // 中文下显示中文xib的内容
        // 英文下显示英文xib的内容
        // 这样的话是维护两套xib的内容
        
        
        //获取APP的语言数组
        //let appLanguages = UserDefaults.standard.object(forKey: "AppleLanguages")
        if let appLanguages = UserDefaults.standard.object(forKey: "AppleLanguages") as? [String], let languageName = appLanguages.first {
            
            if languageName == "zh-Hans-US" {
                chTestLabel.text = "全世界都在说中国话"
            } else if languageName == "en" {
                enTestLabel.text = "what??"
                enTestLabel2.text = "english is hard"
            }
        }
        
        //ex
        //获取当前设备支持的所有语言
        // 获取当前设备支持语言数组
        let arr = NSLocale.availableLocaleIdentifiers
        print(arr) //很多
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
