//
//  CloudflareWebview.swift
//  ViewComponents
//
//  Created by Inumaki on 17.06.24.
//

import Architecture
import UIKit
import WebKit

extension WKWebView {
    private var httpCookieStore: WKHTTPCookieStore { WKWebsiteDataStore.default().httpCookieStore }

    func getCookies(for domain: String? = nil, completion: @escaping ([String: Any]) -> Void) {
        var cookieDict = [String: AnyObject]()
        httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                    }
                } else {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }
}

public class CloudflareWebview: UIViewController, WKNavigationDelegate {

    // swiftlint:disable implicitly_unwrapped_optional
    var webView: WKWebView!
    // swiftlint:enable implicitly_unwrapped_optional
    public var urlString: String?

    // ui
    public let blurView: UIView = {
        let effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        view.layer.borderWidth = 0.5
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let wrapper: UIView = {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        return wrapper
    }()

    let cloudflareDetectedText: UILabel = {
        let label = UILabel()
        label.text = "CloudFlare detected!"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let doneButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.title = "Done"
        configuration.attributedTitle = AttributedString("Done", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.fg
        ]))

        let button = UIButton(configuration: configuration)

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let domainWrapper: UIView = {
        let view = UIView()
        view.layer.borderColor = ThemeManager.shared.getColor(for: .border).cgColor
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 6
        view.backgroundColor = ThemeManager.shared.getColor(for: .overlay)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let domainText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = ThemeManager.shared.getColor(for: .fg)
        label.alpha = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var completion: ([String: Any]?, Error?) -> Void

    public init(url: String, completion: (@escaping ([String: Any]?, Error?) -> Void)) {
        self.urlString = url
        self.completion = completion

        if let requestUrl = URL(string: url) {
            let userDefaults = UserDefaults.standard
            userDefaults.set(nil, forKey: "Cookies-\(requestUrl.getDomain() ?? "")")
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupUI()
        loadUrl()
    }

    func setupWebView() {
        webView = WKWebView(frame: self.view.frame)
        webView.customUserAgent = AppConstants.userAgent
        webView.navigationDelegate = self
        self.view.addSubview(webView)
    }

    func setupUI() {
        domainText.text = urlString
        domainWrapper.addSubview(domainText)

        wrapper.addSubview(blurView)
        wrapper.addSubview(doneButton)
        wrapper.addSubview(cloudflareDetectedText)
        wrapper.addSubview(domainWrapper)
        view.addSubview(wrapper)

        doneButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            wrapper.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wrapper.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wrapper.topAnchor.constraint(equalTo: view.topAnchor),

            blurView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: wrapper.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),

            doneButton.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 10),
            doneButton.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 12),

            cloudflareDetectedText.centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
            cloudflareDetectedText.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 20),

            domainWrapper.topAnchor.constraint(equalTo: cloudflareDetectedText.bottomAnchor, constant: 12),
            domainWrapper.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -12),
            domainWrapper.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            domainWrapper.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),

            domainText.leadingAnchor.constraint(equalTo: domainWrapper.leadingAnchor, constant: 8),
            domainText.trailingAnchor.constraint(equalTo: domainWrapper.trailingAnchor, constant: -8),
            domainText.topAnchor.constraint(equalTo: domainWrapper.topAnchor, constant: 8),
            domainText.bottomAnchor.constraint(equalTo: domainWrapper.bottomAnchor, constant: -8)
        ])
    }

    func loadUrl() {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    @objc func buttonTapped() {
        webView.getCookies { cookies in
            self.completion(cookies, nil)
        }
    }

    // WKNavigationDelegate methods can be implemented here if needed
}
