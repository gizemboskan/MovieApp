//
//  Endpoints.swift
//  InterviewMovieProject
//
//  Created by Gizem Boskan on 11.07.2021.
//

import Foundation

enum Endpoints {
    static let base = "https://api.themoviedb.org/3"
   
    static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
    
    case getPopularMovies(Int)
    case getMovieDetails(Int)
    case search(String)
    case posterImage(String)
    
    var url: URL {
        switch self {
        case .getPopularMovies(let page):
            return URL(string: Endpoints.base + "/movie/popular" + Endpoints.apiKeyParam + "&page=\(page)")!
        case .getMovieDetails(let id): return URL(string: Endpoints.base + "/movie/\(id)" + Endpoints.apiKeyParam)!
        case .search(let query):
            return  URL(string: Endpoints.base + "/search/movie" + Endpoints.apiKeyParam + "&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))")!
        case .posterImage(let posterPath):
            return URL(string: "https://image.tmdb.org/t/p/w200/" + posterPath)!
        }
    }
}
