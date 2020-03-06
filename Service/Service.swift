import Foundation

struct Service {
    
    func getScreenLinks(completion: @escaping ([Screen]?) -> ()) {
        
        let task = session.dataTask(with: screensUrl, completionHandler:  { data, response, error in
            if response is HTTPURLResponse,
            (response as! HTTPURLResponse).statusCode == 200 {
                do {
                    let mappedData = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String:String]
                    let screens = mappedData?.values.compactMap {
                        Screen(url: $0)
                    }
                    completion(screens)
                }
            } else {
                print(error.debugDescription)
            }
        })
        task.resume()
        
    }
    
    private let session = URLSession.shared
    private let screensUrl = URL(string: "https://hw1ym521u8.execute-api.us-west-2.amazonaws.com/beta/list-stream")!
}
