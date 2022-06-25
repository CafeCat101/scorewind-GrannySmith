//
//  WebView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/5/24.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import WebKit
import AVKit

// MARK: - WebViewHandlerDelegate
// For printing values received from web app
protocol WebViewHandlerDelegate {
	func receivedJsonValueFromWebView(value: [String: Any?])
	func receivedStringValueFromWebView(value: String)
}

// MARK: - WebView
struct WebView: UIViewRepresentable, WebViewHandlerDelegate {
	var url: WebUrlType
	// Viewmodel object
	@ObservedObject var viewModel: ViewModel
	//var score: String
	//var linkVideoPlayer: AVPlayer?
	@ObservedObject var scorewindData: ScorewindData
	
	func receivedJsonValueFromWebView(value: [String : Any?]) {
		print("JSON value received from web is: \(value)")
		//viewModel.videoPlayer?.pause()
		//viewModel.playerGoTo()
	}
	
	func receivedStringValueFromWebView(value: String) {
		print("String value received from web is: \(value)")
		if value.isEmpty == false {
			viewModel.videoPlayer?.pause()
			let valueDouble = Double(value)!
			viewModel.playerGoTo(timestamp:Double(String(format: "%.3f", valueDouble))!)
		}
		
	}
	
	// Make a coordinator to co-ordinate with WKWebView's default delegate functions
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	func makeUIView(context: Context) -> WKWebView {
		// Enable javascript in WKWebView
		let preferences = WKPreferences()
		preferences.javaScriptEnabled = true
		
		let configuration = WKWebViewConfiguration()
		configuration.allowsInlineMediaPlayback = true
		// Here "iOSNative" is our delegate name that we pushed to the website that is being loaded
		configuration.userContentController.add(self.makeCoordinator(), name: "iOSNative")
		configuration.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
		configuration.preferences = preferences
		
		let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
		webView.navigationDelegate = context.coordinator
		webView.allowsBackForwardNavigationGestures = false
		webView.scrollView.isScrollEnabled = false
		webView.isMultipleTouchEnabled = false
		return webView
	}
	
	func updateUIView(_ webView: WKWebView, context: Context) {
		if url == .localUrl {
			// Load local website
			print("Load local file")
			//if let url = Bundle.main.url(forResource: "score", withExtension: "html", subdirectory: "www") {
			let url = URL(string: "www/score.html", relativeTo: scorewindData.docsUrl)!
			print("[debug] WebView, Load local file \(url)")
			print("[debug] WebView, allowingReadAccessTo\(url.deletingLastPathComponent())")
				webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
			//}
		} else if url == .publicUrl {
			// Load a public website, for example I used here google.com
			if let url = URL(string: "https://www.google.com") {
				webView.load(URLRequest(url: url))
			}
		}
	}
	
	class Coordinator : NSObject, WKNavigationDelegate {
		var parent: WebView
		var delegate: WebViewHandlerDelegate?
		var valueSubscriber: AnyCancellable? = nil
		var loadSubscriber: AnyCancellable? = nil
		var zoomInSubscriber: AnyCancellable? = nil
		var webViewNavigationSubscriber: AnyCancellable? = nil
		var timestampPublisher:AnyCancellable? = nil
		
		init(_ uiWebView: WebView) {
			self.parent = uiWebView
			self.delegate = parent
		}
		
		deinit {
			valueSubscriber?.cancel()
			loadSubscriber?.cancel()
			zoomInSubscriber?.cancel()
			webViewNavigationSubscriber?.cancel()
			timestampPublisher?.cancel()
		}
		
		func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
			// Get the title of loaded webcontent
			/*webView.evaluateJavaScript("document.title") { (response, error) in
				if let error = error {
					print("Error getting title")
					print(error.localizedDescription)
				}
				
				guard let title = response as? String else {
					return
				}
				
				self.parent.viewModel.showWebTitle.send(title)
			}*/
			
			print("[debug] WebView, didFinish")
			
			let encoder = JSONEncoder()
			do{
				let data = try encoder.encode(parent.scorewindData.currentTimestampRecs)
				let dataJson = String(data: data, encoding: .utf8)!
				let replacedString = dataJson.replacingOccurrences(of: "\"", with: #"\""#)
				let javascriptFunction2 = "loadTimestamps(\"\(replacedString)\");"
				webView.evaluateJavaScript(javascriptFunction2) { (response, error) in
					if let error = error {
						print("[debug] WebView, evaluateJavascript, loadTimestamps() error \(error)")
					} else {
						print("[debug] WebView, \(javascriptFunction2)")
					}
				}
			}catch let error{
				print(error)
			}
			
			//print("parent.viewModel.score: "+parent.viewModel.score)
			//print("parent.score:" + parent.score)
			print("[debug] WebView, parent.scorewindData, scoreViewer:\(parent.scorewindData.currentLesson.scoreViewer)")
			//let javascriptFunction = "load_score_view(\"\(parent.scorewindData.currentLesson.scoreViewer)\");"
			let scoreViewerArr = parent.scorewindData.currentLesson.scoreViewer.components(separatedBy: "/")
			let javascriptFunction = "load_score_view(xml_array[\"\(scoreViewerArr[scoreViewerArr.count-1])\"])"
			webView.evaluateJavaScript(javascriptFunction) { (response, error) in
				if let error = error {
					print("[debug] WebView, \(javascriptFunction)")
					print("[debug] WebView, load_score_view() error, \(error)")
				} else {
					print("[debug] WebView, \(javascriptFunction)")
				}
			}
			
			
			
			
			
			/* An observer that observes 'viewModel.valuePublisher' to get value from TextField and
			 pass that value to web app by calling JavaScript function */
			valueSubscriber = parent.viewModel.valuePublisher.receive(on: RunLoop.main).sink(receiveValue: { value in
				let javascriptFunction = "valueGotFromIOS(\"\(value)\");"
				print(javascriptFunction)
				webView.evaluateJavaScript(javascriptFunction) { (response, error) in
					if let error = error {
						print("Error calling javascript:valueGotFromIOS()")
						print(error.localizedDescription)
					} else {
						print("Called javascript:valueGotFromIOS()")
					}
				}
			})
			
			timestampPublisher = parent.viewModel.timestampPublisher.receive(on: RunLoop.main).sink(receiveValue: { value in
				let javascriptFunction = "loadTimestamps(\"\(value)\");"
				print(javascriptFunction)
				webView.evaluateJavaScript(javascriptFunction) { (response, error) in
					if let error = error {
						print("Error calling javascript:loadTimestamps()")
						print(error.localizedDescription)
					} else {
						print("Called javascript:loadTimestamps()")
					}
				}
			})
			
			loadSubscriber = parent.viewModel.loadPublisher.receive(on: RunLoop.main).sink(receiveValue: { value in
				print("loadSuscriber")
				let javascriptFunction = "load_score_view(\"\(value)\");"
				print(javascriptFunction)
				webView.evaluateJavaScript(javascriptFunction) { (response, error) in
					if let error = error {
						print("Error calling javascript:load_score_view()")
						print(error.localizedDescription)
					} else {
						print("Called javascript:load_score_view()")
						//print("parent.score: "+self.parent.score)
						print("parent.score: "+self.parent.scorewindData.currentLesson.scoreViewer)
					}
				}
			})
			
			zoomInSubscriber = parent.viewModel.zoomInPublisher.receive(on: RunLoop.main).sink(receiveValue: { value in
				let javascriptFunction = "zoomIn(\"\(value)\");"
				print(javascriptFunction)
				webView.evaluateJavaScript(javascriptFunction) { (response, error) in
					if let error = error {
						print("Error calling javascript:zoomIn()")
						print(error.localizedDescription)
					} else {
						print("Called javascript:zoomIn()")
					}
				}
			})
			
			// Page loaded so no need to show loader anymore
			self.parent.viewModel.showLoader.send(false)
		}
		
		/* Here I implemented most of the WKWebView's delegate functions so that you can know them and
		 can use them in different necessary purposes */
		
		func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
			// Hides loader
			parent.viewModel.showLoader.send(false)
		}
		
		func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
			// Hides loader
			parent.viewModel.showLoader.send(false)
		}
		
		func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
			// Shows loader
			parent.viewModel.showLoader.send(true)
		}
		
		func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
			// Shows loader
			parent.viewModel.showLoader.send(true)
			self.webViewNavigationSubscriber = self.parent.viewModel.webViewNavigationPublisher.receive(on: RunLoop.main).sink(receiveValue: { navigation in
				switch navigation {
				case .backward:
					if webView.canGoBack {
						webView.goBack()
					}
				case .forward:
					if webView.canGoForward {
						webView.goForward()
					}
				case .reload:
					webView.reload()
				}
			})
		}
		
		// This function is essential for intercepting every navigation in the webview
		func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
			// Suppose you don't want your user to go a restricted site
			// Here you can get many information about new url from 'navigationAction.request.description'
			if let host = navigationAction.request.url?.host {
				if host == "restricted.com" {
					// This cancels the navigation
					decisionHandler(.cancel)
					return
				}
			}
			// This allows the navigation
			decisionHandler(.allow)
		}
	}
}

// MARK: - Extensions
extension WebView.Coordinator: WKScriptMessageHandler {
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		// Make sure that your passed delegate is called
		if message.name == "iOSNative" {
			if let body = message.body as? [String: Any?] {
				delegate?.receivedJsonValueFromWebView(value: body)
			} else if let body = message.body as? String {
				delegate?.receivedStringValueFromWebView(value: body)
			}
		}
	}
}
