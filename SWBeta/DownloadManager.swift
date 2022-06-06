//
//  DownloadManager.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/6/4.
//

import Foundation
import SwiftUI

class DownloadManager: ObservableObject {
	@Published var downloadList:[DownloadItem] = []
	
	func downloadCourse(course: Course) {
		/**
		 This function is called by Make Course Offline button
		 */
		let downloadListURL = URL(fileURLWithPath: "downloadList", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
		print("[debug] DownloadManager, downloadCourse \(downloadListURL.path)")
		if FileManager.default.fileExists(atPath: downloadListURL.path) {
			//read content to downloadList property
			//append new DownloadItem if the Down
			do {
				if let jsonData = try String(contentsOfFile: downloadListURL.path).data(using: .utf8) {
					let decodedData = try JSONDecoder().decode([DownloadItem].self, from: jsonData)
					downloadList = decodedData
					print("[debug] DownloadManager, downloadCourse: has downloadList.json, downloadList.count\(downloadList.count)")
					
					let checkExistingCourse = downloadList.filter {
						$0.courseID == course.id
					}
					
					if checkExistingCourse.isEmpty {
						for lesson in course.lessons {
							downloadList.append(DownloadItem(courseID: course.id, lessonID: lesson.id, videoDownloadStatus: DownloadStatus.notInQueue.rawValue, xmlDownloadStatus: DownloadStatus.inQueue.rawValue))
						}
						
						let encoder = JSONEncoder()
						encoder.outputFormatting = .prettyPrinted
						do {
							let downloadListData = try encoder.encode(downloadList)
							try downloadListData.write(to: downloadListURL, options: .atomicWrite)
							print("[debug] DownloadManager, downloadCourse, downloadList.count\(downloadList.count)")
						} catch let error {
							print(error)
						}
					}
					
				}
			} catch {
				print(error)
			}
		} else {
			//make temp downloadList object, right it to disk and assign it to downloadList property.
			var tempDownloadList:[DownloadItem] = []
			for lesson in course.lessons {
				tempDownloadList.append(DownloadItem(courseID: course.id, lessonID: lesson.id, videoDownloadStatus: DownloadStatus.notInQueue.rawValue, xmlDownloadStatus: DownloadStatus.inQueue.rawValue))
			}
			if !tempDownloadList.isEmpty {
				let encoder = JSONEncoder()
				encoder.outputFormatting = .prettyPrinted
				do {
					let tempDownloadListData = try encoder.encode(tempDownloadList)
					try tempDownloadListData.write(to: downloadListURL, options: .atomicWrite)
					downloadList = tempDownloadList
					print("[debug] DownloadManager, downloadCourse, downloadList.count\(downloadList.count)")
				} catch let error {
					print(error)
				}
			}
		}
	}
	
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
		
		print("[debug] DownloadManager, checkDownloadStatus(lessonID:\(lessonID)), finalDownloadStatus\(finalDownloadStatus)")
		
		return finalDownloadStatus
	}
	
	func checkDownloadStatus(courseID: Int, lessonsCount: Int) -> DownloadStatus {
		print("[deubg] DownloadManager, checkDownloadStatus(courseID:\(courseID),lessonsCount:\(lessonsCount))")
		var finalDownloadStatus = DownloadStatus.notInQueue
		
		if lessonsCount > 0 {
			let getLessonsInQueue = downloadList.filter {
				$0.courseID == courseID && ($0.videoDownloadStatus == DownloadStatus.inQueue.rawValue || $0.xmlDownloadStatus == DownloadStatus.inQueue.rawValue)
			}
			if getLessonsInQueue.count > 0 {
				finalDownloadStatus = DownloadStatus.inQueue
				
				if getLessonsInQueue.count == lessonsCount {
					print("[deubg] DownloadManager, checkDownloadStatus(courseID:\(courseID),lessonsCount:\(lessonsCount)) status\(finalDownloadStatus)")
					return finalDownloadStatus
				}
			}
			
			let getLessonsDownloading = downloadList.filter {
				$0.courseID == courseID && ($0.videoDownloadStatus == DownloadStatus.downloading.rawValue || $0.xmlDownloadStatus == DownloadStatus.downloading.rawValue)
			}
			if getLessonsDownloading.count > 0 {
				finalDownloadStatus = DownloadStatus.downloading
				
				if getLessonsDownloading.count == lessonsCount {
					print("[deubg] DownloadManager, checkDownloadStatus(courseID:\(courseID),lessonsCount:\(lessonsCount)) status\(finalDownloadStatus)")
					return finalDownloadStatus
				}
			}
			
			let getLessonsDownloaded = downloadList.filter {
				$0.courseID == courseID && $0.videoDownloadStatus == DownloadStatus.downloaded.rawValue && $0.xmlDownloadStatus == DownloadStatus.downloaded.rawValue
			}
			if getLessonsDownloaded.count == lessonsCount {
				finalDownloadStatus = DownloadStatus.downloaded
				print("[deubg] DownloadManager, checkDownloadStatus(courseID:\(courseID),lessonsCount:\(lessonsCount)) status\(finalDownloadStatus)")
				return finalDownloadStatus
			}
		}
		print("[deubg] DownloadManager, checkDownloadStatus(courseID:\(courseID),lessonsCount:\(lessonsCount)) status\(finalDownloadStatus)")
		return finalDownloadStatus
	}
	
}
