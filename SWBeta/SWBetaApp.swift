//
//  SWBetaApp.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/2/26.
//

import SwiftUI

@main
struct SWBetaApp: App {
	@StateObject var scorewindData = ScorewindData()
	@StateObject var downloadManager = DownloadManager()
	@Environment(\.scenePhase) var scenePhase
	
	var body: some Scene {
		WindowGroup {
			WelcomeView(downloadManager: downloadManager)
				.environmentObject(scorewindData)
				.onChange(of: scenePhase, perform: { newPhase in
					if newPhase == .active {
						print("app is active\(scorewindData.firstLaunch)")
						
					} else if newPhase == .inactive {
						print("appp is inactive")
					} else if newPhase == .background {
						print("app is in the background")
					}
				})
				.onAppear {
					scorewindData.firstLaunch = false
				}
		}
	}
	
	
}
