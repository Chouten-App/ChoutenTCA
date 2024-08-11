//
//  SceneDelegate.swift
//  ChoutenApp
//
//  Created by Inumaki on 17.10.23.
//

import App
import ComposableArchitecture
import RelayClient
import RepoClient
import SharedModels
import SwiftUI
import UIKit

extension Notification.Name {
    static let sharedJson = Notification.Name("com.inumaki.chouten.module")
}

extension URL {
    func isReachable(completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { _, response, _ in
            completion((response as? HTTPURLResponse)?.statusCode == 200)
        }.resume()
    }
}

// MARK: - SceneDelegate

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    @Dependency(\.repoClient) var repoClient
    @Dependency(\.relayClient) var relayClient
    var window: UIWindow?
    let userDefaults = UserDefaults.standard

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedSelectedModule(_:)), name: .updatedSelectedModule, object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(handleSharedJson(_:)), name: .sharedJson, object: nil)

        var module: Module?
        do {
            if let moduleId = userDefaults.string(forKey: "selectedModuleId") {
                let modulePath = try repoClient.getModulePathForId(id: moduleId)

                if let modulePath {
                    module = try relayClient.loadModule(
                        fileURL: modulePath
                    )
                }
            }
        } catch {
            print(error.localizedDescription)
        }

        if let urlContext = connectionOptions.urlContexts.first {
            handleOpenURL(urlContext.url)
        }

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = SplashScreenViewController(module) // AppViewController(module)
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

    func scene(_: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        let components: NSURLComponents? = NSURLComponents(url: url, resolvingAgainstBaseURL: false)

        switch components?.host {
        case "addRepo":
            let repoUrl = components?.queryItems?.first?.value
            // install repo
            if let repoUrl, let checkedUrl = URL(string: repoUrl) {
                Task {
                    do {
                        try await repoClient.installRepo(checkedUrl)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        case "addModule":
            break
        default:
            break
        }

        /*
         if url.pathExtension == "module" {
         print("importing.")

         // Handle the file here
         // For example, you could use FileManager to copy the file to your app's documents directory:
         let fileManager = FileManager.default
         do {
         let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
         let destinationURL = documentsURL.appendingPathComponent("Modules").appendingPathComponent(url.lastPathComponent)
         try fileManager.copyItem(at: url, to: destinationURL)

         try moduleClient.importFromFile(destinationURL)
         // Update globalData.availableModules here
         do {
         let modules = try moduleClient.getModules()
         // globalData.setAvailableModules(modules)
         } catch {
         print("Error: \(error)")
         }

         } catch {
         print("Error: \(error)")
         }
         } else if url.pathExtension == "theme" {
         // Handle the file here
         // For example, you could use FileManager to copy the file to your app's documents directory:
         let fileManager = FileManager.default
         do {
         let documentsURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
         let destinationURL = documentsURL.appendingPathComponent("Themes").appendingPathComponent(url.lastPathComponent)
         try fileManager.copyItem(at: url, to: destinationURL)
         } catch {
         print("Error: \(error)")
         }
         }
         */
    }

    func handleOpenURL(_ url: URL) {
        //print(url)
        // NotificationCenter.default.post(name: .sharedJson, object: nil, userInfo: ["url": url])
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

    @objc
    func handleSharedJson(_ notification: Notification) {
        guard notification.userInfo?["url"] is URL else { return }
        if let shouldOpenApp = notification.userInfo?["openApp"] as? Bool, shouldOpenApp {
            // Open the app
//            do {
//                // let modules = try moduleClient.getModules()
//                // globalData.setAvailableModules(modules)
//            } catch {
//                print(error.localizedDescription)
//            }

            if let window {
                let hostingController = AppViewController(nil)
                window.rootViewController = hostingController
                window.makeKeyAndVisible()
            }
        }
    }
}
