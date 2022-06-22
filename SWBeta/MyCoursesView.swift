//
//  MyCoursesView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI

struct MyCoursesView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@Binding var selectedTab:String
	
	var body: some View {
		VStack {
			/*HStack {
				Spacer()
				Label("Scorewind", systemImage: "music.note")
						.labelStyle(.titleAndIcon)
				Spacer()
			}.padding().background(Color("ScreenTitleBg"))*/
			Label("Scorewind", systemImage: "music.note")
					.labelStyle(.titleAndIcon)
			Spacer()
			Text("My Courses View")
			Spacer()
			/*if scorewindData.studentData.getInstrumentChoice() == "" {
			 Text("== no instrument choice ==")
			 }else{
			 Text(scorewindData.studentData.getInstrumentChoice())
			 }*/
			/*ForEach(scorewindData.allCourses, id: \.id) { course in
			 Text(scorewindData.replaceCommonHTMLNumber(htmlString: course.title))
			 }*/
			
		}
		
	}
}

struct MyCoursesView_Previews: PreviewProvider {
	@State static var tab = "TMyCourses"
	static var previews: some View {
		MyCoursesView(selectedTab:$tab).environmentObject(ScorewindData())
	}
}
