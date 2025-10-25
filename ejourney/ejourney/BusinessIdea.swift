//
//  BusinessIdea.swift
//  ejourney
//
//  Created by Debamitro Chakraborti on 10/24/25.
//

import Foundation

struct BusinessIdea: Identifiable, Codable {
    var id: UUID
    var description: String
    var targetMarket: String
    var effort: String
    var reward: String
    var date: Date
    
    init(id: UUID = UUID(), description: String, targetMarket: String, effort: String, reward: String, date: Date = Date()) {
        self.id = id
        self.description = description
        self.targetMarket = targetMarket
        self.effort = effort
        self.reward = reward
        self.date = date
    }
    
    enum CodingKeys: String, CodingKey {
        case id, description, targetMarket, effort, reward, date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode the id as a UUID string
        if let idString = try? container.decode(String.self, forKey: .id) {
            if let uuid = UUID(uuidString: idString) {
                self.id = uuid
            } else {
                self.id = UUID() // Fallback if the string isn't a valid UUID
            }
        } else {
            // If id is not present or not a string, generate a new UUID
            self.id = UUID()
        }
        
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
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(description, forKey: .description)
        try container.encode(targetMarket, forKey: .targetMarket)
        try container.encode(effort, forKey: .effort)
        try container.encode(reward, forKey: .reward)
        
        let formatter = ISO8601DateFormatter()
        try container.encode(formatter.string(from: date), forKey: .date)
    }
}

