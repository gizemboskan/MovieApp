//
//  TMDBClient.swift
//  InterviewMovieProject
//
//  Created by Gizem Boskan on 11.07.2021.
//

import Foundation

class TMDBClient {
    
    static let apiKey = "bee938688bbb964dbd3b2c99cb63a365"
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        DispatchQueue.main.async(qos: .utility) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                
                if error != nil {
                    completion(nil, error)
                    return
                }
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                
                print(String(decoding: data, as: UTF8.self))
                
                let decoder = JSONDecoder()
                
                do {
                    let responseObject = try decoder.decode(ResponseType.self, from: data)
                    completion(responseObject, nil)
                } catch {
                    
                    completion(nil, error)
                    
                }
            }
            task.resume()
        }
        
    }
    class func getPopularMovies(page: Int, completion: @escaping ([Movie], Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getPopularMovies(page).url, responseType: MovieResults.self) { response, error in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    class func getMovieDetails (id: Int, completion: @escaping (MovieDetail?, Error?) -> Void) {
        taskForGETRequest(url: Endpoints.getMovieDetails(id).url, responseType: MovieDetail.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func downloadPosterImage(path: String, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.posterImage(path).url) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        task.resume()
    }
}

