//
//  LessonSheetView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/5/14.
//

import SwiftUI

struct LessonSheetView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var isPresented:Bool
	
	var body: some View {
		VStack {
			/*HStack {
				Button(action:{
					withAnimation{
						scorewindData.currentView = Page.lessonFullScreen
					}
				}){
					RoundedRectangle(cornerRadius: 10, style: .continuous)
						.strokeBorder(Color.gray,lineWidth: 1)
						.background(
							RoundedRectangle(cornerRadius: 10, style: .continuous)
								.foregroundColor(Color.gray.opacity(0.8)))
						.frame(height:60)
						.overlay(
							Text("Focus mode")
								.foregroundColor(Color.white)
						)
				}.buttonStyle(PlainButtonStyle())
				Spacer()
			}
			.padding(SwiftUI.EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))*/
			
			
			List {
				Button(action:{
					if scorewindData.currentView == Page.lesson {
						scorewindData.currentView = Page.lessonFullScreen
					} else {
						scorewindData.currentView = Page.lesson
					}
				}){
					if scorewindData.currentView == Page.lesson {
						Label("Focus mode", systemImage: "lightbulb.circle.fill")
							.labelStyle(.titleAndIcon)
							.foregroundColor(.black)
					} else {
						Label("Explore mode", systemImage: "lightbulb.circle")
							.labelStyle(.titleAndIcon)
							.foregroundColor(.black)
					}
				}
				Section(header: Text("Lessons in this course")){
					ForEach(scorewindData.currentCourse.lessons){ lesson in
						Button(action: {
							self.isPresented = false
							scorewindData.currentLesson = lesson
							scorewindData.setCurrentTimestampRecs()
							scorewindData.lastPlaybackTime = 0.0
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
		//.background(Color("LessonSheet"))
	}
}

struct LessonSheetView_Previews: PreviewProvider {
	static var previews: some View {
		LessonSheetView(isPresented: .constant(false)).environmentObject(ScorewindData())
	}
}
