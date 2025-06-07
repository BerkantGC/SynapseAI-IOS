//
//  ReadResponse.swift
//  SynapseMobile
//
//  Created by Berkant Gürcan on 12/5/24.
//

import SwiftUI

class ReadResponse : Codable {
    var read_all: Bool
    var me: Bool
    var seen_at: String?
}
