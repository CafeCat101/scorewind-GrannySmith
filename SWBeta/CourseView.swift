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
	@Binding var selectedTab:String
	@State private var selectedSection = courseSection.overview
	@ObservedObject var downloadManager:DownloadManager
	@State private var testDownloadStatus = true //remove this later
	@State private var showDownloadAlert = false
	
	var body: some View {
		VStack {
			Text("\(scorewindData.replaceCommonHTMLNumber(htmlString: scorewindData.currentCourse.title))")
				.font(.title2)
			
			HStack {
				Button(action: {
					selectedSection = courseSection.overview
				}) {
					Text("Overview")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(selectedSection == courseSection.overview ? Color.black : Color.gray)
				}
				.frame(width: screenSize.width/3)
				
				Spacer()
					.frame(width:5)
				
				Button(action: {
					selectedSection = courseSection.lessons
				}) {
					Text("Lessons")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(selectedSection == courseSection.lessons ? Color.black : Color.gray)
				}
				.frame(width: screenSize.width/3)
				
				Button(action: {
					selectedSection = courseSection.continue
				}) {
					Text("Continue")
						.font(.headline)
						.fontWeight(.semibold)
						.foregroundColor(selectedSection == courseSection.continue ? Color.black : Color.gray)
				}
				.frame(width: screenSize.width/3)
				
			}
			.frame(height: screenSize.width/10)
			
			if selectedSection == courseSection.overview {
				HTMLString(htmlContent: scorewindData.removeWhatsNext(Text: scorewindData.currentCourse.content))
			} else if selectedSection == courseSection.lessons{
				VStack {
					HStack {
						if downloadManager.checkDownloadStatus(courseID: scorewindData.currentCourse.id, lessonsCount: scorewindData.currentCourse.lessons.count) == DownloadStatus.notInQueue {
							Button(action:{
								showDownloadAlert = true
							}){
								Label("Download for offline", systemImage: "arrow.down.to.line.compact")
									.labelStyle(.titleAndIcon)
									.foregroundColor(Color.black)
							}
							.alert("Download course contents", isPresented: $showDownloadAlert, actions: {
								Button("ok", action:{
									print("[debug] CourseView, alert ok.")
									//downloadManager.downloadCourse(course: scorewindData.currentCourse)
									showDownloadAlert = false
								})
								Button("Cancel", role:.cancel, action:{
									showDownloadAlert = false
								})
							}, message: {
								Text("128 MB course content will be downloaded into your device. Continue?")
							})
						} else if downloadManager.checkDownloadStatus(courseID: scorewindData.currentCourse.id, lessonsCount: scorewindData.currentCourse.lessons.count) == DownloadStatus.inQueue {
							Button(action:{
								//testLessonDownloadStatusUpdate()
								//can call cancel download
							}){
								Label("In queue", systemImage: "arrow.down.square")
									.labelStyle(.titleAndIcon)
							}
						} else if downloadManager.checkDownloadStatus(courseID: scorewindData.currentCourse.id, lessonsCount: scorewindData.currentCourse.lessons.count) == DownloadStatus.downloading {
							Button(action:{
								//can call cancel download
							}){
								Label("Downloading", systemImage: "square.and.arrow.down.on.square.fill")
									.labelStyle(.titleAndIcon)
							}
						} else if downloadManager.checkDownloadStatus(courseID: scorewindData.currentCourse.id, lessonsCount: scorewindData.currentCourse.lessons.count) == DownloadStatus.downloaded {
							Button(action:{
								showDownloadAlert = true
							}){
								Label("Downloaded", systemImage: "arrow.down.square.fill")
									.labelStyle(.titleAndIcon)
							}
							.alert("Remove download", isPresented: $showDownloadAlert, actions: {
								Button("ok", action:{
									print("[debug] CourseView, alert ok.")
									showDownloadAlert = false
									//remove downloaded video and xml
								})
								Button("Cancel", role:.cancel, action:{
									showDownloadAlert = false
								})
							}, message: {
								Text("By removing download, you can not take course offline. Continue?")
							})
						}
						
					}
					List {
						Section(header: Text("In this course...")) {
							ForEach(scorewindData.currentCourse.lessons){ lesson in
								HStack {
									downloadIconView(getLessonID: lesson.id)
										.foregroundColor(scorewindData.currentLesson.title == lesson.title ? Color.green : Color.black)
									
									Button(action: {
										scorewindData.currentLesson = lesson
										scorewindData.setCurrentTimestampRecs()
										scorewindData.currentView = Page.lesson
										scorewindData.lastPlaybackTime = 0.0
										self.selectedTab = "TLesson"
									}) {
										Text(scorewindData.replaceCommonHTMLNumber(htmlString: lesson.title))
											.foregroundColor(scorewindData.currentLesson.title == lesson.title ? Color.green : Color.black)
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
	
	@ViewBuilder
	private func downloadIconView(getLessonID: Int) -> some View {
		let getStatus =  downloadManager.checkDownloadStatus(lessonID: getLessonID)
		if getStatus == 1 {
			Image(systemName: "arrow.down.square")
				.foregroundColor(Color.gray)
		} else if getStatus == 2 {
			Image(systemName: "square.and.arrow.down.on.square.fill")
				.foregroundColor(.blue)
		} else if getStatus == 3 {
			Image(systemName: "arrow.down.square.fill")
				.foregroundColor(Color.green)
		}
	}
	
	private func testLessonDownloadStatusUpdate() {
		if testDownloadStatus == true {
			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				print("[deubg] CourseView, alter downloadManager.downloadList 1")
				downloadManager.downloadList.append(DownloadItem(courseID: 0, lessonID: 90696, videoDownloadStatus: 1, xmlDownloadStatus: 0))
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
				print("[deubg] CourseView, alter downloadManager.downloadList 2")
				if let findIndex = downloadManager.downloadList.firstIndex(where: {$0.lessonID == 90696}) {
					downloadManager.downloadList[findIndex].videoDownloadStatus = 2
					downloadManager.downloadList[findIndex].xmlDownloadStatus = 1
				}
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
				print("[deubg] CourseView, alter downloadManager.downloadList 3")
				if let findIndex = downloadManager.downloadList.firstIndex(where: {$0.lessonID == 90696}) {
					downloadManager.downloadList[findIndex].videoDownloadStatus = 3
					downloadManager.downloadList[findIndex].xmlDownloadStatus = 3
				}
				testDownloadStatus = false
			}
		 }
	}

}

struct CourseView_Previews: PreviewProvider {
	@State static var tab = "TCourse"
	static var previews: some View {
		CourseView(selectedTab: $tab, downloadManager: DownloadManager()).environmentObject(ScorewindData())
	}
}

enum courseSection {
	case overview
	case lessons
	case `continue`
}
