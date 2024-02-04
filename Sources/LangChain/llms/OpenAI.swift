//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/10.
//


import Foundation
import Alamofire
import OpenAIKit

struct ChatResponse: Decodable {
    let choices: [Choice]
    
    struct Choice: Decodable {
        let message: Message
        
        struct Message: Decodable {
            let content: String
        }
    }
}

public class OpenAI: LLM {
    
    let temperature: Double
    let model: ModelID
    
    public init(temperature: Double = 0.0, model: ModelID = Model.GPT4.gpt4_1106_preview, callbacks: [BaseCallbackHandler] = [], cache: BaseCache? = nil) {
        self.temperature = temperature
        self.model = model
        super.init(callbacks: callbacks, cache: cache)
    }
    
public class OpenAI {
    let temperature: Double
    let model: String // Assuming model is a String. Adjust according to the actual type of `ModelID`
    
    public init(temperature: Double = 0.0, model: String) {
        self.temperature = temperature
        self.model = model
    }
    
    public func send(text: String, stops: [String] = []) async throws -> String {
        let env = Env.loadEnv()
        print("entering send function")
        guard let apiKey = env["OPENAI_API_KEY"], let baseUrl = env["OPENAI_API_BASE"] else {
            print("Please set openai api key.")
            return "Please set openai api key."
        }
        
        // Adjust the URL path according to the actual API endpoint
        let url = "https://\(baseUrl)/v1/chats" // Example endpoint, adjust as necessary
        print("url =",url)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)"
            // Add other headers as needed
        ]
        let parameters: Parameters = [
            "model": model,
            "messages": [["role": "user", "content": text]],
            "temperature": temperature,
            // Add other parameters as needed
        ]
        
do {
        let response = try await AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .serializingDecodable(Completion.self).value
        
        // Here, you process the response to extract the content you need
        let content = response.choices.first!.message.content ?? "No content available"
        
        // Assuming you're not using streaming for this response
        return LLMResult(llm_output: content)
    } catch {
        print("Request failed with error: \(error)")
        throw error
    }
}
}
}
