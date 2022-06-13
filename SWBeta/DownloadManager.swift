//
//  DownloadManager.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/6/4.
//

import Foundation
import Combine

class DownloadManager: ObservableObject {
	@Published var downloadList:[DownloadItem] = []
	var callForDownloadPublisher = PassthroughSubject<Bool, Never>()
	let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	let courseOfflineURL = URL(fileURLWithPath: "courseOffline", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
	
	init() {
		/*for testing only*/
		/*let testURL = URL(string: "myfolder/test1.json", relativeTo: docsUrl)!
		do {
			print(testURL.path)
			let str = "blablabla"
			var isDirectory = ObjCBool(true)
			if FileManager.default.fileExists(atPath: docsUrl!.path+"/myfolder", isDirectory: &isDirectory) == false {
				try FileManager.default.createDirectory(atPath: docsUrl!.path+"/myfolder", withIntermediateDirectories: true)
				try str.write(to: testURL, atomically: true, encoding: String.Encoding.utf8)
			} else {
				print("myfolder directory exists.")
				try FileManager.default.removeItem(atPath: docsUrl!.path+"/myfolder")
			}
			
		} catch {
			print("\(error)")
				// failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
		}*/
	}

	/*func testPublisherTrigger(caller: String) async {
		print("testPublisherTrigger is called from \(caller)")
			callForDownloadPublisher.send(true)

		}
	}*/
	

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
	
	func addOrRemoveCourseOffline(currentCourseDownloadStatus: DownloadStatus, courseID: Int, lessons:[Lesson]) {
		var courseOfflineList:[CourseOfflineItem] = []
		
		if FileManager.default.fileExists(atPath: courseOfflineURL.path) {
			do {
				if let jsonData = try String(contentsOfFile: courseOfflineURL.path).data(using: .utf8) {
					courseOfflineList = try JSONDecoder().decode([CourseOfflineItem].self, from: jsonData)
				}
			} catch {
				print(error)
			}
		}
		
		let findExistingCourseItem = courseOfflineList.filter({$0.courseID == courseID})
		let findExistingLessonItems = downloadList.filter({$0.courseID == courseID})
		if currentCourseDownloadStatus == DownloadStatus.notInQueue {
			if findExistingCourseItem.isEmpty == true {
				print("[deubg] add course(id:\(courseID) to courseOffline.json")
				courseOfflineList.append(CourseOfflineItem(courseID: courseID))
			} else {
				print("[debug] courseOffline.json has this courseID item.")
			}
			if findExistingLessonItems.isEmpty == true {
				for lesson in lessons {
					downloadList.append(DownloadItem(courseID: courseID, lessonID: lesson.id, videoDownloadStatus: DownloadStatus.inQueue.rawValue, xmlDownloadStatus: DownloadStatus.inQueue.rawValue))
				}
			}
			
		} else {
			if !findExistingCourseItem.isEmpty {
				print("[deubg] remove course(id:\(courseID) from courseOffline.json")
				courseOfflineList.removeAll(where: {$0.courseID == courseID})
			} else {
				print("[debug] courseOffline.json has this courseID item.")
			}
			if !findExistingLessonItems.isEmpty{
				for lesson in lessons {
					downloadList.removeAll(where: {$0.lessonID == lesson.id})
				}
			}
		}
		
		if !courseOfflineList.isEmpty {
			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted
			do {
				let coursesOfflineData = try encoder.encode(courseOfflineList)
				try coursesOfflineData.write(to: courseOfflineURL, options: .atomicWrite)
			} catch let error {
				print(error)
			}
		} else {
			if FileManager.default.fileExists(atPath: courseOfflineURL.path) {
				do {
					try FileManager.default.removeItem(atPath: courseOfflineURL.path)
				} catch {
					print(error)
				}
			}
		}
		
		
	}
	
	func buildDownloadListFromJSON(allCourses:[Course]) {
		var courseOfflineList:[CourseOfflineItem] = []
		if FileManager.default.fileExists(atPath: courseOfflineURL.path) {
			do {
				if let jsonData = try String(contentsOfFile: courseOfflineURL.path).data(using: .utf8) {
					courseOfflineList = try JSONDecoder().decode([CourseOfflineItem].self, from: jsonData)
				}
			} catch {
				print(error)
			}
		}
		
		if !courseOfflineList.isEmpty {
			var newDownloadList:[DownloadItem] = []
			
			for courseItem in courseOfflineList {
				let findCourseTarget = allCourses.first(where: {$0.id == courseItem.courseID}) ?? Course()
				if findCourseTarget.id > 0 {
					for lesson in findCourseTarget.lessons {
						let courseURL = URL(string: "course\(courseItem.courseID)", relativeTo: docsUrl)!
						let videoURL = URL(fileURLWithPath: lesson.videoMP4, relativeTo: courseURL).appendingPathExtension("mp4")
						var videoStatus = DownloadStatus.inQueue
						if FileManager.default.fileExists(atPath: videoURL.path) {
							videoStatus = DownloadStatus.downloaded
						}
						let xmlURL = URL(fileURLWithPath: lesson.scoreViewer, relativeTo: courseURL).appendingPathExtension("xml")
						var xmlStatus = DownloadStatus.inQueue
						if FileManager.default.fileExists(atPath: xmlURL.path) {
							xmlStatus = DownloadStatus.downloaded
						}
						newDownloadList.append(DownloadItem(courseID: findCourseTarget.id, lessonID: lesson.id, videoDownloadStatus: videoStatus.rawValue, xmlDownloadStatus: xmlStatus.rawValue))
					}
				}
			}
			downloadList = newDownloadList
		}
	}
	
	func newDownloadVideos() async throws {
		for (index, item) in newDownloadList.enumerated() {
			if canceled == true {
				break
			}
			if item.downloadStatus == 1 {
				let findLesson = testVideos.first(where:{$0.id == item.lessonID})
				if findLesson != nil {
					print("newDownloadVideos, lesson.videoMP4 = \(findLesson!.videoMP4)")
					let url = URL(string: decodeVideoURL(videoURL: findLesson!.videoMP4))!
					
					newDownloadList[index].downloadStatus = 2
					print("newDownloadVideos, newDownloadList[\(index)].downloadStatus \(newDownloadList[index].downloadStatus)")
					
					do {
						DispatchQueue.main.async {
							self.newDownloadList[index].downloadStatus = 2
							print("newDownloadVideos, newDownloadList[\(index)].downloadStatus \(self.newDownloadList[index].downloadStatus)")
						}
						let newStatus = try await newDownload(url, lessonID: item.lessonID)
						if canceled == true {
							DispatchQueue.main.async {
								self.newDownloadList[index].downloadStatus = 1
							}
							break
						}
						DispatchQueue.main.async {
							self.newDownloadList[index].downloadStatus = newStatus
							print("newDownloadVideos, newDownloadList[\(index)].downloadStatus \(self.newDownloadList[index].downloadStatus)")
						}
					} catch {
						print("newDownloadVideos, catch,\(error)")
					}
				}
			}
		}
	}
	
}
