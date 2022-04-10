//
//  iCloudKeyValue.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/4/7.
//

import XCTest
@testable import SWBeta

class iCloudKeyValue: XCTestCase {
	var studentDataModel = StudentData()
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	/*func testPerformanceExample() throws {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
		}
	}*/
	
	func testReadAllKeys() throws {
		XCTAssertNoThrow(studentDataModel.backendReadAllKeys())
	}
	
	func testRemoveInstrumentKey() throws {
		//remove enrolled courses: enrolledCourses
		//remove instrument preference: instrument
		XCTAssertNoThrow(studentDataModel.removeAKey(keyName: "instrument"))
		studentDataModel.backendReadAllKeys()
	}
	
	func testSetInstrumentChoice() throws {
		XCTAssertNoThrow(studentDataModel.setInstrumentChoice(instrument: InstrumentType.guitar.rawValue))
	}
	
	func testUpdateEnrolledCourses() throws {
		let testCourseID = 22222
		let testCourseIsCompelted = false
		XCTAssertNoThrow(studentDataModel.updateEnrolledCourses(courseID: testCourseID, isCompleted: testCourseIsCompelted))
		studentDataModel.backendReadAllKeys()
	}
	
	func testGetInstrumentChoice() throws {
		XCTAssertNoThrow(print("get instrument choice: "+studentDataModel.getInstrumentChoice()))
	}
}
