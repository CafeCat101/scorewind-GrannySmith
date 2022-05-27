//
//  LessonTextView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/5/15.
//

import SwiftUI

struct LessonTextView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	
	var body: some View {
		HTMLString(htmlContent: scorewindData.currentLesson.content)
			.onAppear(perform: {
				scorewindData.lastViewAtScore = false
			})
	}
}

struct LessonTextView_Previews: PreviewProvider {
	static var previews: some View {
		LessonTextView().environmentObject(ScorewindData())
	}
}
