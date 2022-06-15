//
//  HomeView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/5/13.
//

import SwiftUI

struct HomeView: View {
	@EnvironmentObject var scorewindData:ScorewindData
	@State private var selectedTab = "TWizard"
	@ObservedObject var downloadManager: DownloadManager
	@Environment(\.scenePhase) var scenePhase
	
	var body: some View {
		if scorewindData.currentView != Page.lessonFullScreen {
			TabView(selection: $selectedTab) {
				WizardView(selectedTab: $selectedTab)
					.tabItem {
						Image(systemName: "eyes")
						Text("Wizard")
					}.tag("TWizard")
				
				MyCoursesView(selectedTab: $selectedTab)
					.tabItem {
						Image(systemName: "music.note.list")
						Text("My Courses")
					}.tag("TMyCourses")
				
				if scorewindData.currentCourse.id > 0 {
					CourseView(selectedTab: $selectedTab, downloadManager: downloadManager)
						.tabItem {
							Image(systemName: "note.text")
							Text("Course")
						}.tag("TCourse")
				}
				
				if scorewindData.currentLesson.id > 0 {
					LessonView()
						.tabItem {
							Image(systemName: "note")
							Text("Lesson")
						}.tag("TLesson")
				}
			}
			.ignoresSafeArea()
			.onChange(of: scenePhase, perform: { newPhase in
				if newPhase == .active {
					print("app is active")
					downloadManager.buildDownloadListFromJSON(allCourses: scorewindData.allCourses)
					/*if downloadManager.appState == .background {
						print("[debug] HomeView, tabview, downloadManager.appState=background")
						downloadManager.buildDownloadListFromJSON(allCourses: scorewindData.allCourses)
						Task {
							print("[debug] HomeView, downloadVideoXML")
							do {
								try await downloadManager.downloadVideoXML(allCourses: scorewindData.allCourses)
							} catch {
								print("[debug] HomeView, downloadVideoXML, catch, \(error)")
							}
						}
					}
					downloadManager.appState = .active*/
				} else if newPhase == .inactive {
					print("appp is inactive")
					//downloadManager.appState = .inactive
				} else if newPhase == .background {
					print("app is in the background")
					//downloadManager.appState = .background
				}
			})
			.onReceive(downloadManager.downloadTaskPublisher, perform: { value in
				print("HomeView,onRecieve, downloadTaskPublisher:\(value.count)")
			})
		} else {
			if scorewindData.currentView == Page.lessonFullScreen {
				LessonView()
					.onChange(of: scenePhase, perform: { newPhase in
						if newPhase == .active {
							print("app is active")
							downloadManager.buildDownloadListFromJSON(allCourses: scorewindData.allCourses)
							
							/*if downloadManager.appState == .background {
								print("[debug] HomeView, tabview, downloadManager.appState=background")
								downloadManager.buildDownloadListFromJSON(allCourses: scorewindData.allCourses)
								Task {
									print("[debug] HomeView, downloadVideoXML")
									do {
										try await downloadManager.downloadVideoXML(allCourses: scorewindData.allCourses)
									} catch {
										print("[debug] HomeView, downloadVideoXML, catch, \(error)")
									}
								}
							}
							downloadManager.appState = .active*/
						} else if newPhase == .inactive {
							print("appp is inactive")
							//downloadManager.appState = .inactive
						} else if newPhase == .background {
							print("app is in the background")
							//downloadManager.appState = .background
						}
					})
			}
		}
	}
		
}


struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView(downloadManager: DownloadManager()).environmentObject(ScorewindData())
	}
}
