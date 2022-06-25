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
					courseDownloadButtonView()
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
		if getStatus == DownloadStatus.inQueue.rawValue {
			Image(systemName: "arrow.down.square")
				.foregroundColor(Color.gray)
		} else if getStatus == DownloadStatus.downloading.rawValue {
			Image(systemName: "square.and.arrow.down.on.square.fill")
				.foregroundColor(.blue)
		} else if getStatus == DownloadStatus.downloaded.rawValue {
			Image(systemName: "arrow.down.square.fill")
				.foregroundColor(Color.green)
		} else if getStatus == DownloadStatus.failed.rawValue {
			Image(systemName: "exclamationmark.square")
				.foregroundColor(Color.gray)
		}
	}
	
	@ViewBuilder
	private func courseDownloadButtonView() -> some View {
		let getStatus =  downloadManager.checkDownloadStatus(courseID: scorewindData.currentCourse.id, lessonsCount: scorewindData.currentCourse.lessons.count)
		
		HStack {
			if getStatus == DownloadStatus.notInQueue {
				Image(systemName: "arrow.down.to.line")
					.foregroundColor(Color.black)
			} else if getStatus == DownloadStatus.inQueue {
				Image(systemName: "arrow.down.square")
					.foregroundColor(Color.gray)
			} else if getStatus == DownloadStatus.downloading {
				Image(systemName: "square.and.arrow.down.on.square.fill")
					.foregroundColor(.blue)
			} else if getStatus == DownloadStatus.downloaded {
				Image(systemName: "arrow.down.square.fill")
					.foregroundColor(Color.green)
			} else if getStatus == DownloadStatus.failed {
				Image(systemName: "exclamationmark.square")
					.foregroundColor(Color.green)
			}
			
			Button(action: {
				showDownloadAlert = true
			}) {
				if getStatus == DownloadStatus.notInQueue {
					Text("Download course for offline")
						.foregroundColor(Color.black)
				} else {
					Text("Remove downloads")
						.foregroundColor(Color.black)
				}
			}
			.alert("\(getAlertDialogTitle(downloadStatus:getStatus))", isPresented: $showDownloadAlert, actions: {
				Button("ok", action:{
					print("[debug] CourseView, alert ok.")
					showDownloadAlert = false
					downloadManager.addOrRemoveCourseOffline(currentCourseDownloadStatus: getStatus, courseID: scorewindData.currentCourse.id, lessons: scorewindData.currentCourse.lessons)
					if downloadManager.downloadingCourse == 0 && getStatus == DownloadStatus.notInQueue {
						Task {
							print("[debug] download all Task")
							do {
								try await downloadManager.downloadVideos(allCourses: scorewindData.allCourses)
							} catch {
								print("[debug] download all, catch, \(error)")
							}
							
						}
					} else {
						print("[debug] downloadVideoXML task is running.")
					}
					
				})
				Button("Cancel", role:.cancel, action:{
					showDownloadAlert = false
				})
			}, message: {
				if getStatus == DownloadStatus.notInQueue {
					Text("128 MB course content will be downloaded into your device. Continue?")
				} else {
					Text("After removing downloads, you can not take course offline. Continue?")
				}
			})
		}
	}
	
	private func getAlertDialogTitle(downloadStatus: DownloadStatus) -> String {
		if downloadStatus == DownloadStatus.notInQueue {
			return "Download course"
		} else {
			return "Remove download"
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
