//
//  WelceomView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/2/28.
//

import SwiftUI

struct WelcomeView: View {
	@State var currentPage: Page = .wizard
	@State private var showWelcome = true
	@EnvironmentObject var scorewindData:ScorewindData
	@State var screenMessage = "Welcome!"
	
	var body: some View {
		if showWelcome == true {
			Text(screenMessage)
				.onAppear{
					print("->WelcomeView: onAppear")
					loadScorewindCourses()
					scorewindData.initiateTimestampData()
					/*if scorewindData.studentData.getInstrumentChoice() == "" {
						scorewindData.studentData.setInstrumentChoice(instrument: "guitar")
					}*/
				}
		}else{
			if currentPage == .myCourses {
				MyCoursesView()
					.transition(.scale)
			}else{
				WizardView()
					.transition(.scale)
			}
		}
	}
}

extension WelcomeView {
	func loadScorewindCourses(){
		let courseURL = URL(fileURLWithPath: "data_scorewind_courses", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
		let courseWPURL = "https://scorewind.com/courses_ios.json"
		
		if FileManager.default.fileExists(atPath: courseURL.path) {
			print("->WelcomeView: data_scorewind_courses.json is already downloaded")
			decodeCoursesJSON(courseFilePath: courseURL.path)
		} else {
			scorewindData.downloadJson(fromURLString: courseWPURL) { (result) in
				switch result {
				case .success(let data):
					do {
						print("->WelcomeView: downloaded course json.")
						try data.write(to: courseURL, options: .atomicWrite)
						decodeCoursesJSON(courseFilePath: courseURL.path)
					} catch let error {
						print(error)
						print("->WelcomeView, failed to write course json file to disk.")
						screenMessage = "Something is wrong!"
					}
				case .failure(let error):
					print("->WelcomeView, failed to download course json")
					print(error)
					screenMessage = "Something is wrong!"
				}
			}
		}
	}
	
	func decodeCoursesJSON(courseFilePath: String){
		print("->WelcomeView, decodeCourseJSON is called")
		if scorewindData.loadLocalFile(filePath: courseFilePath) {
			print("->WelcomeView,loadLocalFile is called, result: true")
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				withAnimation{
					self.showWelcome = false
					self.currentPage = .myCourses
				}
			}
		}else{
			screenMessage = "Something is wrong!"
		}
	}
}

struct WelcomeView_Previews: PreviewProvider {
	static var previews: some View {
		WelcomeView().environmentObject(ScorewindData())
	}
}
