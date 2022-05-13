//
//  CourseView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI

struct CourseView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@State private var showOverview = true
	let screenSize: CGRect = UIScreen.main.bounds
	@State private var OverviewLabelColor = Color.black
	@State private var LessonsLabelColor = Color.gray
	@Binding var selectedTab:String
	
	var body: some View {
		VStack {
			Text("\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentCourse.title))")
				.font(.title2)
			
			/*Button(action: {
				//showNavigationGuide = true
			}) {
				Text("\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentCourse.title))")
					.font(.title2)
					.foregroundColor(Color.black)
			}*/
			HStack {
				Button(action: {
					showOverview = true
					OverviewLabelColor = Color.black
					LessonsLabelColor = Color.gray
				}) {
					Text("Overview")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(OverviewLabelColor)
				}
				.frame(width: screenSize.width/2)
				
				Spacer()
					.frame(width:5)
				
				Button(action: {
					showOverview = false
					OverviewLabelColor = Color.gray
					LessonsLabelColor = Color.black
				}) {
					Text("Lessons")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(LessonsLabelColor)
				}
				.frame(width: screenSize.width/2)
			}
			.frame(height: screenSize.width/10)
			
			if showOverview {
				HTMLString(htmlContent: scorewindData.removeWhatsNext(Text: scorewindData.currentCourse.content))
			} else {
				List {
					Section(header: Text("In this course...")) {
						ForEach(scorewindData.currentCourse.lessons){ lesson in
							Button(action: {
								//self.isPresented = false
								scorewindData.currentLesson = lesson
								scorewindData.currentView = Page.lesson
								self.selectedTab = "TLesson"
							}) {
								if scorewindData.currentLesson.title == lesson.title {
									Text(scorewindData.replaceCommonHTMLNumber(htmlString: lesson.title))
										.foregroundColor(Color.green)
								}else{
									Text(scorewindData.replaceCommonHTMLNumber(htmlString: lesson.title))
										.foregroundColor(Color.black)
								}
							}
						}
					}
				}
			}
			Spacer()
		}
		
		/*
		if goToView == Page.course {
			TabView(selection: $selectedTab) {
				VStack {
					Text("\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentCourse.title))")
						.font(.title2)
						.foregroundColor(Color.black)
					/*Button(action: {
						//showNavigationGuide = true
					}) {
						Text("\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentCourse.title))")
							.font(.title2)
							.foregroundColor(Color.black)
					}*/
					HTMLString(htmlContent: scorewindData.removeWhatsNext(Text: scorewindData.currentCourse.content))
					Spacer()
				}
				.tabItem {
					Image(systemName: "note.text")
					Text("Overview")
				}.tag(1)
				
				VStack {
					Button(action: {
						//showNavigationGuide = true
					}) {
						Text("\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentCourse.title))")
							.font(.title2)
							.foregroundColor(Color.black)
					}
					List {
						Section(header: Text("Content")) {
							ForEach(scorewindData.currentCourse.lessons){ lesson in
								Button(action: {
									//self.isPresented = false
									scorewindData.currentLesson = lesson
									goToView = Page.lesson
								}) {
									if scorewindData.currentLesson.title == lesson.title {
										Text(scorewindData.replaceCommonHTMLNumber(htmlString: lesson.title))
											.foregroundColor(Color.green)
									}else{
										Text(scorewindData.replaceCommonHTMLNumber(htmlString: lesson.title))
											.foregroundColor(Color.black)
									}
								}
							}
						}
					}
				}
				.tabItem {
					Image(systemName: "music.note.list")
					Text("Lessons") }.tag(2)
			}
			
			//.edgesIgnoringSafeArea(.bottom)
			
		}
		*/
	}
}

struct CourseView_Previews: PreviewProvider {
	@State static var tab = "TCourse"
	static var previews: some View {
		CourseView(selectedTab: $tab).environmentObject(ScorewindData())
	}
}
