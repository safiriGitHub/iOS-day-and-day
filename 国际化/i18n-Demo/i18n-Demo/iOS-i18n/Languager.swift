//
//  Languager.swift
//  i18n-Demo
//
//  Created by safiri on 2021/11/6.
//

import Foundation
import UIKit

/// UserDefaults获取APP支持语言的约定key
private let kUserLanguage = "AppleLanguages"

class Languager {
    
    static let sharedInstance = Languager()
    private init() {
        initLanguages()
    }
    
    // 初始化配置
    func initLanguages() {
        guard let language = (UserDefaults.standard.object(forKey: kUserLanguage) as? [String])?.first else {
            assert(false, "未知错误，获取APP语言失败")
            return
        }
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
            let bundle = Bundle(path: path) {
            currentLanguageBundle = bundle
            _currentLanguage = language
        }else {
            // 当前语言无法加载--不支持
            // 则加载info中Localization native development region中的值的lporj,设置为当前语言
            if let l = Bundle.main.infoDictionary?[kCFBundleDevelopmentRegionKey as String] as? String {
                self.currentLanguage = l
                print("Languager:\(language)不支持，切换成默认语言\(self._currentLanguage!)")
            }else {
                assert(false, "未知错误，获取APP语言失败")
            }
        }
    }
    
    // MARK: getter setter
    /// 当前语言获取与切换
    var currentLanguage: String {
        get {
            if _currentLanguage == nil {
                _currentLanguage = (UserDefaults.standard.object(forKey: kUserLanguage) as! [String]).first!
            }
            return _currentLanguage!
        }
        set {
            if _currentLanguage == newValue {
                return
            }
            if let path = Bundle.main.path(forResource: newValue, ofType: "lproj"),
                let bundle = Bundle(path: path) {
                currentLanguageBundle = bundle
                _currentLanguage = newValue
            }else {
                if let defaultLanguage = Bundle.main.infoDictionary?[kCFBundleDevelopmentRegionKey as String] as? String,
                    let path = Bundle.main.path(forResource: defaultLanguage, ofType: "lproj"),
                    let bundle = Bundle(path: path) {
                    _currentLanguage = defaultLanguage
                    currentLanguageBundle = bundle
                }else {
                    assert(false, "未知错误，获取APP语言失败")
                }
            }
            UserDefaults.standard.setValue([_currentLanguage!], forKey: kUserLanguage)
            Bundle.main.onLanguage()
        }
    }
    
    // MARK: params
    
    /// 当前语言
    fileprivate var _currentLanguage: String?
    
    /// 当前语言对应Bundle
    var currentLanguageBundle: Bundle?
    
}

extension Languager {
    /**
     获取当前语言的storyboard
     */
    func storyboard(_ name: String) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: self.currentLanguageBundle)
    }
    
    /**
     获取当前语言的nib
     */
    func nib(_ name: String) -> UINib {
        return UINib(nibName: name, bundle: self.currentLanguageBundle)
    }
    
    /**
     获取当前语言的string
     */
    func string(_ key: String, table tableName: String? = nil) -> String {
        if let str = self.currentLanguageBundle?.localizedString(forKey: key, value: nil, table: tableName) {
            return str
        }
       
        return key
    }
}

func LocalizedAPP(_ key: String) -> String {
    return Languager.sharedInstance.string(key, table: nil)
}
func LocalizedAPP(_ key: String, table tableName: String? = nil) -> String {
    return Languager.sharedInstance.string(key, table: tableName)
}
