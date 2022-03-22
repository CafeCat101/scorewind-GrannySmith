//
//  MyCoursesView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI

struct MyCoursesView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	var body: some View {
		VStack {
			ForEach(scorewindData.allCourses, id: \.id) { course in
				Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
			}
		}
		Text("Course page")
	}
	
	
}

struct MyCoursesView_Previews: PreviewProvider {
	static var previews: some View {
		CourseView().environmentObject(ScorewindData())
	}
}
