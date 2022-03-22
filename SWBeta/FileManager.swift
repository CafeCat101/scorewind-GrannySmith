//
//  FileManager.swift
//  SWBeta
//
//  Created by Leonore Yardimli on 2022/3/13.
//

import Foundation

public extension FileManager {
	static var documentoryDirecotryURL: URL {
	`default`.urls(for: .documentDirectory, in: .userDomainMask)[0]
	}
}
