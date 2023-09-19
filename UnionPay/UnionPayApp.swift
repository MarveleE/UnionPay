//
//  UnionPayApp.swift
//  UnionPay
//
//  Created by grochgen on 2023/8/23.
//

import SwiftUI

@main
struct UnionPayApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var viewModel: ViewModel = ViewModel()

    init() {
        UIApplication.swizzleOpenURL()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onAppear {
                    UIApplication.onUrlOpened = { url in
                        self.viewModel.url = url
                    }
                }
        }
    }
}
