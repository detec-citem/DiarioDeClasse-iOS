//
//  AppDelegate.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 26/06/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import Firebase
import IQKeyboardManagerSwift
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    //MARK: Variables
    var window: UIWindow?

    //MARK: Methods
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        #if DEBUG
        #else
            FirebaseApp.configure()
        #endif
        IQKeyboardManager.shared.enable = true
        UITabBar.appearance().tintColor = Cores.defaultApp
        let tableViewAppearance = UITableView.appearance()
        tableViewAppearance.backgroundColor = .white
        tableViewAppearance.tableFooterView = UIView()
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.tintColor = .white
        navigationBarAppearance.isTranslucent = false
        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationBarAppearance.barTintColor = Cores.defaultApp
        navigationBarAppearance.backgroundColor = Cores.defaultApp
        var controller: UIViewController?
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let usuarioLogado = UsuarioDao.usuarioLogado()
        if usuarioLogado == nil {
            controller = storyboard.instantiateViewController(withIdentifier: LoginViewController.className)
        }
        else {
            LoginRequest.usuarioLogado = usuarioLogado
            controller = storyboard.instantiateViewController(withIdentifier: MenuViewController.className)
        }
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillTerminate(_: UIApplication) {
        CoreDataManager.sharedInstance.salvarBanco()
    }
}
