//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/3.
//

import AsyncHTTPClient
import Foundation
import SwiftyJSON
import NIOPosix

public struct WikipediaPage {
    public let title: String
    public let pageid: Int
    public let extract: String // Add this line
    
   public func content() async throws -> String {
        let eventLoopGroup = ThreadManager.thread
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        
        let baseURL = "http://en.wikipedia.org/w/api.php"
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "prop", value: "extracts"),
            URLQueryItem(name: "exintro", value: "true"),
            URLQueryItem(name: "explaintext", value: "true"),
            URLQueryItem(name: "pageids", value: "\(self.pageid)"),
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "format", value: "json"),
        ]
//        print(components.url!.absoluteString)
        var request = HTTPClientRequest(url: components.url!.absoluteString)
        request.method = .GET
        
        let response = try await httpClient.execute(request, timeout: .seconds(30))
        if response.status == .ok {
            let str = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
//            print(str)
            let json = try JSON(data: str.data(using: .utf8)!)
            return json["query"]["pages"]["\(self.pageid)"]["extract"].stringValue
            
        } else {
            // handle remote error
            print("http code is not 200.")
            return ""
        }
    }
}

extension WikipediaAPIWrapper {
    public func loadFullPageContent(pageId: Int) async throws -> String {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            try? httpClient.syncShutdown()
            try? eventLoopGroup.syncShutdownGracefully()
        }

        let baseURL = "https://en.wikipedia.org/w/api.php"
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "pageids", value: "\(pageId)"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "prop", value: "extracts"),
            // Removed exintro=true to get the full content
            URLQueryItem(name: "explaintext", value: "true"), // Get plain text content
            URLQueryItem(name: "exsectionformat", value: "wiki") // Use "wiki" for wikicode; alternatives: "plain", "raw"
        ]

         guard let url = components.url else {
            throw URLError(.badURL)
        }

        var request = HTTPClientRequest(url: url.absoluteString)
        request.method = .GET

        let response = try await httpClient.execute(request, timeout: .seconds(30))
        guard response.status == .ok else {
            throw URLError(.badServerResponse)
        }

        // Assuming response.body.collect() is available and correct
        // Convert HTTPClientResponse.Body to Data
        let bodyData = Data(buffer: try await response.body.collect(upTo: 1_024 * 1024))
        let json = try JSON(data: bodyData)
        guard let pageContent = json["query"]["pages"]["\(pageId)"]["extract"].string else {
            throw NSError(domain: "WikipediaAPIWrapperError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse page content"])
        }

        return pageContent
    }
}
