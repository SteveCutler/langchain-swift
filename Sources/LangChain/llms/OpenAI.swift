//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/6/10.
//


import Foundation
import Alamofire
import OpenAIKit

public class OpenAI: LLM {
    
    let temperature: Double
    let model: ModelID
    
    public init(temperature: Double = 0.0, model: ModelID = Model.GPT4.gpt4_1106_preview, callbacks: [BaseCallbackHandler] = [], cache: BaseCache? = nil) {
        self.temperature = temperature
        self.model = model
        super.init(callbacks: callbacks, cache: cache)
    }
    
 public func send(text: String, stops: [String] = []) async throws -> LLMResult {
        let env = Env.loadEnv()
        
        guard let apiKey = env["OPENAI_API_KEY"], let baseUrl = env["OPENAI_API_BASE"] ?? "api.openai.com" else {
            print("Please set openai api key.")
            return LLMResult(llm_output: "Please set openai api key.")
        }
        
        let url = "https://\(baseUrl)/v1/..." // Adjust the URL path according to the actual API endpoint
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)"
            // Add other headers as needed
        ]
        let parameters: Parameters = [
            "model": model,
            "prompt": text,
            "temperature": temperature,
            // Add other parameters as needed
        ]
        
        do {
            let response: ChatResponse = try await AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .serializingDecodable(ChatResponse.self).value
            // Use the response
            return LLMResult(llm_output: response.someProperty) // Adjust according to how you want to use the response
        } catch {
            print("Request failed with error: \(error)")
            throw error
    }
}



