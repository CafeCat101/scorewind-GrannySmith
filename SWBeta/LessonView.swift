//
//  LessonView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI

struct LessonView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	
	var body: some View {
		VStack {
			Text("\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentLesson.title))")
				.font(.title2)
			Spacer()
			Text("lesson content")
			Button("Test full screen mode") {
				scorewindData.currentView = Page.lessonFullScreen
			}
			Button("Test tab view mode") {
				scorewindData.currentView = Page.lesson
			}
			Spacer()
		}
	}
}

struct LessonView_Previews: PreviewProvider {
	static var previews: some View {
		LessonView().environmentObject(ScorewindData())
	}
}
