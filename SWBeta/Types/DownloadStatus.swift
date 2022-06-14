//
//  DownloadStatus.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/6/1.
//

import Foundation

enum DownloadStatus:Int {
	case notInQueue = 0
	case inQueue = 1
	case downloading = 2
	case downloaded = 3
	case failed = 4
}
