//
//  ScorewindData.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/2/28.
//

import Foundation
import SwiftUI

class ScorewindData: ObservableObject {
	@Published var currentCourse = Course()
	@Published var currentLesson = Lesson()
	@Published var previousCourse:Course = Course()
	@Published var nextCourse:Course = Course()
	@Published var currentTimestampRecs:[TimestampRec] = []
	var allCourses:[Course] = []
	var allTimestamps:[Timestamp] = []
	let courseURL = URL(fileURLWithPath: "courses_ios", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
	let timestampURL = URL(fileURLWithPath: "timestamps_ios", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
	let courseWPURL = "https://scorewind.com/courses_ios.json"
	let timestampWPURL = "https://scorewind.com/timestamps_ios.json"
	let dataVersionWPURL = "https://scorewind.com/data_version.json"
	@Published var studentData: StudentData
	@Published var currentView = Page.wizard
	var lastPlaybackTime = 0.0
	@Published var lastViewAtScore = false
	
	init() {
		print(courseURL.path)
		studentData = StudentData()
	}
	
	public func initiateCoursesFromLocal() -> Bool{
		var taskCompleted = false
		do {
			if let jsonData = try String(contentsOfFile: courseURL.path).data(using: .utf8) {
				let decodedData = try JSONDecoder().decode([Course].self, from: jsonData)
				allCourses = decodedData
				print("->initiateCoursesFromLocal(): decoded, courses")
				taskCompleted = true
			}
		} catch {
			print(error)
		}
		return taskCompleted
	}
	
	public func initiateTimestampsFromLocal(){
		do {
			if let jsonData = try String(contentsOfFile: timestampURL.path).data(using: .utf8) {
				let decodedData = try JSONDecoder().decode([Timestamp].self, from: jsonData)
				allTimestamps = decodedData
				print("->initiateTimestampsFromLocal(): decoded, timestamps")
			}
		} catch {
			print(error)
		}
	}
	
	public func downloadJson(fromURLString urlString: String, completion: @escaping(Result<Data, Error>) -> Void) {
		if let url = URL(string: urlString) {
			let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
				if let error = error {
					completion(.failure(error))
				}
				
				if let data = data {
					completion(.success(data))
				}
			}
			
			urlSession.resume()
		}
	}
	
	func replaceCommonHTMLNumber(htmlString:String)->String{
		var result = htmlString.replacingOccurrences(of: "&#8211;", with: "-")
		result = result.replacingOccurrences(of: "&#32;", with: " ")
		result = result.replacingOccurrences(of: "&quot;", with: "\"")
		result = result.replacingOccurrences(of: "&#8212;", with: "—")
		result = result.replacingOccurrences(of: "&#8216;", with: "‘")
		result = result.replacingOccurrences(of: "&#8217;", with: "’")
		result = result.replacingOccurrences(of: "&#8220;", with: "“")
		result = result.replacingOccurrences(of: "&#8221;", with: "”")
		return result
	}
	
	func removeWhatsNext(Text:String)->String{
		let searchText = "<h4>What's next</h4>"
		if let range: Range<String.Index> = Text.range(of: searchText) {
			let findIndex: Int = Text.distance(from: Text.startIndex, to: range.lowerBound)
			print("index: ", findIndex) //index: 2
			let myText = Text.prefix(findIndex)
			return String(myText)
			//let targetRange = Text.index(after: Text.startIndex)..<findIndex
			
			
		}else{
			return Text
		}
	}
	
	
	func needToCheckVersion() -> Int{
		//check version from web is last check is a week old.
		var needToCheckVersion = 0
		let dataVersionURL = URL(fileURLWithPath: "data_version", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
		
		do {
			let jsonData = try String(contentsOfFile: dataVersionURL.path).data(using: .utf8)
			let dataVersionDic = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers) as? [String:Any]
			let today = Date()
			let dateInFileFormatter = DateFormatter()
			dateInFileFormatter.dateFormat = "YYYY-MM-dd"
			let dateInFileString = "\(dataVersionDic!["updated"] ?? "")"
			print("\(dataVersionDic!["updated"] ?? "")")
			
			let numberOfDays = Calendar.current.dateComponents([.day], from: dateInFileFormatter.date(from:dateInFileString)!, to: today).day!
			if numberOfDays > 30 {
				needToCheckVersion = dataVersionDic!["version"] as? Int ?? 0
			}
		} catch {
			print(error.localizedDescription)
		}
		
		return needToCheckVersion
	}
	
	func firstLaunch() -> String {
		let dataVersionURL = URL(fileURLWithPath: "data_version", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
		let courseURL = URL(fileURLWithPath: "courses_ios", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
		let timestampURL = URL(fileURLWithPath: "timestamps_ios", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
		var errorMessage = "";
		print(dataVersionURL.path)
		
		if FileManager.default.fileExists(atPath: dataVersionURL.path) == false {
			do {
				try FileManager.default.copyItem(atPath: Bundle.main.path(forResource: "data_version", ofType: "json")!, toPath: dataVersionURL.path)
				if let jsonData = try String(contentsOfFile: dataVersionURL.path).data(using: .utf8) {
					do {
						var dataVersionJson = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String:Any]
						let today = Date()
						let todayFormatter = DateFormatter()
						todayFormatter.dateFormat = "YYYY-MM-dd"
						dataVersionJson!["updated"] = todayFormatter.string(from:today) as AnyObject
						for (key, value) in dataVersionJson! {
							print("\(key):\(value)")
						}
						
						let backToJSONData = try JSONSerialization.data(withJSONObject: dataVersionJson as Any)
						let jsonString = NSString(data:backToJSONData, encoding: String.Encoding.utf8.rawValue) as Any
						try backToJSONData.write(to: dataVersionURL,options: .atomicWrite)
						print(jsonString)
					} catch {
						print(error.localizedDescription)
					}
				}
			} catch {
				errorMessage = errorMessage + ", " + error.localizedDescription
			}

			do {
				try FileManager.default.copyItem(atPath: Bundle.main.path(forResource: "courses_ios", ofType: "json")!, toPath: courseURL.path)
			} catch {
				errorMessage = errorMessage + ", " + error.localizedDescription
			}
			
			do {
				try FileManager.default.copyItem(atPath: Bundle.main.path(forResource: "timestamps_ios", ofType: "json")!, toPath: timestampURL.path)
			} catch {
				errorMessage = errorMessage + ", " + error.localizedDescription
			}
		}else{
			errorMessage = "0"
		}
		
		return errorMessage
	}
	
	func setCurrentTimestampRecs() {
		if allTimestamps.count > 0 {
			for course in allTimestamps {
				if course.id == currentCourse.id {
					for lesson in course.lessons {
						if lesson.id == currentLesson.id {
							currentTimestampRecs = lesson.timestamps
							break
						}
					}
				}
			}
		}
	}
	
	func timestampToJson()->String {
		print("call ScoreWindData timestampToJson fun")
		let encoder = JSONEncoder()
		do{
			let data = try encoder.encode(currentTimestampRecs)
			print(String(data: data, encoding: .utf8)!)
			print("========")
			return String(data: data, encoding: .utf8)!
		}catch let error{
			print(error)
			return ""
		}
		
	}
	
	func findPreviousCourse(){
		
	}
	
	func findNextCourse(){
	
	}
	
	func checkDownloadList(courseID:Int){
		let downloadListURL = URL(fileURLWithPath: "downloadList", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
		if FileManager.default.fileExists(atPath: downloadListURL.path) {
			
		}
	}
	
	func downloadCourse(courseID:Int){
		
	}
	
	func cancelDonwloadCourse(courseID:Int){
		
	}
}
