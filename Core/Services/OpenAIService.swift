//
//  OpenAIService.swift
//  WordFlow
//
//  Created by WordFlow Team on 29.06.2026.
//

import Foundation

final class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - Generate AI Content for Word
    
    func generateWordContent(for word: String) async throws -> WordAIContent {
        let prompt = """
        For the English word "\(word)", provide:
        1. A simple explanation in English (1-2 sentences)
        2. An example sentence using the word
        3. A memory association or mnemonic to help remember it
        4. Three quiz questions to test understanding
        
        Format your response as JSON with keys: explanation, example, association, quizQuestions (array of strings)
        """
        
        let content = try await makeRequest(prompt: prompt)
        return try parseWordContent(from: content)
    }
    
    // MARK: - Generate Simple Explanation
    
    func generateExplanation(for word: String) async throws -> String {
        let prompt = """
        Explain the English word "\(word)" in simple English in 1-2 sentences.
        Make it easy to understand for English learners.
        """
        
        return try await makeRequest(prompt: prompt)
    }
    
    // MARK: - Generate Example Sentence
    
    func generateExample(for word: String) async throws -> String {
        let prompt = """
        Create a simple example sentence using the English word "\(word)".
        The sentence should be easy to understand and show the word's meaning clearly.
        """
        
        return try await makeRequest(prompt: prompt)
    }
    
    // MARK: - Generate Memory Association
    
    func generateAssociation(for word: String, translation: String) async throws -> String {
        let prompt = """
        Create a fun and memorable association or mnemonic to help remember the English word "\(word)" (meaning: \(translation)).
        Keep it creative and easy to visualize.
        """
        
        return try await makeRequest(prompt: prompt)
    }
    
    // MARK: - Generate Quiz Questions
    
    func generateQuizQuestions(for word: String, count: Int = 3) async throws -> [String] {
        let prompt = """
        Generate \(count) quiz questions to test understanding of the English word "\(word)".
        Questions should vary in difficulty and test different aspects (meaning, usage, context).
        Return only the questions, one per line.
        """
        
        let response = try await makeRequest(prompt: prompt)
        return response.components(separatedBy: "\n").filter { !$0.isEmpty }
    }
    
    // MARK: - Private Methods
    
    private func makeRequest(prompt: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": "You are a helpful English language teacher."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 500
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw OpenAIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw OpenAIError.parsingError
        }
        
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func parseWordContent(from jsonString: String) throws -> WordAIContent {
        guard let data = jsonString.data(using: .utf8) else {
            throw OpenAIError.parsingError
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(WordAIContent.self, from: data)
    }
}

// MARK: - Models

struct WordAIContent: Codable {
    let explanation: String
    let example: String
    let association: String
    let quizQuestions: [String]
}

enum OpenAIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case parsingError
    case apiKeyMissing
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .parsingError:
            return "Failed to parse response"
        case .apiKeyMissing:
            return "API key is missing"
        }
    }
}
