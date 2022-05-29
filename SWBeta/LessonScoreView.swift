//
//  LessonScoreView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/5/14.
//

import SwiftUI
import AVFoundation

struct LessonScoreView: View {
	var viewModel:ViewModel
	@EnvironmentObject var scorewindData:ScorewindData
	
	var body: some View {
		VStack() {
			if scorewindData.currentLesson.scoreViewer.isEmpty {
				Text("no score in this course")
			} else {
			WebView(url: .localUrl, viewModel: viewModel, scorewindData: scorewindData)
				.padding(.leading, 0)
				.padding(.trailing, 0)
				.padding(.bottom, 0)
				.onAppear(perform: {
					print(scorewindData.timestampToJson())
				})
			}
			
		}
	}
}

struct LessonScoreView_Previews: PreviewProvider {
	//@State static var player = AVPlayer()
	static var previews: some View {
		LessonScoreView(viewModel: ViewModel()).environmentObject(ScorewindData())
	}
}
