//
//  NSBundle+Language.swift
//  i18n-Demo
//
//  Created by safiri on 2021/11/6.
//

import Foundation
import Network

/**
 *  当调用onLanguage后替换掉mainBundle为当前语言的bundle
 */
class BundleEx: Bundle {
    
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = languageBundle() {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        } else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
}

extension Bundle {
    
    //代替dispatch_once
    private static var onLanguageDispatchOnce: ()->Void = {
        object_setClass(Bundle.main, BundleEx.self)
    }
    
    func onLanguage() {
        //替换NSBundle.mainBundle()的class为自定义的BundleEx，这样一来我们就可以重写方法
        Bundle.onLanguageDispatchOnce()
    }
    
    //当前语言的bundle
    func languageBundle() -> Bundle? {
        return Languager.sharedInstance.currentLanguageBundle
    }
}

extension String {
    var loca: String {
        return NSLocalizedString(self, comment: "")
    }
}

extension Array where Element == String {
    func loca() -> [String] {
        return self.map { NSLocalizedString($0, comment: "") }
    }
}
