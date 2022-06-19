//
//  ViewModel.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/5/14.
//

import Foundation
import Combine
import AVKit

class ViewModel: ObservableObject {
	var webViewNavigationPublisher = PassthroughSubject<WebViewNavigation, Never>()
	var showWebTitle = PassthroughSubject<String, Never>()
	var showLoader = PassthroughSubject<Bool, Never>()
	var valuePublisher = PassthroughSubject<String, Never>()
	var loadPublisher = PassthroughSubject<String, Never>()
	var zoomInPublisher = PassthroughSubject<String, Never>()
	var timestampPublisher = PassthroughSubject<String, Never>()
	//var score:String = ""
	//var highlightBar = 1 //doesn't need this now. measure is found by playback time. keep it incase we'll track it as well.
	@Published var videoPlayer: AVPlayer?
	
	func playerGoTo(timestamp:Double){
		print("playerGoTo()[ViewModel]")
		let timestampCMTime:Int64 = Int64(timestamp*1000)
		let seekTime = CMTime(value: timestampCMTime, timescale: 1000)
		videoPlayer?.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
		print("ViewModel playerGoTo "+String(CMTimeGetSeconds(seekTime)))
		videoPlayer?.play()
	}
}

// For identifiying WebView's forward and backward navigation
enum WebViewNavigation {
	case backward, forward, reload
}

// For identifying what type of url should load into WebView
enum WebUrlType {
	case localUrl, publicUrl
}

