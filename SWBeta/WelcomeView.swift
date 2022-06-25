//
//  WelceomView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/2/28.
//

import SwiftUI

struct WelcomeView: View {
	//@State var currentPage: Page = .wizard
	@State private var showWelcome = true
	@EnvironmentObject var scorewindData:ScorewindData
	@State var screenMessage = "Welcome!"
	@ObservedObject var downloadManager:DownloadManager
	
	var body: some View {
		if showWelcome == true {
			VStack {
				Spacer()
				Image("logo")
				HStack {
					Spacer()
					Text(screenMessage)
						.font(.title)
					Spacer()
				}
				Spacer()
			}
			.background(
				Image("WelcomeViewBg")
					.resizable()
					.scaledToFill()
					.ignoresSafeArea()
			)
			.onAppear{
				print("->WelcomeView: onAppear")
				checkDataVersion()
			}
				
		}else{
			/*if currentPage == .myCourses {
				MyCoursesView()
					.transition(.scale)
			}else{
				WizardView()
					.transition(.scale)
			}*/
			HomeView(downloadManager: downloadManager)
		}
	}
}

extension WelcomeView {
	func checkDataVersion() {
		let dataVersionURL = URL(fileURLWithPath: "data_version", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
		
		if FileManager.default.fileExists(atPath: dataVersionURL.path) {
			//regular launch
			let currentDataVersion = scorewindData.needToCheckVersion()
			if currentDataVersion > 0 {
				//check version from web
				print("->Check data version from the web.")
				scorewindData.downloadJson(fromURLString: scorewindData.dataVersionWPURL) { (result) in
					switch result {
					case .success(let data):
						do {
							let tempDataVersionURL = URL(fileURLWithPath: "data_version_", relativeTo: FileManager.documentoryDirecotryURL).appendingPathExtension("json")
							try data.write(to: tempDataVersionURL, options: .atomicWrite)
							let tempJsonData = try String(contentsOfFile: tempDataVersionURL.path).data(using: .utf8)
							let tempDataVersionDic = try JSONSerialization.jsonObject(with: tempJsonData!, options: .mutableContainers) as? [String:Any]
							let dataVersionFromWeb = tempDataVersionDic!["version"] as? Int ?? 0
							
							let jsonData = try String(contentsOfFile: dataVersionURL.path).data(using: .utf8)
							var dataVersionDic = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers) as? [String:Any]
							if dataVersionFromWeb > currentDataVersion {
								print("->Has newer data from web.")
								//download course and timestamp data, when it's done. update the real data version content then remove the temp data version file
								scorewindData.downloadJson(fromURLString: scorewindData.courseWPURL) { (result) in
									switch result {
									case .success(let data):
										do {
											print("->WelcomeView: downloaded course json.")
											try data.write(to: scorewindData.courseURL, options: .atomicWrite)
											
											scorewindData.downloadJson(fromURLString: scorewindData.timestampWPURL) { (result) in
												switch result {
												case .success(let data):
													do {
														print("->WelcomeView: downloaded timestamps json.")
														try data.write(to: scorewindData.timestampURL, options: .atomicWrite)
														if FileManager.default.fileExists(atPath: scorewindData.courseURL.path) && FileManager.default.fileExists(atPath: scorewindData.timestampURL.path) {
															dataVersionDic?["version"] = dataVersionFromWeb
															let today = Date()
															let todayFormatter = DateFormatter()
															todayFormatter.dateFormat = "YYYY-MM-dd"
															dataVersionDic?["updated"] = todayFormatter.string(from:today)
															
															let backToJSONData = try JSONSerialization.data(withJSONObject: dataVersionDic as Any)
															try backToJSONData.write(to: dataVersionURL,options: .atomicWrite)
															try FileManager.default.removeItem(at: tempDataVersionURL)
														}
														
														setupDataObjects()
													} catch let error {
														print(error)
														print("->WelcomeView, failed to write course json file to disk.")
														screenMessage = "Sorry, we couldn't finish downloading course data. Please relaunch the app to try again."
													}
												case .failure(let error):
													print("->WelcomeView, failed to download course json")
													print(error)
													screenMessage = "Sorry, we couldn't finish downloading course data. Please relaunch the app to try again."
												}
											}
										} catch let error {
											print(error)
											print("->WelcomeView, failed to write course json file to disk.")
											screenMessage = "Sorry, we couldn't finish downloading course data. Please relaunch the app to try again."
										}
									case .failure(let error):
										print("->WelcomeView, failed to download course json")
										print(error)
										screenMessage = "Sorry, we couldn't finish downloading course data. Please relaunch the app to try again."
									}
								}
							}else{
								print("->Data version from the web(\(dataVersionFromWeb)) v.s the one on local(\(currentDataVersion))")
								let today = Date()
								let todayFormatter = DateFormatter()
								todayFormatter.dateFormat = "YYYY-MM-dd"
								dataVersionDic?["updated"] = todayFormatter.string(from:today)
								let backToJSONData = try JSONSerialization.data(withJSONObject: dataVersionDic as Any)
								try backToJSONData.write(to: dataVersionURL,options: .atomicWrite)
								try FileManager.default.removeItem(at: tempDataVersionURL)
								setupDataObjects()
							}
						} catch let error {
							print(error)
							screenMessage = "\(error.localizedDescription)"
						}
					case .failure(let error):
						print(error)
						screenMessage = "\(error.localizedDescription)"
					}
				}
			}else{
				//version 0 means no just check the version within 30 days
				//initiate data objects from local file
				print("->No need to check version from web. difference:\(currentDataVersion)")
				setupDataObjects()
			}
		}else{
			//first launch
			let errorMessage = scorewindData.firstLaunch()
			if !errorMessage.isEmpty {
				screenMessage = errorMessage
			}else{
				setupDataObjects()
			}
		}
	}
	
	func setupDataObjects(){
		scorewindData.initiateTimestampsFromLocal()
		scorewindData.initiateCoursesFromLocal()
		scorewindData.setupWWW()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			withAnimation{
				showWelcome = false
			}
		}
		downloadManager.buildDownloadListFromJSON(allCourses: scorewindData.allCourses)
		Task {
			print("[debug] WelcomeView, Task:downloadVideoXML")
			do {
				try await downloadManager.downloadVideos(allCourses: scorewindData.allCourses)
			} catch {
				print("[debug] WelcomeView, Task:downloadVideoXML, catch, \(error)")
			}
		}
	}
}

struct WelcomeView_Previews: PreviewProvider {
	static var previews: some View {
		WelcomeView(downloadManager: DownloadManager()).environmentObject(ScorewindData())
	}
}
