//
//  MovieResults.swift
//  InterviewMovieProject
//
//  Created by Gizem Boskan on 11.07.2021.
//

import Foundation

// MARK: - MovieResults
struct MovieResults: Codable {
    let page: Int
    let results: [Movie]
    let totalPages, totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

