//
//  LessonView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI
import AVKit

struct LessonView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@State private var showLessonSheet = false
	@State private var player = AVPlayer()
	let screenSize: CGRect = UIScreen.main.bounds
	@State private var watchTime = ""
	@ObservedObject var viewModel = ViewModel()
	@State private var showScore = false
	@State private var startPos:CGPoint = .zero
	@State private var isSwipping = true
	@GestureState var magnifyBy = 1.0
	@State private var magnifyStep = 1
	
	var body: some View {
		VStack {
			/*Text("\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentLesson.title))")
			 .font(.title2)*/
			Button(action:{
				showLessonSheet = true
			}) {
				Label("\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentLesson.title))", systemImage: "list.bullet.circle")
					.labelStyle(.titleAndIcon)
					.font(.title2)
					.foregroundColor(.black)
			}
			
			VideoPlayer(player: player)
				.frame(height: screenSize.height*0.35)
				.onAppear(perform: {
					setupPlayer()
				})
				.background(.black)
			
			VStack {
				if showScore == false {
					LessonTextView()
				}else {
					LessonScoreView(viewModel: viewModel,player: $player)
				}
			}
			.simultaneousGesture(
				DragGesture()
					.onChanged { gesture in
						if self.isSwipping {
							self.startPos = gesture.location
							self.isSwipping.toggle()
						}
					}
					.onEnded { gesture in
						let xDist =  abs(gesture.location.x - self.startPos.x)
						let yDist =  abs(gesture.location.y - self.startPos.y)
						if self.startPos.y <  gesture.location.y && yDist > xDist {
							//down
						}
						else if self.startPos.y >  gesture.location.y && yDist > xDist {
							//up
						}
						else if self.startPos.x > gesture.location.x && yDist < xDist {
							//left
							withAnimation{
								showScore = true
							}
						}
						else if self.startPos.x < gesture.location.x && yDist < xDist {
							//right
							withAnimation{
								showScore = false
							}
						}
						self.isSwipping.toggle()
					}
			)
			
			/*Spacer()
			 
			 Text("lesson content")
			 Button("Test full screen mode") {
			 scorewindData.currentView = Page.lessonFullScreen
			 }
			 Button("Test tab view mode") {
			 scorewindData.currentView = Page.lesson
			 }
			 */
			Spacer()
		}
		.onAppear(perform: {
			viewModel.score = scorewindData.currentLesson.scoreViewer
		})
		.sheet(isPresented: $showLessonSheet, onDismiss: {
			viewModel.score = scorewindData.currentLesson.scoreViewer
			viewModel.highlightBar = 1
			magnifyStep = 1
			
			player.pause()
			player.replaceCurrentItem(with: nil)
			setupPlayer()
		}){
			LessonSheetView(isPresented: self.$showLessonSheet)
		}
	}
	
	
	private func decodeVideoURL(videoURL:String)->String{
		let decodedURL = videoURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
		//print(decodedURL)
		return decodedURL
	}
	
	private func findMesaureByTimestamp(videoTime: Double)->Int{
		var getMeasure = 0
		for(index, theTime) in scorewindData.currentTimestampRecs.enumerated(){
			//print("index "+String(index))
			//print("timestamp "+String(theTime.measure))
			var endTimestamp = theTime.timestamp + 100
			if index < scorewindData.currentTimestampRecs.count-1 {
				endTimestamp = scorewindData.currentTimestampRecs[index+1].timestamp
			}
			print("==>")
			print("loop timestamp "+String(theTime.timestamp))
			print("endTimestamp "+String(endTimestamp))
			print("<--")
			if videoTime >= theTime.timestamp && videoTime < Double(endTimestamp) {
				getMeasure = theTime.measure
				break
			}
		}
		
		return getMeasure
	}
	
	private func setupPlayer(){
		watchTime = ""
		
		player = AVPlayer(url: URL(string: decodeVideoURL(videoURL: scorewindData.currentLesson.video))!)
		
		player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 3), queue: .main, using: { time in
			let catchTime = time.seconds
			let atMeasure = findMesaureByTimestamp(videoTime: catchTime)
			self.viewModel.valuePublisher.send(String(atMeasure))
			self.viewModel.highlightBar = atMeasure
			watchTime = String(format: "%.3f", Float(catchTime))//createTimeString(time: Float(time.seconds))
			print("find measure:"+String(atMeasure))
		})
		viewModel.videoPlayer = player
	}
}

struct LessonView_Previews: PreviewProvider {
	static var previews: some View {
		LessonView().environmentObject(ScorewindData())
	}
}
