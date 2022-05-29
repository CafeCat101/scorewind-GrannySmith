//
//  StudentData.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/4/4.
//

import Foundation
import SwiftUI


class StudentData: ObservableObject {
	private let useriCloudKeyValueStore = NSUbiquitousKeyValueStore.default
	
	func getInstrumentChoice()->String{
		return useriCloudKeyValueStore.string(forKey:"instrument") ?? ""
	}
	
	func getEnrolledCourses()->[String:Any] {
		return useriCloudKeyValueStore.dictionary(forKey:"enrolledCourses") ?? [:]
	}
	
	func getCompletedLessons(courseID:Int)->[Int] {
		let getAllCompletedLessons = useriCloudKeyValueStore.dictionary(forKey:"completedLessons") ?? [:]
		var filteredLessons:[Int] = []
		
		for lesson in getAllCompletedLessons {
			if lesson.value as! Int == courseID {
				filteredLessons.append(Int(lesson.key)!)
			}
		}
		return filteredLessons
	}
	
	
	func setInstrumentChoice(instrument:String) {
		useriCloudKeyValueStore.set(instrument,forKey: "instrument")
		useriCloudKeyValueStore.synchronize()
	}
	
	func updateEnrolledCourse(courseID:Int, isCompleted: Bool) {
		var enrolledCourses = getEnrolledCourses()
		enrolledCourses.updateValue(isCompleted, forKey: String(courseID))
		useriCloudKeyValueStore.set(enrolledCourses,forKey: "enrolledCourses")
		useriCloudKeyValueStore.synchronize()
	}
	
	func updateCompletedLesson(courseID:Int, lessonID:Int, isCompleted:Bool){
		var getAllCompletedLessons = getCompletedLessons(courseID: courseID)
		if isCompleted  {
			if getAllCompletedLessons.contains(lessonID) == false{
				getAllCompletedLessons.append(lessonID)
			}
		}else{
			if getAllCompletedLessons.contains(lessonID) == true{
				//getAllCompletedLessons.remove(lessonID)
			}
		}

	}
	
	
	func removeAKey(keyName:String){
		useriCloudKeyValueStore.removeObject(forKey: keyName)
	}
	
	func backendReadAllKeys(){
		for(key,value) in useriCloudKeyValueStore.dictionaryRepresentation {
			print("===================")
			print("\(key):\(value)")
			print("===================")
		}
	}
}
