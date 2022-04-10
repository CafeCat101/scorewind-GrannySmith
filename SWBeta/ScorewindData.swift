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
	var allCourses:[Course] = []
	var allTimestamps:[Timestamp] = []
	let courseURL = URL(fileURLWithPath: "data_scorewind_courses", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
	let timestampURL = URL(fileURLWithPath: "data_scorewind_timestamp", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
	let courseWPURL = "https://scorewind.com/courses_ios.json"
	let timestampWPURL = "https://scorewind.com/timestamps_ios.json"
	@Published var studentData: StudentData
	
	init() {
		print(courseURL.path)
		studentData = StudentData()
	}
	
	public func initiateTimestampData() {
		if FileManager.default.fileExists(atPath: timestampURL.path) {
			print("data_scorewind_timestamp.json is already in the documentory.")
			self.loadLocalFile(filePath: self.timestampURL.path)
			
		} else {
			downloadJson(fromURLString: timestampWPURL) { (result) in
				switch result {
				case .success(let data):
					do {
						print("->downloadJson: downloaded, timestamps")
						try data.write(to: self.timestampURL, options: .atomicWrite)
						self.loadLocalFile(filePath: self.timestampURL.path)
					} catch let error {
						print(error)
					}
				case .failure(let error):
					print(error)
				}
			}
		}
	}
	
	public func loadLocalFile(filePath: String) -> Bool{
		var taskCompleted = false
		
		do {
			if let jsonData = try String(contentsOfFile: filePath).data(using: .utf8) {
				if(filePath.contains("data_scorewind_courses.json")){
					let decodedData = try JSONDecoder().decode([Course].self, from: jsonData)
					allCourses = decodedData
					print("->loadLocalFile(): decoded, courses")
					taskCompleted = true
				}
				
				if(filePath.contains("data_scorewind_timestamp.json")){
					let decodedData = try JSONDecoder().decode([Timestamp].self, from: jsonData)
					allTimestamps = decodedData
					print("->loadLocalFile(): decoded, timestamps")
					taskCompleted = true
				}
			}
			
		} catch {
			print(error)
		}
		
		return taskCompleted
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
}
