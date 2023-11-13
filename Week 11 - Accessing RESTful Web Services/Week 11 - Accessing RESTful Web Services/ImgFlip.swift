//
//  ImgFlip.swift
//  Week 11 - Accessing RESTful Web Services
//
//  Created by Indrajeet Patwardhan on 11/9/23.
//

import Foundation
import UIKit

enum MemeError: Error{
    case getMemesError
    case missingImageURL
    case imageCreationError
}

class ImgFlip{
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    private func processGetMemesResult(data: Data?, error: Error?) ->
    Result<[ImgFlipMemeTemplate], Error>
    {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return ImgFlipApi.memeTemplates(fromJSON: jsonData)
    }
    
    private func downloadImage(
        url: URL,
        completion: @escaping (Result<UIImage, Error>)-> Void
    ){
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request){
            (data, response, error) in
            
            let result = self.processGetMemesResult(data: data, error: error)
            
            OperationQueue.main.addOperation{
                completion(result)
            }
        }
        task.resume()
    }
    
    func getMemes(
        completion: @escaping (Result<[ImgFlipMemeTemplate], Error>) -> Void
    ){
        let url = ImgFlipApi.getMemesURL
        let request = URLRequest(url: url)
        
        print("getMemes() - Using URL: \(url)")
        
        let task = self.session.dataTask(with: request){
            (data, response, error) in
            
//            if let jsonData = data{
//                if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8){
//                    print(jsonString)
//                }
//            }
//            else if let requestError = error{
//                print("Error fetching memes: \(requestError)")
//            }
//            else{
//                print("Unexpected error with the request")
//            }
            let result = self.processGetMemesResult(data: data, error: error)
            OperationQueue.main.addOperation{
                completion(result)
            }
        }
        task.resume()
    }
    
    func downloadMemeTemplateImage(
        for template: ImgFlipMemeTemplate,
        completion: @escaping (Result<UIImage, Error>)-> Void
    )
    {
        if let imageURL = template.url{
            self.downloadImage(url: imageURL, completion: completion)
        }
        else{
            completion(.failure(MemeError.missingImageURL))
        }
    }
    
    func processImageDownloadResult(data: Data?, error: Error?)->
    Result<UIImage, Error>{
        guard
            let imageData = data,
            let image = UIImage(data: imageData)
        else{
            if data == nil{
                return .failure(error!)
            }
            else{
                return .failure(MemeError.imageCreationError)
            }
        }
        
        return .success(image)
    }
}
