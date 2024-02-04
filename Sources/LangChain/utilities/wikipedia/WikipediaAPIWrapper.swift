//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/2.
//
import AsyncHTTPClient
import Foundation
import SwiftyJSON
import NIOPosix
import Alamofire

public struct WikipediaAPIWrapper {
   public init() {}
  public func search(query: String) async throws -> [WikipediaPage] {
        let baseURL = "https://en.wikipedia.org/w/api.php"
        let parameters: Parameters = [
            "action": "query",
            "format": "json",
            "list": "search",
            "srsearch": query,
            "utf8": 1,
            "srlimit": 5, // Adjust the limit as needed
            "prop": "extracts", // Request extracts
            "exintro": "", // Get introductory content
            "explaintext": "", // Return extracts in plain text
            "exsentences": 3 // Limit the extract to first few sentences
        ]

        do {
            let response = try await AF.request(baseURL, method: .get, parameters: parameters).serializingData().value
            let json = try JSON(data: response)
            var wikis: [WikipediaPage] = []
            let searchResults = json["query"]["search"].arrayValue

            for wiki in searchResults {
                wikis.append(WikipediaPage(
                    title: wiki["title"].stringValue,
                    pageid: wiki["pageid"].intValue,
                    extract: wiki["snippet"].stringValue // Use "snippet" or adjust based on actual JSON key for extracts
                ))
            }
            return wikis
        } catch {
            print("Request failed with error: \(error)")
            throw error
        }
  }
    
    
    public func load(query: String) async throws -> [Document] {
        let pages = try await self.search(query: query)
        var docs: [Document] = []
        for page in pages {
            let content = try await page.content()
            docs.append(Document(page_content: content, metadata: [:]))
        }
        return docs
    }
  
}
  



