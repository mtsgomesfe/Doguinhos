//
//  DogBreed.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import Foundation

// MARK: - Modelo principal para raças de cachorros
struct DogBreed: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let hypoallergenic: Bool
    let life: LifeSpan
    let maleWeight: WeightRange
    let femaleWeight: WeightRange
    
    // Propriedades adicionais para imagens (não vêm da API)
    var images: [String] = []
    var mainImage: String?
    var isFavorite: Bool = false
    
    // Propriedades computadas para facilitar o uso
    var lifeSpanText: String {
        "\(life.min) - \(life.max) anos"
    }
    
    var maleWeightText: String {
        "\(maleWeight.min) - \(maleWeight.max) kg"
    }
    
    var femaleWeightText: String {
        "\(femaleWeight.min) - \(femaleWeight.max) kg"
    }
    
    var hypoallergenicText: String {
        hypoallergenic ? "Sim" : "Não"
    }
    
    // CodingKeys para mapear os nomes da API
    enum CodingKeys: String, CodingKey {
        case id, name, description, hypoallergenic, life
        case maleWeight = "male_weight"
        case femaleWeight = "female_weight"
    }
}

// MARK: - Estruturas auxiliares
struct LifeSpan: Codable, Hashable {
    let min: Int
    let max: Int
}

struct WeightRange: Codable, Hashable {
    let min: Int
    let max: Int
}

// MARK: - Resposta da API para raças
struct BreedsAPIResponse: Codable {
    let data: [BreedData]
    let meta: Meta?
    let links: Links?
}

struct BreedData: Codable {
    let id: String
    let type: String
    let attributes: DogBreed
}

struct Meta: Codable {
    let pagination: Pagination?
}

struct Pagination: Codable {
    let current: Int
    let records: Int
}

struct Links: Codable {
    let `self`: String?
    let current: String?
    let next: String?
    let last: String?
}

// MARK: - Modelo para imagens do Dog CEO API
struct DogImage: Codable, Identifiable {
    let id = UUID()
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url
    }
}

struct DogImagesResponse: Codable {
    let message: [String]
    let status: String
}

struct DogBreedsListResponse: Codable {
    let message: [String: [String]]
    let status: String
}

