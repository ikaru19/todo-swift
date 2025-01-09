//
//  SceneDelegate.swift
//  todo-swift
//
//  Created by Admin on 09/01/25.
//

import UIKit
import RealmSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        // Buat window dan atur rootViewController
        let window = UIWindow(windowScene: windowScene)
        let realm = try! Realm()
        let viewModel = TaskListViewModel(realm: realm)
        window.rootViewController = UINavigationController(rootViewController: TaskListViewController(viewModel: viewModel))
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
