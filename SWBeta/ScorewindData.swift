//
//  ScorewindData.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/2/28.
//

import Foundation
import SwiftUI
import ZIPFoundation

class ScorewindData: ObservableObject {
	@Published var currentCourse = Course()
	@Published var currentLesson = Lesson()
	@Published var previousCourse:Course = Course()
	@Published var nextCourse:Course = Course()
	@Published var currentTimestampRecs:[TimestampRec] = []
	@Published var studentData: StudentData
	@Published var currentView = Page.wizard
	@Published var lastViewAtScore = false
	let courseURL = URL(fileURLWithPath: "courses_ios", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
	let timestampURL = URL(fileURLWithPath: "timestamps_ios", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
	let courseWPURL = "https://scorewind.com/courses_ios.json"
	let timestampWPURL = "https://scorewind.com/timestamps_ios.json"
	let dataVersionWPURL = "https://scorewind.com/data_version.json"
	let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	var lastPlaybackTime = 0.0
	var allCourses:[Course] = []
	private var allTimestamps:[Timestamp] = []
	private var userDefaults = UserDefaults.standard
	var dataVersion = 0
	
	init() {
		print(docsUrl!.path)
		studentData = StudentData()
		dataVersion = userDefaults.object(forKey: "dataVersion") as? Int ?? 0
		print("[debug] ScoreWindData, userDefaults.dataversion \(dataVersion)")
		//========
		print("[debug] ScorewindData, fileExist-www:\(FileManager.default.fileExists(atPath: (docsUrl?.appendingPathComponent("www").path)!))")
	}
	
	public func initiateCoursesFromLocal(){
		do {
			if let jsonData = try String(contentsOfFile: courseURL.path).data(using: .utf8) {
				let decodedData = try JSONDecoder().decode([Course].self, from: jsonData)
				allCourses = decodedData
				print("->initiateCoursesFromLocal(): decoded, courses")
			}
		} catch {
			print(error)
		}
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
	
	func setupWWW() {
		if FileManager.default.fileExists(atPath: docsUrl!.appendingPathComponent("www").path) == false {
			do {
				print("[debug] ScorewindData, move www from bundle to documents")
				try FileManager.default.copyItem(atPath: Bundle.main.resourceURL!.appendingPathComponent("www").path, toPath: docsUrl!.appendingPathComponent("www").path)
			} catch {
				print("[debug] ScorewindData, copyItem catch \(error)")
			}
		} else {
			print("[debug] ScorewindData, documents/www exists")
		}
	}
	
	func launchSetup(syncData: Bool, dataVersionFromWeb: Int? = 0) {
		/**
		 -data version check is another independant task whenever the app is launched or brought to foreground(if there has download task in process, don't check)
		 -isFirstLaunch when syncData=false
		 */
		if syncData == false {
			//unzip from bundle
			if dataVersion == 0 {
				//first time install app
				do {
					try FileManager.default.unzipItem(at: Bundle.main.resourceURL!.appendingPathComponent("scorewind_ios_xml.zip"), to: docsUrl!)
					try FileManager.default.copyItem(atPath: Bundle.main.resourceURL!.appendingPathComponent("www").path, toPath: docsUrl!.appendingPathComponent("www").path)
					try FileManager.default.moveItem(at: docsUrl!.appendingPathComponent("course_xml.js"), to: docsUrl!.appendingPathComponent("www/course_xml.js"))
					dataVersion = readBundleDataVersion()
					userDefaults.set(dataVersion,forKey: "dataVersion")
					print("[debug] ScorewindData, firstLaunch, final dataVersion \(dataVersion)")
				} catch {
					if FileManager.default.fileExists(atPath: docsUrl!.appendingPathComponent("course_xml.js").path) {
						do {
							try FileManager.default.removeItem(at: docsUrl!.appendingPathComponent("course_xml.js"))
							print("[debug] ScorewindData, firstLaunch, documents/course_xml.js is found, uncessary, deleted.")
						} catch {
							print("[debug] ScorewindData, firstLaunch, documents/course_xml.js is found, uncessary, should delete it. catch \(error)")
						}
					}
					if FileManager.default.fileExists(atPath: docsUrl!.appendingPathComponent("www").path) && FileManager.default.fileExists(atPath: docsUrl!.appendingPathComponent("courses_ios.json").path) && FileManager.default.fileExists(atPath: docsUrl!.appendingPathComponent("timestamps_ios.json").path) && FileManager.default.fileExists(atPath: docsUrl!.appendingPathComponent("www/course_xml.js").path) {
						dataVersion = readBundleDataVersion()
						userDefaults.set(dataVersion,forKey: "dataVersion")
						print("[debug] ScorewindData, firstLaunch, no changes, final dataVersion \(dataVersion)")
					}
					print("[debug] ScorewindData, unzip, move www and course_xml catch \(error)")
				}
			} else {
				//when app gets new version
				if readBundleDataVersion() > dataVersion {
					do {
						try FileManager.default.removeItem(at: docsUrl!.appendingPathComponent("www"))
						try FileManager.default.removeItem(at: docsUrl!.appendingPathComponent("courses_ios.json"))
						try FileManager.default.removeItem(at: docsUrl!.appendingPathComponent("timestamps_ios.json"))
					} catch {
						print("[debug] ScorewindData, app update, delete original data, catch \(error)")
					}
					
					do {
						try FileManager.default.unzipItem(at: Bundle.main.resourceURL!.appendingPathComponent("scorewind_ios_xml.zip"), to: docsUrl!)
						try FileManager.default.copyItem(atPath: Bundle.main.resourceURL!.appendingPathComponent("www").path, toPath: docsUrl!.appendingPathComponent("www").path)
						try FileManager.default.moveItem(at: docsUrl!.appendingPathComponent("course_xml.js"), to: docsUrl!.appendingPathComponent("www/course_xml.js"))
						dataVersion = readBundleDataVersion()
						userDefaults.set(dataVersion,forKey: "dataVersion")
						print("[debug] ScorewindData, firstLaunch, app updated, final dataVersion \(dataVersion)")
					} catch {
						if dataVersion != readBundleDataVersion() {
							print("[debug] ScorewindData, warning! app data update failed probably.")
						}
						print("[debug] ScorewindData, unzip, move www and course_xml catch \(error)")
					}
				}
			}
		} else {
			if dataVersionFromWeb! > 0 {
				do {
					try FileManager.default.removeItem(at: docsUrl!.appendingPathComponent("courses_ios.json"))
					try FileManager.default.removeItem(at: docsUrl!.appendingPathComponent("timestamps_ios.json"))
					try FileManager.default.removeItem(at: docsUrl!.appendingPathComponent("www/course_xml.js"))
				} catch {
					print("[debug] ScorewindData, app update, delete original data from zip, catch \(error)")
				}
				
				do {
					try FileManager.default.unzipItem(at: docsUrl!.appendingPathComponent("scorewind_ios_xml.zip"), to: docsUrl!)
					try FileManager.default.moveItem(at: docsUrl!.appendingPathComponent("course_xml.js"), to: docsUrl!.appendingPathComponent("www/course_xml.js"))
					dataVersion = dataVersionFromWeb!
					userDefaults.set(dataVersion,forKey: "dataVersion")
					print("[debug] ScorewindData, new data is updated, final dataVersion \(dataVersion)")
				} catch {
					if dataVersion != readBundleDataVersion() {
						print("[debug] ScorewindData, warning! new data update failed probably.")
					}
				}
			}
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
	
	private func readBundleDataVersion() -> Int {
		let dataVersionURL = URL(fileURLWithPath: "data_version", relativeTo: Bundle.main.resourceURL).appendingPathExtension("json")
		do {
			let jsonData = try String(contentsOfFile: dataVersionURL.path).data(using: .utf8)
			let dataVersionDic = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers) as? [String:Any]
			return dataVersionDic!["version"] as? Int ?? 0
		} catch {
			return 0
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

}
