//
//  TestGjh2ViewController.swift
//  TouchainNFT
//
//  Created by safiri on 2021/11/5.
//

import UIKit

class TestGjh2ViewController: UIViewController {

    @IBOutlet weak var testLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        testLabel.text = NSLocalizedString("Year", comment: "")
        testLabel.textColor = .red
        /// xib国际化示例2
        /// localization 选择 Base  English:Localizable Strings Chinese: Localizable Strings
        /// xib只添加label，在strings文件中会生成相对于的配置文字代码
        /// 如：
        /// ```
        /// /* Class = "UILabel"; text = "Label"; ObjectID = "Ima-pm-Edd"; */
        /// "Ima-pm-Edd.text" = "我为你做了一切";
        /// ```
        /// 在其他语言文件中同样进行配置，就可实现国际化
        /// ```
        /// /* Class = "UILabel"; text = "Label"; ObjectID = "Ima-pm-Edd"; */
        /// "Ima-pm-Edd.text" = "i do everything for everything for you";
        /// ```
        /// 在对应的viewcontroller文件中，可对label进行设置
        /// `testLabel.text = NSLocalizedString("Year", comment: "")`
        ///
        
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
