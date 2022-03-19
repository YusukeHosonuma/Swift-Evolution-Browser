//
//  File.swift
//  
//
//  Created by 細沼祐介 on 2022/03/10.
//

import Foundation
import SwiftUI
import WebKit

public class WebViewCoordinator: NSObject, WKNavigationDelegate {
    let isLoading: Binding<Bool>
    
    public init(isLoading: Binding<Bool>) {
        self.isLoading = isLoading
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.isLoading.wrappedValue = false
    }
}

#if os(macOS)
public struct WebView: NSViewRepresentable {
    private let url: URL
    private let isLoading: Binding<Bool>
    
    public init(url: URL, isLoading: Binding<Bool>) {
        self.url = url
        self.isLoading = isLoading
    }
    
    public func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    public func updateNSView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.navigationDelegate = context.coordinator
        webView.load(request)
    }
    
    public func makeCoordinator() -> WebViewCoordinator {
        .init(isLoading: isLoading)
    }
}
#else
public struct WebView: UIViewRepresentable {
    private let url: URL
    private let isLoading: Binding<Bool>
    
    public init(url: URL, isLoading: Binding<Bool>) {
        self.url = url
        self.isLoading = isLoading
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.navigationDelegate = context.coordinator
        webView.load(request)
    }

    public func makeCoordinator() -> WebViewCoordinator {
        .init(isLoading: isLoading)
    }
}
#endif
