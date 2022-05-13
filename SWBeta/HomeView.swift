//
//  HomeView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/5/13.
//

import SwiftUI

struct HomeView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@State private var selectedTab = "TMyCourses"
	
	var body: some View {
		if scorewindData.currentView != Page.lessonFullScreen {
			TabView(selection: $selectedTab) {
				WizardView()
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
					CourseView(selectedTab: $selectedTab)
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
			}.ignoresSafeArea()
		} else {
			if scorewindData.currentView == Page.lessonFullScreen {
				LessonView()
			}
		}
			
			
	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView().environmentObject(ScorewindData())
	}
}
