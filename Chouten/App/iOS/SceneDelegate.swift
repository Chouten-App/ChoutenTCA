//
//  SceneDelegate.swift
//  Chouten
//
//  Created by Inumaki on 13/10/2024.
//

import Dependencies
import UIKit

extension Notification.Name {
    static let changedModule = Notification.Name("ChangedModule")
    static let updatedSelectedModule = Notification.Name("UpdatedSelectedModule")
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    @Dependency(\.relayClient) var relayClient
    @Dependency(\.repoClient) var repoClient
    var window: UIWindow?
    let userDefaults = UserDefaults.standard
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedSelectedModule(_:)), name: .updatedSelectedModule, object: nil)
        
        var module: Module?
        do {
            if let moduleId = userDefaults.string(forKey: "selectedModuleId") {
                
                let modulePath = try repoClient.getModulePathForId(id: moduleId)

                if let modulePath {
                    module = try relayClient.loadModule(
                        fileURL: modulePath
                    )
                }
            } else {
                let defaultValues: [String: Any] = [
                    "selectedModuleId": ""
                ]
                userDefaults.register(defaults: defaultValues)
            }
        } catch {
            print(error.localizedDescription)
        }

        if let urlContext = connectionOptions.urlContexts.first {
            // handleOpenURL(urlContext.url)
        }

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = EntryController(module)
            self.window = window
            window.makeKeyAndVisible()

            let currentStyle = userDefaults.integer(forKey: "currentStyle")

            switch currentStyle {
            case 0:
                window.overrideUserInterfaceStyle = .dark
            case 1:
                window.overrideUserInterfaceStyle = .light
            case 2:
                window.overrideUserInterfaceStyle = .unspecified
            default:
                window.overrideUserInterfaceStyle = .dark
            }

        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    @objc func handleUpdatedSelectedModule(_ notification: Notification) {
        // Handle the notification here
        do {
            if let moduleId = userDefaults.string(forKey: "selectedModuleId") {
                let modulePath = try repoClient.getModulePathForId(id: moduleId)

                if let modulePath {
                    var module = try relayClient.loadModule(
                        fileURL: modulePath
                    )
                    NotificationCenter.default.post(name: .changedModule, object: module)
                }

            }
        } catch {
            print(error.localizedDescription)
        }
        // Perform actions in SceneDelegate based on the notification
        // Example: Change scene-related configurations, update UI, etc.
    }
}

