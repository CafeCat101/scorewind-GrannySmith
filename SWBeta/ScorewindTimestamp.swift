//
//  ScorewindTimestamp.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/13.
//

import Foundation

struct Timestamp:Codable, Identifiable {
	var id: Int
	var courseTitle: String
	var lessons: [TimestampLesson]
	
	enum CodingKeys: String, CodingKey{
		case id = "id"
		case courseTitle = "course_title"
		case lessons = "lessons"
	}
}

struct TimestampLesson: Codable, Identifiable {
	var id: Int
	var scorewindID: Int
	var title: String
	var timestamps: [TimestampRec]
	var step: Int
	
	enum CodingKeys: String, CodingKey{
		case id = "id"
		case scorewindID = "scorewind_id"
		case title = "lesson_title"
		case timestamps = "time_stamps"
		case step = "lesson_step"
	}
}

struct TimestampRec: Codable{
	//var id = UUID()
	var measure: Int
	var timestamp: Double
	//var `repeat`: Int
	//var notes: String
	//var type: String
	
	/*enum CodingKeys: String, CodingKey {
		//case id = UUID()
		case measure = "measure"
		case timestamp = "timestamp"
		case repeatCount = "repeat"
		//case notes = "notes"
		//case type = "time_type"
	}*/
	
	/*init() {
		id = UUID()
		measure = 0
		timestamp = 0.0
		`repeat` = 0
	}*/
}


