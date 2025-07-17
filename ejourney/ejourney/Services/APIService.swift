//
//  APIService.swift
//  ejourney
//
//  Created by Cascade on 7/10/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case unknown
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

class APIService {
    static let shared = APIService()
    
    // Local development server URL
    private let baseURL = "http://localhost:3000/v1"
    
    private init() {}
    
    // Generic request function
    private func request<T: Decodable>(endpoint: String, method: String = "GET", body: Data? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add authentication if needed
        // request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Business Ideas API
    
    func saveIdea(_ idea: BusinessIdea) async throws -> BusinessIdea {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let data = try? encoder.encode(idea) else {
            throw APIError.unknown
        }
        
        return try await request(endpoint: "ideas", method: "POST", body: data)
    }
    
    func fetchIdeas() async throws -> [BusinessIdea] {
        return try await request(endpoint: "ideas")
    }
    
    func updateIdea(_ idea: BusinessIdea) async throws -> BusinessIdea {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let data = try? encoder.encode(idea) else {
            throw APIError.unknown
        }
        
        return try await request(endpoint: "ideas/\(idea.id)", method: "PUT", body: data)
    }
    
    func deleteIdea(id: UUID) async throws -> Bool {
        let _: EmptyResponse = try await request(endpoint: "ideas/\(id)", method: "DELETE")
        return true
    }
}

// Empty response for endpoints that don't return data
struct EmptyResponse: Codable {}
