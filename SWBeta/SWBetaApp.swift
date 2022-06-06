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
	
	var body: some Scene {
		WindowGroup {
			WelcomeView(downloadManager: downloadManager).environmentObject(scorewindData)
		}
	}
}
