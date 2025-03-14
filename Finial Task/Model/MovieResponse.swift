//
//  Movie.swift
//  FinalProjectVer01
//
//  Created by Walid Nadim on 12/2/24.
//

import Foundation

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let id: Int?
    let title: String?
    let name: String?
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let firstAirDate: String?
    let voteAverage: Double
    let mediaType: String?
    let originalLanguage: String?
    let runtime: Int?
    let popularity: Double?
    let genreIds: [Int]?
    let adult: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case mediaType = "media_type"
        case originalLanguage = "original_language"
        case runtime
        case popularity
        case genreIds = "genre_ids"
        case adult
    }
    
    var displayTitle: String? {
        return title ?? name ?? "Unknown"
    }
    
    var displayDate: String? {
        return releaseDate ?? firstAirDate ?? "TBA"
    }
    
    var displayMediaType: String? {
        return mediaType ?? "movie"
    }
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(backdropPath)")
    }
    
    var displayDuration: String? {
        guard let runtime = runtime else { return "N/A" }
        let hours = runtime / 60
        let minutes = runtime % 60
        return hours > 0 ? "\(hours)hour \(minutes)minutes" : "\(minutes)m"
    }
    
    var displayPopularity: String? {
        return String(format: "%.1f", popularity ?? "")
    }
    
    var genreNames: [String]? {
        return genreIds?.compactMap { id in
            switch id {
            case 28: return "Action"
            case 12: return "Adventure"
            case 16: return "Animation"
            case 35: return "Comedy"
            case 80: return "Crime"
            case 99: return "Documentary"
            case 18: return "Drama"
            case 10751: return "Family"
            case 14: return "Fantasy"
            case 36: return "History"
            case 27: return "Horror"
            case 10402: return "Music"
            case 9648: return "Mystery"
            case 10749: return "Romance"
            case 878: return "Science Fiction"
            case 10770: return "TV Movie"
            case 53: return "Thriller"
            case 10752: return "War"
            case 37: return "Western"
            default: return nil
            }
        } ?? []
    }
    
    // Add language mapping
    private static let languageMap: [String: String]? = [
        "en": "English",
        "es": "Spanish",
        "fr": "French",
        "de": "German",
        "it": "Italian",
        "ja": "Japanese",
        "ko": "Korean",
        "zh": "Chinese",
        "hi": "Hindi",
        "ar": "Arabic",
        "ru": "Russian",
        "pt": "Portuguese",
        "nl": "Dutch",
        "tr": "Turkish",
        "pl": "Polish",
        "vi": "Vietnamese",
        "th": "Thai",
        "sv": "Swedish",
        "da": "Danish",
        "fi": "Finnish",
        "no": "Norwegian",
        "id": "Indonesian",
        "fa": "Persian",
        "el": "Greek",
        "he": "Hebrew",
        "cs": "Czech",
        "hu": "Hungarian",
        "ro": "Romanian",
        "bn": "Bengali",
        "uk": "Ukrainian"
    ]
    
    var displayLanguage: String {
      return (Movie.languageMap?[originalLanguage ?? ""] ?? "Unknown Language").uppercased()
    }
    
    var displayCensorship: String {
        return adult ?? true ? "18+" : "13+"
    }
}
