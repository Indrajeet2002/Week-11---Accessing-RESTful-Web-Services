//
//  ImgFlipApi.swift
//  Week 11 - Accessing RESTful Web Services
//
//  Created by Indrajeet Patwardhan on 11/9/23.
//

import Foundation

enum EndPoint: String {
    case getMemes = "get_memes"
}

class ImgFlipApi
{
    private static let baseURLString = "https://api.imgflip.com/"
    
    static var getMemesURL: URL{
        return self.imgFlipURL(
            endPoint: EndPoint.getMemes,
            parameters: nil
        )
    }
    
    private static func imgFlipURL(
        endPoint: EndPoint,
        parameters: [String:String]?
    ) -> URL
    {
        let endpoint = self.baseURLString + endPoint.rawValue
        
        var components = URLComponents(string: baseURLString)!
        
        var queryItems = [URLQueryItem]()
        
        let baseQueryParameters = [
            "dummy": "value"
        ]
        for (key, value) in baseQueryParameters{
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParameters = parameters {
            for (key, value) in additionalParameters{
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        
        components.queryItems = queryItems
        
        return components.url!
    }
    
    static func memeTemplates(fromJSON data: Data)->
    Result<[ImgFlipMemeTemplate], Error>
    {
        do{
            let decoder = JSONDecoder()

            let getMemesResponse = try decoder.decode(
                ImgFlipGetMemesResponse.self,
                from: data
            )
            let memeTemplates = getMemesResponse.data.memeTemplates.filter{
                $0.url != nil
            }

            return .success(memeTemplates)

        }
        catch{
            return .failure(error)
        }
    }
}

struct ImgFlipGetMemesResponse: Codable{
    let success: Bool = false
    let data: ImgFlipGetMemesResponseData

    enum CodingKeys:String, CodingKey{
        case success = "success"
        case data = "data"
    }
}

struct ImgFlipGetMemesResponseData: Codable{
    let memeTemplates: [ImgFlipMemeTemplate]

    enum CodingKeys:String, CodingKey{
        case memeTemplates = "memes"
    }
}

struct ImgFlipMemeTemplate: Codable{
    let templateID: String
    let name: String
    let url: URL?

    enum CodingKeys: String, CodingKey{
        case templateID = "id"
        case name
        case url
    }
}
