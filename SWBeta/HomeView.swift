//
//  HomeView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/5/13.
//

import SwiftUI

struct HomeView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@State private var selectedTab = "TWizard"
	@ObservedObject var downloadManager: DownloadManager
	@Environment(\.scenePhase) var scenePhase
	
	var body: some View {
		if scorewindData.currentView != Page.lessonFullScreen {
			TabView(selection: $selectedTab) {
				WizardView(selectedTab: $selectedTab)
					.tabItem {
						Image(systemName: "eyes")
						Text("Wizard")
					}.tag("TWizard")
				
				MyCoursesView(selectedTab: $selectedTab)
					.tabItem {
						Image(systemName: "music.note.list")
						Text("My Courses")
					}.tag("TMyCourses")
				
				if scorewindData.currentCourse.id > 0 {
					CourseView(selectedTab: $selectedTab, downloadManager: downloadManager)
						.tabItem {
							Image(systemName: "note.text")
							Text("Course")
						}.tag("TCourse")
				}
				
				if scorewindData.currentLesson.id > 0 {
					LessonView()
						.tabItem {
							Image(systemName: "note")
							Text("Lesson")
						}.tag("TLesson")
				}
			}
			.ignoresSafeArea()
			.onChange(of: scenePhase, perform: { newPhase in
				if newPhase == .active {
					print("app is active")
					downloadManager.buildDownloadListFromJSON(allCourses: scorewindData.allCourses)
				} else if newPhase == .inactive {
					print("appp is inactive")
				} else if newPhase == .background {
					print("app is in the background")
				}
			})
			/*.onReceive(downloadManager.callForDownloadPublisher, perform: { value in
			 if value == true {
			 Task {
			 await downloadManager.testPublisherTrigger(caller: "HomeView, tabView")
			 }
			 }
			 })*/
		} else {
			if scorewindData.currentView == Page.lessonFullScreen {
				LessonView()
					.onChange(of: scenePhase, perform: { newPhase in
						if newPhase == .active {
							print("app is active")
							downloadManager.buildDownloadListFromJSON(allCourses: scorewindData.allCourses)
						} else if newPhase == .inactive {
							print("appp is inactive")
						} else if newPhase == .background {
							print("app is in the background")
						}
					})
			}
		}
	}
		
}


struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView(downloadManager: DownloadManager()).environmentObject(ScorewindData())
	}
}
