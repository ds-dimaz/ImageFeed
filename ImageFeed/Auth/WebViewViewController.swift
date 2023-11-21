import Foundation
import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    weak var delegate: AuthViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            context: nil
        )
    }
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        webView.navigationDelegate = self
        
        var urlComponents = URLComponents(string: UnsplashAuthorizationPath)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: AccessScope)
        ]
        let url = urlComponents.url!
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        webView.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress)
        )
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        
        // Я прилепил такой костыль, потому что мне не нравится, что при использовании простого
        // progressView.isHidden = abs(webView.estimatedProgress - 1.0) <= 0.0001
        // мы видим progressView когда контент webView уже загрузился
        // а с такой небольшой задержкой всё как раз показывается как надо
        
        if abs(webView.estimatedProgress - 1.0) <= 0.0001 {
            progressView.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.webView.isHidden = false
            }
        } else {
            webView.isHidden = true
            progressView.isHidden = false
        }
    }
    
    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

protocol WebViewViewControllerDelegate: AnyObject {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
    
}
