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
					LessonView(downloadManager: downloadManager)
						.tabItem {
							Image(systemName: "note")
							Text("Lesson")
						}.tag("TLesson")
				}
			}
			.ignoresSafeArea()
			.onAppear{
				//==>>>> app is launched...
				print("[debug] HomeView, onAppear")
				if downloadManager.appState == .background {
					//hide codes here so it won't be triggered when switching full lesson screen view to tab view
					print("[debug] HomeView, tabview, downloadManager.appState=background")
					setupDataObjects()
					activateDownloadVideoXML()
				}
				downloadManager.appState = .active
				//<<<<==
			}
			.onChange(of: scenePhase, perform: { newPhase in
				if newPhase == .active {
					print("[deubg] HomeView, app is active")
					if downloadManager.appState == .background {
						print("[debug] HomeView, tabview, downloadManager.appState=background")
						activateDownloadVideoXML()
					}
					downloadManager.appState = .active
				} else if newPhase == .inactive {
					print("[debug] HomeView, appp is inactive")
				} else if newPhase == .background {
					print("[debug] HomeView, app is in the background")
					downloadManager.appState = .background
				}
			})
			.onReceive(downloadManager.downloadTaskPublisher, perform: { clonedDownloadList in
				print("[deubg] HomeView,onRecieve, downloadTaskPublisher:\(clonedDownloadList.count)")
				for courseID in clonedDownloadList {
					print("[debug] HomeView, onRecieve - \(courseID)")
				}
				if downloadManager.compareDownloadList(downloadTargets: clonedDownloadList) == false {
					print("[deubg] HomeView, onRecieve, cloned and original are different, call downloadXMLVideo")
					Task {
						print("[debug] HomeView, onRecieve, Task:downloadVideoXML")
						do {
							try await downloadManager.downloadVideos(allCourses: scorewindData.allCourses)
						} catch {
							print("[debug] HomeView, onRecieve, Task:downloadVideoXML, catch, \(error)")
						}
					}
				}
			})
		} else {
			if scorewindData.currentView == Page.lessonFullScreen {
				LessonView(downloadManager: downloadManager)
					.onChange(of: scenePhase, perform: { newPhase in
						if newPhase == .active {
							print("[debug] LessonView, app is active")
							if downloadManager.appState == .background {
								print("[debug] LessonView, tabview, downloadManager.appState=background")
								activateDownloadVideoXML()
							}
							downloadManager.appState = .active
						} else if newPhase == .inactive {
							print("[debug] LessonView, appp is inactive")
						} else if newPhase == .background {
							print("[debug] LessonView, app is in the background")
							downloadManager.appState = .background
						}
					})
					.onReceive(downloadManager.downloadTaskPublisher, perform: { clonedDownloadList in
						print("[deubg] LessonView, onRecieve, downloadTaskPublisher:\(clonedDownloadList.count)")
						for courseID in clonedDownloadList {
							print("[debug] LessonView, onRecieve - \(courseID)")
						}
						if downloadManager.compareDownloadList(downloadTargets: clonedDownloadList) == false {
							print("[deubg] LessonView, onRecieve, cloned and original are different, call downloadXMLVideo")
							Task {
								print("[debug] LessonView, onRecieve, Task:downloadVideoXML")
								do {
									try await downloadManager.downloadVideos(allCourses: scorewindData.allCourses)
								} catch {
									print("[debug] LessonView, onRecieve, Task:downloadVideoXML, catch, \(error)")
								}
							}
						}
					})
			}
		}
	}
	
	private func activateDownloadVideoXML() {
		downloadManager.buildDownloadListFromJSON(allCourses: scorewindData.allCourses)
		Task {
			print("[debug] HomeView, Task:downloadVideoXML")
			do {
				try await downloadManager.downloadVideos(allCourses: scorewindData.allCourses)
			} catch {
				print("[debug] HomeView, Task:downloadVideoXML, catch, \(error)")
			}
		}
	}
	
	private func setupDataObjects(){
		print("[debug] HomeView, setupDataObject()")
		scorewindData.launchSetup(syncData: false)
		scorewindData.initiateTimestampsFromLocal()
		scorewindData.initiateCoursesFromLocal()
	}
}


struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView(downloadManager: DownloadManager()).environmentObject(ScorewindData())
	}
}
