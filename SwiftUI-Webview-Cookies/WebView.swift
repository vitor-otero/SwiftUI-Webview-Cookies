//
//  WebView.swift
//  SwiftUI-Webview-Cookies
//
//  Created by Vítor Otero on 26/03/2023.
//

import SwiftUI
import WebKit

struct WebView : UIViewRepresentable {
    let request: URLRequest
    var webview: WKWebView?
    
    init(web: WKWebView?, req: URLRequest) {
        self.webview = WKWebView()
        self.request = req
    }
    
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate{
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // Delegate methods go here
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            // alert functionality goes here
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            UIView.animate(withDuration: 0.3) {
                webView.isHidden = true
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            UIView.animate(withDuration: 0.3, animations: {
                webView.isHidden = false
                webView.scrollView.contentMode = .scaleAspectFit
            })}
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print(error)
        }
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Check if the navigation action is a link click
            if navigationAction.navigationType == .linkActivated {
                // Check if the link URL is for Outlook or OneDrive
                if let url = navigationAction.request.url,
                   (url.scheme == "ms-outlook" || url.scheme == "ms-onedrive") {
                    // Open the URL in the native app
                    UIApplication.shared.open(url)
                    webView.isHidden = false
                    // Cancel the web view navigation
                    decisionHandler(.cancel)
                    return
                }
            }
            
            // Allow the web view navigation
            //load cookie of current domain
            webView.loadDiskCookies(for: url.host!) {
                decisionHandler(.allow)
            }
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            //write cookie for current domain
            webView.writeDiskCookies(for: url.host!){
                decisionHandler(.allow)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        return webview!
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.uiDelegate = context.coordinator
        uiView.navigationDelegate = context.coordinator
        uiView.load(request)
    }
    
    func goHome(){
        webview?.load(URLRequest(url: URL(string: "https://www.google.com")!))
    }
    
    func reload(){
        webview?.reload()
    }
}

extension WKWebView {
    
    enum PrefKey {
        static let cookie = "cookies"
    }
    
    func writeDiskCookies(for domain: String, completion: @escaping () -> ()) {
        fetchInMemoryCookies(for: domain) { data in
            print("write data", data)
            UserDefaults.standard.setValue(data, forKey: PrefKey.cookie + domain)
            completion();
        }
    }
    
    func loadDiskCookies(for domain: String, completion: @escaping () -> ()) {
        if let diskCookie = UserDefaults.standard.dictionary(forKey: (PrefKey.cookie + domain)){
            fetchInMemoryCookies(for: domain) { freshCookie in
                let mergedCookie = diskCookie.merging(freshCookie) { (_, new) in new }
                for (_, cookieConfig) in mergedCookie {
                    let cookie = cookieConfig as! Dictionary<String, Any>
                    var expire : Any? = nil
                    if let expireTime = cookie["Expires"] as? Double{
                        expire = Date(timeIntervalSinceNow: expireTime)
                    }
                    
                    let newCookie = HTTPCookie(properties: [
                        .domain: cookie["Domain"] as Any,
                        .path: cookie["Path"] as Any,
                        .name: cookie["Name"] as Any,
                        .value: cookie["Value"] as Any,
                        .secure: cookie["Secure"] as Any,
                        .expires: expire as Any
                    ])
                    self.configuration.websiteDataStore.httpCookieStore.setCookie(newCookie!)
                }
                completion()
            }
        }
        else{
            completion()
        }
    }
    
    func fetchInMemoryCookies(for domain: String, completion: @escaping ([String: Any]) -> ()) {
        var cookieDict = [String: AnyObject]()
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
            for cookie in cookies {
                if cookie.domain.contains(domain) {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }}

let url = URL(string: "https://www.google.com")!

