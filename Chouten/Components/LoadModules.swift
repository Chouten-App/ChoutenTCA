//
//  LoadModules.swift
//  Chouten
//
//  Created by Resty on 12.01.25.
//

import Core
import Dependencies



func loadSelectedModule() -> (RepoModule, RepoMetadata)? {
    @Dependency(\.repoClient) var repoClient
    
    do {
        let repos = try repoClient.getRepos()
        
        for repo in repos {
            let selectedModuleId = UserDefaults.standard.string(forKey: "selectedModuleId")
            
            if let modules = repo.modules {
                for module in modules {
                    if module.id == selectedModuleId {
                        return (module, repo)
                    }
                }
            }
        }
    } catch {
        print("Error loading repositories: \(error.localizedDescription)")
    }
    
    return nil
}


func getIconData(for module: RepoModule, repo: RepoMetadata, completion: @escaping (String?) -> Void) {
    DispatchQueue.global(qos: .background).async {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        if let imageUrl = documentsDirectory?
            .appendingPathComponent("Repos")
            .appendingPathComponent(repo.id)
            .appendingPathComponent("Modules")
            .appendingPathComponent(module.id) {
            
            // Try loading the image as JPG
            if (try? Data(contentsOf: imageUrl.appendingPathComponent("icon.jpg"))) != nil {
                let imagePath = imageUrl.appendingPathComponent("icon.jpg").path
                DispatchQueue.main.async {
                    completion(imagePath)
                }
                return
            }
            // Try loading the image as PNG if JPG is unavailable
            else if (try? Data(contentsOf: imageUrl.appendingPathComponent("icon.png"))) != nil {
                let imagePath = imageUrl.appendingPathComponent("icon.png").path
                DispatchQueue.main.async {
                    completion(imagePath)
                }
                return
            }
        }
        DispatchQueue.main.async {
            completion(nil)
        }
    }
}
