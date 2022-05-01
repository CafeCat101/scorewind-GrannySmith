//
//  DataVersion.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/4/27.
//

import Foundation
struct DataVersion: Codable, Identifiable {
	var id = UUID()
	var version: Int
	var updated: String
	
	/*enum CodingKeys: String, CodingKey {
		//case id = UUID()
		case measure = "measure"
		case timestamp = "timestamp"
		case repeatCount = "repeat"
	}*/
}
