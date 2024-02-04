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

   public func loadIntroAndSections(pageId: Int) async throws -> (intro: String, sections: [String]) {
    let introURL = "https://en.wikipedia.org/w/api.php"
    let sectionsURL = introURL // Same base URL, different parameters
    
    // Parameters for fetching the introductory content
    let introParameters: Parameters = [
        "action": "query",
        "prop": "extracts",
        "exintro": "",
        "explaintext": "",
        "pageids": pageId,
        "format": "json",
    ]
    
    // Parameters for fetching the section titles
    let sectionsParameters: Parameters = [
        "action": "parse",
        "pageid": pageId,
        "prop": "sections",
        "format": "json",
    ]
    
    // Fetch introductory content
    let introResponse = try await AF.request(introURL, method: .get, parameters: introParameters).serializingData().value
    let introJson = try JSON(data: introResponse)
    let introText = introJson["query"]["pages"]["\(pageId)"]["extract"].stringValue
    
    // Fetch section titles
    let sectionsResponse = try await AF.request(sectionsURL, method: .get, parameters: sectionsParameters).serializingData().value
    let sectionsJson = try JSON(data: sectionsResponse)
    let sectionTitles = sectionsJson["parse"]["sections"].arrayValue.enumerated().map { index, section in
        "\(index + 1) \(section["line"].stringValue)" // Numbering starts at 1
    }
    
    return (introText, sectionTitles)
}
   
   public func loadSectionContent(pageId: Int, sectionIndex: Int) async throws -> String {
        let baseURL = "https://en.wikipedia.org/w/api.php"
        let parameters: Parameters = [
            "action": "parse",
            "pageid": pageId,
            "section": sectionIndex,
            "prop": "text",
            "format": "json",
            "formatversion": 2 // Use the latest format version for cleaner output
        ]
        
     //   let baseURL = "https://en.wikipedia.org/api/rest_v1/page"
   // let sectionURL = "\(baseURL)/segment/\(pageId)/\(sectionIndex)"

    do {
        // Fetch the section content using Alamofire
        let response = try await AF.request(baseURL, method: .get, parameters: parameters).serializingData().value
        let json = try JSON(data: response)
        let sectionContent = json["parse"]["text"].stringValue // Adjust based on actual JSON structure
        let cleanedSectionContent = sectionContent.strippingHTML()

        return cleanedSectionContent

    }
    }
}
}

extension String {
    func strippingHTML() -> String {
        let range = NSRange(location: 0, length: self.utf16.count)
        let regex = try! NSRegularExpression(pattern: "<.*?>", options: [])
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "")
    }
}

  



