//
//  Service.swift
//  Swann Video Streaming
//
//  Created by Raj Patel on 22/02/20.
//  Copyright © 2020 Raj Patel. All rights reserved.
//

import Foundation

struct Service {
    
    let session = URLSession.shared
    private let screensUrl = URL(string: "https://hw1ym521u8.execute-api.us-west-2.amazonaws.com/beta/list-stream")!
    
    func getScreenLinks(completion: @escaping (Screens?) -> ()) {
        
        let task = session.dataTask(with: screensUrl, completionHandler:  { data, response, error in
            if response is HTTPURLResponse,
            (response as! HTTPURLResponse).statusCode == 200 {
                do {
                    let jsonDecoder = JSONDecoder()
                    let screens = try jsonDecoder.decode(Screens.self, from: data!)
                    completion(screens)
                }  catch let parseError as NSError {
                    print("JSON Error \(parseError.localizedDescription)")
                }
            } else {
                print(error.debugDescription)
            }
        })
        task.resume()
    }
}
