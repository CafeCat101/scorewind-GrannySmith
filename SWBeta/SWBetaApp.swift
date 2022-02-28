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
	
	var body: some Scene {
		WindowGroup {
			WelceomView().environmentObject(scorewindData)
		}
	}
}
