//
//  BusinessIdea.swift
//  ejourney
//
//  Created by Debamitro Chakraborti on 10/24/25.
//

import Foundation

struct BusinessIdea: Identifiable, Codable {
    var id: Int
    var description: String
    var targetMarket: String
    var effort: String
    var reward: String
    var date: Date
    var userId: Int
    
    init(description: String, targetMarket: String, effort: String, reward: String, date: Date = Date()) {
        self.id = 0
        self.description = description
        self.targetMarket = targetMarket
        self.effort = effort
        self.reward = reward
        self.date = date
        self.userId = 1
    }
    
    enum CodingKeys: String, CodingKey {
        case id, description, targetMarket, effort, reward, date, userId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: .id)
        self.description = try container.decode(String.self, forKey: .description)
        self.targetMarket = try container.decode(String.self, forKey: .targetMarket)
        self.effort = try container.decode(String.self, forKey: .effort)
        self.reward = try container.decode(String.self, forKey: .reward)
        
        // Try to decode date as ISO8601 string, or use current date as fallback
        if let dateString = try? container.decode(String.self, forKey: .date) {
            let formatter = ISO8601DateFormatter()
            self.date = formatter.date(from: dateString) ?? Date()
        } else if let timestamp = try? container.decode(Date.self, forKey: .date) {
            self.date = timestamp
        } else {
            self.date = Date()
        }
        
        self.userId = try container.decode(Int.self, forKey: .userId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(description, forKey: .description)
        try container.encode(targetMarket, forKey: .targetMarket)
        try container.encode(effort, forKey: .effort)
        try container.encode(reward, forKey: .reward)
        try container.encode(userId, forKey: .userId)
        
        let formatter = ISO8601DateFormatter()
        try container.encode(formatter.string(from: date), forKey: .date)
    }
}

