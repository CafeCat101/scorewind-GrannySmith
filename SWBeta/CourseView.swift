//
//  CourseView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI
import WebKit

struct CourseView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@State private var showOverview = true
	let screenSize: CGRect = UIScreen.main.bounds
	@State private var OverviewLabelColor = Color.black
	@State private var LessonsLabelColor = Color.gray
	@State private var ContinueLabelColor = Color.gray
	@Binding var selectedTab:String
	@State private var selectedSection = courseSection.overview
	
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
					selectedSection = courseSection.overview
					setSelectionLabelColor()
				}) {
					Text("Overview")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(OverviewLabelColor)
				}
				.frame(width: screenSize.width/3)
				
				Spacer()
					.frame(width:5)
				
				Button(action: {
					selectedSection = courseSection.lessons
					setSelectionLabelColor()
				}) {
					Text("Lessons")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(LessonsLabelColor)
				}
				.frame(width: screenSize.width/3)
				
				Button(action: {
					selectedSection = courseSection.continue
					setSelectionLabelColor()
				}) {
					Text("Continue")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(ContinueLabelColor)
				}
				.frame(width: screenSize.width/3)
				
			}
			.frame(height: screenSize.width/10)
			
			if selectedSection == courseSection.overview {
				HTMLString(htmlContent: scorewindData.removeWhatsNext(Text: scorewindData.currentCourse.content))
			} else if selectedSection == courseSection.lessons{
				VStack {
					HStack {
						Button(action:{
							
						}){
							Label("Download for offline", systemImage: "square.and.arrow.down")
								.labelStyle(.titleAndIcon)
						}
					}
					List {
						Section(header: Text("In this course...")) {
							ForEach(scorewindData.currentCourse.lessons){ lesson in
								Button(action: {
									scorewindData.currentLesson = lesson
									scorewindData.setCurrentTimestampRecs()
									scorewindData.currentView = Page.lesson
									scorewindData.lastPlaybackTime = 0.0
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
			} else if selectedSection == courseSection.continue {
				List {
					Section(header: Text("Next course")) {
						Button(action: {
							
						}) {
							Text("Next course's title")
								.foregroundColor(Color.black)
						}
					}
					
					Section(header: Text("previous course")) {
						Button(action: {
							
						}) {
							Text("Previous course's title")
								.foregroundColor(Color.black)
						}
					}
				}
			}
			
			Spacer()
		}
		.onAppear(perform: {
			scorewindData.findPreviousCourse()
			scorewindData.findNextCourse()
		})
	}
	
	private func setSelectionLabelColor() {
		if selectedSection == courseSection.overview {
			OverviewLabelColor = .black
			LessonsLabelColor = .gray
			ContinueLabelColor = .gray
		}
		
		if selectedSection == courseSection.lessons {
			OverviewLabelColor = .gray
			LessonsLabelColor = .black
			ContinueLabelColor = .gray
		}
		
		if selectedSection == courseSection.continue {
			OverviewLabelColor = .gray
			LessonsLabelColor = .gray
			ContinueLabelColor = .black
		}
	}
	
	private func checkDownloadStatus(lessonID:Int) -> Int {
		var finalDownloadStatus = 0
		var getVideoDownloadStatus = 0
		var getXMLDownloadStatus = 0
		
		if let findIndex = scorewindData.downloadList.firstIndex(where: {$0.lessonID == lessonID}) {
			getVideoDownloadStatus = scorewindData.downloadList[findIndex].videoDownloadStatus
			getXMLDownloadStatus = scorewindData.downloadList[findIndex].xmlDownloadStatus
		}
		
		if getVideoDownloadStatus+getXMLDownloadStatus == 0 {
			finalDownloadStatus = 0
		} else if getVideoDownloadStatus == 3 && getXMLDownloadStatus == 3 {
			finalDownloadStatus = DownloadStatus.downloaded.rawValue
		}
		return finalDownloadStatus
	}
}

struct CourseView_Previews: PreviewProvider {
	@State static var tab = "TCourse"
	static var previews: some View {
		CourseView(selectedTab: $tab).environmentObject(ScorewindData())
	}
}

enum courseSection {
	case overview
	case lessons
	case `continue`
}
