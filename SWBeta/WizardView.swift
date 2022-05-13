//
//  WizardView.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/4.
//

import SwiftUI

struct WizardView: View {
	var body: some View {
		VStack {
			Label("Scorewind", systemImage: "music.note")
					.labelStyle(.titleAndIcon)
			Spacer()
			Text("Wizard View")
			Spacer()
		}
		
	}
}

struct WizardView_Previews: PreviewProvider {
	static var previews: some View {
		WizardView()
	}
}
