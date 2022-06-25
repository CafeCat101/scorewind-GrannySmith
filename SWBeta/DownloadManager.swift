//
//  DownloadManager.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/6/4.
//

import Foundation
import Combine
import SwiftUI

class DownloadManager: ObservableObject {
	@Published var downloadList:[DownloadItem] = []
	let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	private var swVideoDownloadTask: Task<URL?,Error>?
	var downloadTaskPublisher = PassthroughSubject<[DownloadItem], Never>()
	var appState:ScenePhase = .background
	private var userDefaults = UserDefaults.standard
	var downloadingCourse = 0
	
	init() {
		let checkCourseOfflineList = userDefaults.object(forKey: "courseOffline") as? [Int] ?? []
		if !checkCourseOfflineList.isEmpty {
			for item in checkCourseOfflineList {
				print("[debug] DownloadManager, UserDefault-key:courseOffline item:\(item)")
			}
		} else {
			print("[deubg] DownloadManager, UserDefault-key:courseOffline is empty")
		}
	}
	
	func checkDownloadStatus(lessonID:Int) -> Int {
		var finalDownloadStatus = DownloadStatus.notInQueue.rawValue
		let findIndex = downloadList.firstIndex(where: {$0.lessonID == lessonID}) ?? -1
		if findIndex > -1 {
			finalDownloadStatus = downloadList[findIndex].videoDownloadStatus
		}
		print("[debug] DownloadManager, checkDownloadStatus(lessonID:\(lessonID)), finalDownloadStatus\(finalDownloadStatus)")
		
		return finalDownloadStatus
	}
	
	func checkDownloadStatus(courseID: Int, lessonsCount: Int) -> DownloadStatus {
		print("[deubg] DownloadManager, checkDownloadStatus(courseID:\(courseID),lessonsCount:\(lessonsCount))")
		let lessonsInDownloadList = downloadList.filter({$0.courseID == courseID}).count
		
		if lessonsInDownloadList > 0 {
			let InQueue = downloadList.filter({$0.courseID == courseID && $0.videoDownloadStatus == DownloadStatus.inQueue.rawValue}).count
			let downloaded = downloadList.filter({$0.courseID == courseID && $0.videoDownloadStatus == DownloadStatus.downloaded.rawValue}).count
			let failed = downloadList.filter({$0.courseID == courseID && $0.videoDownloadStatus == DownloadStatus.failed.rawValue}).count
			
			if downloaded == lessonsCount {
				return DownloadStatus.downloaded
			} else if InQueue == lessonsCount {
				return DownloadStatus.inQueue
			} else {
				if failed > 0 {
					return DownloadStatus.failed
				} else {
					return DownloadStatus.downloading
				}
			}
		} else {
			return DownloadStatus.notInQueue
		}
	}
	
	func addOrRemoveCourseOffline(currentCourseDownloadStatus: DownloadStatus, courseID: Int, lessons:[Lesson]) {
		var courseOfflineList = userDefaults.object(forKey: "courseOffline") as? [Int] ?? []
		let findExistingCourseItem = courseOfflineList.filter({$0 == courseID})
		let findExistingLessonItems = downloadList.filter({$0.courseID == courseID})
		
		if currentCourseDownloadStatus == DownloadStatus.notInQueue {
			if findExistingCourseItem.isEmpty == true {
				print("[deubg] add course(id:\(courseID) to UserDefault key:courseOffline")
				courseOfflineList.append(courseID)
				userDefaults.set(courseOfflineList, forKey: "courseOffline")
			} else {
				print("[debug] UserDefault key:courseOffline already have courseID\(courseID)")
			}
			if findExistingLessonItems.isEmpty == true {
				for lesson in lessons {
					downloadList.append(DownloadItem(courseID: courseID, lessonID: lesson.id, videoDownloadStatus: DownloadStatus.inQueue.rawValue))
				}
			}
		} else {
			if !findExistingCourseItem.isEmpty {
				print("[deubg] remove course(id:\(courseID) from UserDefault key:courseOffline")
				if downloadingCourse == courseID {
					swVideoDownloadTask?.cancel()
					downloadingCourse = 0
				}
				courseOfflineList.removeAll(where: {$0 == courseID})
				userDefaults.set(courseOfflineList, forKey: "courseOffline")
				do {
					try FileManager.default.removeItem(atPath: URL(string: "course\(courseID)", relativeTo: docsUrl)!.path)
				} catch {
					print("[debug] remove course/all downloaded file, catch,\(error)")
				}
			} else {
				print("[debug] UserDefault key:courseOffline didn't have courseID\(courseID)")
			}
			if !findExistingLessonItems.isEmpty{
				for lesson in lessons {
					downloadList.removeAll(where: {$0.lessonID == lesson.id})
				}
			}
		}
	}
	
	func buildDownloadListFromJSON(allCourses:[Course]) {
		print("[debug] DownloadManager, buildDownloadListFromJSON")
		
		let courseOfflineList = userDefaults.object(forKey: "courseOffline") as? [Int] ?? []
		if !courseOfflineList.isEmpty {
			var newDownloadList:[DownloadItem] = []
			
			for courseItem in courseOfflineList {
				let findCourseTarget = allCourses.first(where: {$0.id == courseItem}) ?? Course()
				if findCourseTarget.id > 0 {
					let courseURL = URL(string: "course\(courseItem)", relativeTo: docsUrl)!
					
					for lesson in findCourseTarget.lessons {
						let videoURL = URL(string: lesson.videoMP4.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
						var videoStatus = DownloadStatus.inQueue
						if FileManager.default.fileExists(atPath: courseURL.appendingPathComponent(videoURL.lastPathComponent).path) {
							videoStatus = DownloadStatus.downloaded
						} else {
							print("[debug] DownloadManager, buildDownloadListFromJSON, video(\(courseURL.appendingPathComponent(videoURL.lastPathComponent).path) is not found.")
						}
						
						newDownloadList.append(DownloadItem(courseID: findCourseTarget.id, lessonID: lesson.id, videoDownloadStatus: videoStatus.rawValue))
					}
				}
			}
			downloadList = newDownloadList
		}
	}
	
	func downloadVideos(allCourses: [Course]) async throws{
		let downloadTargets = self.downloadList
		for item in downloadTargets {
			if item.videoDownloadStatus == 1{
				let getCourse = allCourses.first(where: {$0.id == item.courseID})
				let getLesson = getCourse?.lessons.first(where: {$0.id == item.lessonID})
				print("[deubg] [downlaodVideoXML] lessonID:\(getLesson?.id ?? 0)")
				
				let destCourseURL = URL(string: "course\(item.courseID)", relativeTo: docsUrl)!
				do {
					print("[deubg] [downlaodVideoXML] destCourseURL:\(destCourseURL.path)")
					var isDirectory = ObjCBool(true)
					if FileManager.default.fileExists(atPath: destCourseURL.path, isDirectory: &isDirectory) == false {
						try FileManager.default.createDirectory(atPath: destCourseURL.path, withIntermediateDirectories: true)
					}
				} catch {
					print("[deubg] [downlaodVideoXML] check create destCourseURL, catch \(error)")
				}
				
				var isDirectory = ObjCBool(true)
				if FileManager.default.fileExists(atPath: destCourseURL.path, isDirectory: &isDirectory) == true {
					print("[deubg] [downlaodVideoXML] scoreViewer:\(getLesson!.scoreViewer)")
					let downloadableVideoURL = URL(string: getLesson!.videoMP4.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
					
					let getDownloadListIndex = self.downloadList.firstIndex(where: {$0.courseID == item.courseID && $0.lessonID == item.lessonID}) ?? -1
					if getDownloadListIndex > -1 {
						DispatchQueue.main.async {
							//self.downloadList[getDownloadListIndex].videoDownloadStatus = DownloadStatus.downloading.rawValue
							self.downloadTaskUpdateStatus(status: DownloadStatus.downloading, tempCourseID: item.courseID, tempLessonID: item.lessonID)
						}
						
						if FileManager.default.fileExists(atPath: destCourseURL.appendingPathComponent(downloadableVideoURL.lastPathComponent).path) == false {
							swVideoDownloadTask = Task { () -> URL? in
								print("[deubg] [downlaodVideoXML] swVideoDownloadTask, downloadingCourse:\(self.downloadingCourse), begin(lessonID:\(item.lessonID)")
								self.downloadingCourse = item.courseID
								let (fileURL, _) = try await URLSession.shared.download(from: downloadableVideoURL)
								return fileURL
							}
							
							do {
								let getVideoFileURL = try await swVideoDownloadTask!.value!
								self.downloadingCourse = 0
								print("[deubg] [downlaodVideoXML] getVideoFileURL:\(getVideoFileURL.path)")
								print("[deubg] [downlaodVideoXML] destVideoFileURL:\(destCourseURL.appendingPathComponent(downloadableVideoURL.lastPathComponent).path)")
								try FileManager.default.moveItem(at: getVideoFileURL, to: destCourseURL.appendingPathComponent(downloadableVideoURL.lastPathComponent))
								DispatchQueue.main.async {
									self.downloadTaskUpdateStatus(status: DownloadStatus.downloaded, tempCourseID: item.courseID, tempLessonID: item.lessonID)
								}
							} catch {
								print("[deubg] [downlaodVideoXML] do await swXMLDownloadTask, catch \(error)")
								if FileManager.default.fileExists(atPath: destCourseURL.appendingPathComponent(downloadableVideoURL.lastPathComponent).path) == false {
									DispatchQueue.main.async {
										self.downloadTaskUpdateStatus(status: DownloadStatus.failed, tempCourseID: item.courseID, tempLessonID: item.lessonID)
									}
								} else {
									DispatchQueue.main.async {
										self.downloadTaskUpdateStatus(status: DownloadStatus.downloaded, tempCourseID: item.courseID, tempLessonID: item.lessonID)
									}
								}
								
							}
						} else {
							print("[deubg] [downlaodVideoXML] FileManager, destXMLFileURL exists.")
							DispatchQueue.main.async {
								self.downloadTaskUpdateStatus(status: DownloadStatus.downloaded, tempCourseID: item.courseID, tempLessonID: item.lessonID)
							}
						}
					}
					
				}
			}
		}
		
		DispatchQueue.main.async {
			self.downloadTaskPublisher.send(downloadTargets)
		}
	}
	
	private func downloadTaskUpdateStatus(status: DownloadStatus, tempCourseID: Int, tempLessonID: Int) {
		//"temp" because these IDs are from array the loop uses, not the original downloadList
		print("[deubg] [downlaodVideoXML-downloadTaskUpdateStatus] item.CourseID\(tempCourseID),courseIDitem.lessonID\(tempLessonID)")
		let getDownloadListIndex = self.downloadList.firstIndex(where: {$0.courseID == tempCourseID && $0.lessonID == tempLessonID}) ?? -1
		print("[deubg] [downlaodVideoXML-downloadTaskUpdateStatus] getDownloadListIndex\(getDownloadListIndex) lessonID\(tempLessonID)")
		if getDownloadListIndex > -1 {
			self.downloadList[getDownloadListIndex].videoDownloadStatus = status.rawValue
		}
	}
	
	func compareDownloadList(downloadTargets: [DownloadItem]) -> Bool {
		var courseIDInTargets:[Int] = []
		var courseIDInDownloadList:[Int] = []
		for item in downloadTargets {
			let existingCourseID = courseIDInTargets.firstIndex(where: {$0 == item.courseID}) ?? -1
			if existingCourseID == -1 {
				courseIDInTargets.append(item.courseID)
			}
		}
		print("[debug] [compareDownloadList]courseID in downloadVideoXML \(courseIDInTargets)")
		for itemD in downloadList {
			let existingCourseID = courseIDInDownloadList.firstIndex(where: {$0 == itemD.courseID}) ?? -1
			if existingCourseID == -1 {
				courseIDInDownloadList.append(itemD.courseID)
			}
		}
		print("[debug] [compareDownloadList]courseID in downloadList \(courseIDInDownloadList)")
		if courseIDInTargets == courseIDInDownloadList {
			return true
		} else {
			return false
		}
	}
	
}
