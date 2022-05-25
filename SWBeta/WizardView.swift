//
//  WizardView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI

struct WizardView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	
	var body: some View {
		VStack {
			Label("Scorewind", systemImage: "music.note")
					.labelStyle(.titleAndIcon)
			List {
				Section(header: Text("All")) {
					ForEach(scorewindData.allCourses) { course in
						Button(action: {
							scorewindData.currentCourse = course
							scorewindData.currentView = Page.course
							scorewindData.currentLesson = Lesson()
							self.selectedTab = "TCourse"
						}) {
							if course.id == scorewindData.currentCourse.id {
								Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
									.foregroundColor(Color.blue)
							} else {
								Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
									.foregroundColor(Color.black)
							}
							
						}
					}
				}
			}
			.listStyle(GroupedListStyle())
		}
		
	}
}

struct WizardView_Previews: PreviewProvider {
	@State static var tab = "TMyCourses"
	static var previews: some View {
		WizardView(selectedTab: $tab).environmentObject(ScorewindData())
	}
}
