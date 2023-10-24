import class Foundation.Bundle

extension Foundation.Bundle {
    static let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("ZIPFoundation_ZIPFoundation.bundle").path
        let buildPath = "/Users/inumaki/development/ChoutenDevelopment/ChoutenApp/Chouten/.build/arm64-apple-macosx/debug/ZIPFoundation_ZIPFoundation.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}