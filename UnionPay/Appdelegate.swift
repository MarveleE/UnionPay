//
//  Appdelegate.swift
//  UnionPay
//
//  Created by grochgen on 2023/8/23.
//

import Foundation

class AppDelegate: NSObject, UIApplicationDelegate {

    var onUrlOpened: ((String) -> Void)?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Your code here")
        return true
    }
}

extension UIApplication {

    static var onUrlOpened: ((String) -> Void)?

    static var canJump: Bool = false

    @objc func hooked_openURL(_ url: URL) -> Bool {
        print("Hooked openURL: \(url)")
        UIApplication.onUrlOpened?(url.absoluteString)
        if UIApplication.canJump {
            return hooked_openURL(url)
        }
        return false
    }

    static func swizzleOpenURL() {
        let originalSelector = #selector(openURL(_:))
        let swizzledSelector = #selector(hooked_openURL(_:))

        guard
            let originalMethod = class_getInstanceMethod(UIApplication.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(UIApplication.self, swizzledSelector)
        else {
            return
        }

        let didAddMethod = class_addMethod(
            UIApplication.self,
            originalSelector,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod)
        )

        if didAddMethod {
            class_replaceMethod(
                UIApplication.self,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod)
            )
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}
