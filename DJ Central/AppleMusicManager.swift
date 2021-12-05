//
//  AppleMusicManager.swift
//  DJ Central
//
//  Created by William Thompson on 6/17/17.
//  Copyright © 2017 J. W. Enterprises, LLC. All rights reserved.
//  See LICENSE.txt
//

import Foundation
import UIKit
import StoreKit

class AppleMusicManager {
    typealias CatalogSearchCompletionHandler = (_ mediaItems: [[MediaItem]], _ error: Error?) -> Void
    typealias GetUserStoreFrontCompletionHandler = (_ storeFront: String?, _ error: Error?) -> Void
    lazy var urlSession: URLSession = {
        let urlSessionConfiguration = URLSessionConfiguration.default
        return URLSession(configuration: urlSessionConfiguration)
    }()
    var storeFrontID: String?
    var developerAuthenticationToken : String?
    let url = URL(string: "https://www.jwenterprises.co/2017/06/16/token/")
    
    func readContentsAtFilePath(_ url: URL) -> String {
        let contents = try! String(contentsOf: url, encoding: String.Encoding.utf8)
        return contents
    }
    
    func fetchDeveloperToken() -> String? {
        //var developerAuthenticationtoken : String?
        if developerAuthenticationToken == nil {
            
        
        
        let json = ["user":"larry"]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let url = URL(string: "http://api.theblueduckpond.com/app")!
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf -8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
                if error != nil {
                    print("Error -> \(String(describing: error))")
                    return
                }
                //do {
                    
                    let stringResults = String(data: data!, encoding: .utf8)
                    print(stringResults!)
                self.developerAuthenticationToken = stringResults!
                    //---> use to turn returned info back into JSON formats let results = try JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed)
                    print("Result -> \(stringResults!)")
               // }
               // catch {
               // print("Error -> \(error)")
               // }
                
            }
            task.resume()
        }
            catch{
                print(error)
                
            }
            return developerAuthenticationToken
        }
        return developerAuthenticationToken
    }
    
    func performAppleMusicCatalogSearch(with term: String, countryCode: String, completion: @escaping CatalogSearchCompletionHandler) {
        guard let developerToken = fetchDeveloperToken() else {
            print("oops")
            return
        }
        let urlRequest = AppleMusicRequest.createSearchRequest(term, countryCode: countryCode, developerToken: developerToken)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion([], error)
                return
            }
            do {
                let mediaItem = try self.processMediaItemSections(data!)
                completion(mediaItem, nil)
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func performAppleMusicStoreFrontLookup(_ regionCode: String, completion: @escaping GetUserStoreFrontCompletionHandler) {
        guard let developerToken = fetchDeveloperToken() else {
            print("oops")
            return
        }
        let urlRequest = AppleMusicRequest.createStoreFrontRequest(regionCode, developerToken: developerToken)
        let task = urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion(nil, error)
                return
            }
            do {
                let identifier = try self?.processStoreFront(data!)
                completion(identifier, nil)
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func processMediaItemSections(_ json: Data) throws -> [[MediaItem]] {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let results = jsonDictionary[ResponseRootJSONKeys.results] as? [String: [String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.results)
        }
        var mediaItems = [[MediaItem]]()
        if let songsDictionary = results[ResourceTypeJSONKeys.songs] {
            if let dataArray = songsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let songMediaItems = try processMediaItems(from: dataArray)
                mediaItems.append(songMediaItems)
            }
        }
        if let albumsDictionary = results[ResourceTypeJSONKeys.albums] {
            if let dataArray = albumsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let albumMediaItems = try processMediaItems(from: dataArray)
                mediaItems.append(albumMediaItems)
            }
        }
        return mediaItems
    }
    
    func processMediaItems(from json: [[String: Any]]) throws -> [MediaItem] {
        let songMediaItems = try json.map { try MediaItem(json: $0) }
        return songMediaItems
    }
    
    func processStoreFront(_ json: Data) throws -> String {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let data = jsonDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.data)
        }
        guard let identifier = data.first?[ResourceJSONKeys.identifier] as? String else {
            throw SerializationError.missing(ResourceJSONKeys.identifier)
        }
        return identifier
    }
}
