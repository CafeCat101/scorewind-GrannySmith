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
			List {
				Section(header: Text("Lessons in this course")){
					ForEach(scorewindData.currentCourse.lessons){ lesson in
						Button(action: {
							self.isPresented = false
							scorewindData.currentLesson = lesson
							scorewindData.setCurrentTimestampRecs()
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
	}
}

struct LessonSheetView_Previews: PreviewProvider {
	static var previews: some View {
		LessonSheetView(isPresented: .constant(false)).environmentObject(ScorewindData())
	}
}
