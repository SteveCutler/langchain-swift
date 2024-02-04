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
    
    public override func _send(text: String, stops: [String] = []) async throws -> LLMResult {
        let env = Env.loadEnv()
        
        if let apiKey = env["OPENAI_API_KEY"] {
            let baseUrl = env["OPENAI_API_BASE"] ?? "api.openai.com"
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(apiKey)",
                "Content-Type": "application/json"
            ]
            
            let parameters: [String: Any] = [
                "model": model,
                "messages": [["content": text]],
                "temperature": temperature,
                "stops": stops
            ]
            
            let url = "https://\(baseUrl)/v1/chats"
            
            do {
                let response = try await AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).serializingDecodable(OpenAIKit.ChatCompletion.self).value
                return LLMResult(llm_output: response.choices.first!.message.content)
            } catch {
                print("Request failed with error: \(error)")
                throw error
            }
        } else {
            print("Please set openai api key.")
            return LLMResult(llm_output: "Please set openai api key.")
        }
    }
}

