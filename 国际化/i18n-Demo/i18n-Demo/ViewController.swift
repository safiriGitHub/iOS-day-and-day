//
//  ViewController.swift
//  i18n-Demo
//
//  Created by safiri on 2021/11/5.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var texti18nButton: UIButton!
    @IBOutlet weak var xib1i18nButton: UIButton!
    @IBOutlet weak var xib2i18nButton: UIButton!
    
    fileprivate var languageBgView: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func texti18nButtonClick(_ sender: Any) {
        navigationController?.pushViewController(Texti18nViewController(), animated: true)
    }
    
    @IBAction func xib1i18nButton(_ sender: Any) {
        navigationController?.pushViewController(TestGjhViewController(nibName: "TestGjhViewController", bundle: nil), animated: true)
    }
    @IBAction func xib2i18nButtonClick(_ sender: Any) {
        navigationController?.pushViewController(TestGjh2ViewController(nibName: "TestGjh2ViewController", bundle: nil), animated: true)
    }
    
    // MARK:切换语言
    @IBAction func changeLanguageInApp(_ sender: Any)
    {
        if(languageBgView == nil){
            languageBgView = UIButton(frame: UIScreen.main.bounds)
            languageBgView?.backgroundColor = UIColor(red:0.000 , green:0.000 , blue:0.000, alpha:0.8)
            languageBgView?.addTarget(self, action: #selector(hide), for: .touchUpInside)
            
            let languageView = UIView(frame: CGRect(x: 0, y: languageBgView!.frame.size.height - 200, width: languageBgView!.frame.size.width, height: 200))
            self.languageBgView?.addSubview(languageView)
            languageView.backgroundColor = UIColor.white
            
            let topView = UIView(frame: CGRect(x: 0, y: 0, width: languageView.frame.size.width, height: 40))
            languageView.addSubview(topView)
            
            let cancelBtn = UIButton(frame: CGRect(x: 10, y: 0, width: 60, height: 40))
            cancelBtn.tag = 10
            cancelBtn.setTitleColor(UIColor(red:0.949 , green:0.349 , blue:0.122, alpha:1.0)
                                    , for: .normal)
            cancelBtn.addTarget(self, action: #selector(hide), for: .touchUpInside)
            topView.addSubview(cancelBtn)
            
            let changeBtn = UIButton(frame: CGRect(x: topView.frame.size.width-70, y: 0, width: 70, height: 40))
            changeBtn.tag = 11
            changeBtn.setTitleColor(UIColor(red:0.949 , green:0.349 , blue:0.122, alpha:1.0)
                                    , for: .normal)
            changeBtn.addTarget(self, action: #selector(change), for: .touchUpInside)
            topView.addSubview(changeBtn)
            
            self.pickerView = UIPickerView(frame: CGRect(x: 0, y: 40, width: languageView.frame.size.width, height: languageView.frame.size.height-40))
            self.pickerView.dataSource = self
            self.pickerView.delegate = self
            languageView.addSubview(self.pickerView)
        }
        let languagesVal = Array(APPLanguages.values)
        self.pickerView.selectRow(languagesVal.firstIndex(of: Languager.sharedInstance.currentLanguage)!, inComponent: 0, animated: false)
        
        (languageBgView?.viewWithTag(10) as! UIButton).setTitle(LocalizedAPP("取消"), for: .normal)
        (languageBgView?.viewWithTag(11) as! UIButton).setTitle(LocalizedAPP("切换"), for: .normal)
        UIApplication.shared.keyWindow?.addSubview(self.languageBgView!)
        
        
        
    }
    
    @objc func hide(){
        self.languageBgView?.removeFromSuperview()
    }
    
    @objc func change() {
        let row = self.pickerView.selectedRow(inComponent: 0)
        let key = Array(APPLanguages.keys)[row]
        
        //切换语言
        Languager.sharedInstance.currentLanguage = APPLanguages[key]!
        self.hide()
        
        
        //重新设置root viewcontroller，重新加载时会加载切换后的语言资源
        let mainSb = UIStoryboard(name: "Main", bundle: nil)
        let rootViewC = mainSb.instantiateInitialViewController() as! UINavigationController
        
        UIApplication.shared.delegate?.window??.rootViewController = rootViewC
    }
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: view.frame.size.height-150, width: view.frame.size.width, height: 150))
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
}

extension ViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return APPLanguages.count
    }
    
    func pickerView(_ pickerView: UIPickerView,titleForRow row:Int,forComponent component:Int) -> String? {
        return Array(APPLanguages.values)[row]
    }
}

