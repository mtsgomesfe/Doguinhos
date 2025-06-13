//
//  APIService.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import Foundation
import Combine

// MARK: - Protocolo para serviços de API
protocol APIServiceProtocol {
    func fetchBreeds() async throws -> [DogBreed]
    func fetchBreedImages(for breedName: String) async throws -> [String]
}

// MARK: - Serviço principal de API
class APIService: APIServiceProtocol, ObservableObject {
    static let shared = APIService()
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    // URLs das APIs
    private let dogAPIBaseURL = "https://dogapi.dog/api/v2"
    private let dogCEOBaseURL = "https://dog.ceo/api"
    
    private init() {}
    
    // MARK: - Buscar todas as raças
    func fetchBreeds() async throws -> [DogBreed] {
        let url = URL(string: "\(dogAPIBaseURL)/breeds")!
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            let apiResponse = try decoder.decode(BreedsAPIResponse.self, from: data)
            var breeds: [DogBreed] = []
            
            for breedData in apiResponse.data {
                var breed = breedData.attributes
                breed.id = breedData.id
                breeds.append(breed)
            }
            
            return breeds
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Buscar imagens de uma raça específica
    func fetchBreedImages(for breedName: String) async throws -> [String] {
        // Converter nome da raça para formato aceito pela API (lowercase, sem espaços)
        let formattedBreedName = breedName.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
        
        let url = URL(string: "\(dogCEOBaseURL)/breed/\(formattedBreedName)/images")!
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        do {
            let imagesResponse = try decoder.decode(DogImagesResponse.self, from: data)
            return Array(imagesResponse.message.prefix(10)) // Limitar a 10 imagens
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Buscar uma imagem aleatória de uma raça
    func fetchRandomBreedImage(for breedName: String) async throws -> String? {
        let formattedBreedName = breedName.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
        
        let url = URL(string: "\(dogCEOBaseURL)/breed/\(formattedBreedName)/images/random")!
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            return nil
        }
        
        do {
            let imageResponse = try decoder.decode(DogImageResponse.self, from: data)
            return imageResponse.message
        } catch {
            return nil
        }
    }
}

// MARK: - Estrutura para resposta de imagem única
struct DogImageResponse: Codable {
    let message: String
    let status: String
}

// MARK: - Erros da API
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Resposta inválida do servidor"
        case .decodingError(let error):
            return "Erro ao decodificar dados: \(error.localizedDescription)"
        case .networkError(let error):
            return "Erro de rede: \(error.localizedDescription)"
        }
    }
}

