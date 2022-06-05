//
//  DownloadManager.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/6/4.
//

import Foundation

class DownloadManager: ObservableObject {
	@Published var downloadList = [DownloadItem()]
	
	private func downloadLesson(lessonID: Int) async {
		
	}
	
	private func downloadVideos(videoLink: String) {
		let remoteURL = URL(string: videoLink)!
		let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
		let targetURL = documentURL.appendingPathComponent(remoteURL.lastPathComponent)
		print("[debug] download des:\(targetURL.path)")

		let downloadTask = URLSession.shared.downloadTask(with: remoteURL) { url, response, error in
				guard let tempURL = url else { return }
				_ = try? FileManager.default.replaceItemAt(targetURL, withItemAt: tempURL)
		}
		downloadTask.resume()
	}
	
	func checkDownloadStatus(lessonID:Int) -> Int {
		var finalDownloadStatus = DownloadStatus.notInQueue.rawValue
		var getVideoDownloadStatus = DownloadStatus.notInQueue.rawValue
		var getXMLDownloadStatus = DownloadStatus.notInQueue.rawValue
		
		if let findIndex = downloadList.firstIndex(where: {$0.lessonID == lessonID}) {
			getVideoDownloadStatus = downloadList[findIndex].videoDownloadStatus
			getXMLDownloadStatus = downloadList[findIndex].xmlDownloadStatus
		}
		
		if getVideoDownloadStatus == DownloadStatus.inQueue.rawValue || getXMLDownloadStatus == DownloadStatus.inQueue.rawValue {
			finalDownloadStatus = DownloadStatus.inQueue.rawValue
		}
		
		if getVideoDownloadStatus == DownloadStatus.downloading.rawValue || getXMLDownloadStatus == DownloadStatus.downloading.rawValue {
			finalDownloadStatus = DownloadStatus.downloading.rawValue
		}
		
		if getVideoDownloadStatus == DownloadStatus.downloaded.rawValue && getXMLDownloadStatus == DownloadStatus.downloaded.rawValue {
			finalDownloadStatus = DownloadStatus.downloaded.rawValue
		}
		
		print("[debug] DownloadManager, checkDownloadStatus(lessonID:\(lessonID), finalDownloadStatus\(finalDownloadStatus)")
		
		return finalDownloadStatus
	}
	
}
