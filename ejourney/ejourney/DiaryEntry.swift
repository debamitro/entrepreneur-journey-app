//
//  DiaryEntry.swift
//  ejourney
//
//  Created by Cascade on 7/10/25.
//

import Foundation

struct DiaryEntry: Codable, Identifiable {
    let id: Int
    var content: String
    var category: String
    var userId: Int
    var createdAt: Date
    var updatedAt: Date
    
    init(content: String = "") {
        self.id = 0
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.category = "ENTREPRENEUR"
        self.userId = 1
    }
}
