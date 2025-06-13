//
//  AsyncImage.swift
//  TestesDeAPI
//
//  Created by Matheus on 07/06/25.
//


import Foundation
import SwiftUI

// MARK: - MODELOS

struct DogBreedsListResponse: Decodable {
    let message: [String: [String]]
    let status: String
}

struct DogImageResponse: Decodable {
    let message: String
    let status: String
}

struct BreedInfo: Decodable {
    let name: String
    let temperament: String?
    let origin: String?
    let life_span: String?
    let bred_for: String?
}

// MARK: - VIEWMODEL

class DogBreedsViewModel: ObservableObject {
    @Published var breeds: [String] = []
    @Published var selectedBreed: String = "" {
        didSet {
            // 🔁 Salva a raça selecionada
            UserDefaults.standard.set(selectedBreed, forKey: "SelectedBreed")
        }
    }
    @Published var dogImageURL: String? {
        didSet {
            // 🔁 Salva a imagem atual
            if let url = dogImageURL {
                UserDefaults.standard.set(url, forKey: "DogImageURL")
            }
        }
    }
    @Published var breedInfo: BreedInfo?
    @Published var isLoadingBreedInfo = false
    @Published var translatedDescription: String?
    
    private let translator = TranslationService()
    private let dogAPIKey = "SUA_API_KEY"

    init() {
        fetchBreeds()
        restoreLastState()
    }

    private func restoreLastState() {
        // 🔁 Restaura dados salvos, se houver
        if let savedBreed = UserDefaults.standard.string(forKey: "SelectedBreed") {
            self.selectedBreed = savedBreed
            fetchBreedInfo(for: savedBreed)
            
            if let savedImage = UserDefaults.standard.string(forKey: "DogImageURL") {
                self.dogImageURL = savedImage
            } else {
                fetchDogImage(for: savedBreed)
            }
        }
    }

    func fetchBreeds() {
        guard let url = URL(string: "https://dog.ceo/api/breeds/list/all") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(DogBreedsListResponse.self, from: data)
                let allBreeds = decoded.message.flatMap { (key, subBreeds) -> [String] in
                    if subBreeds.isEmpty {
                        return [key]
                    } else {
                        return subBreeds.map { "\(key)/\($0)" }
                    }
                }

                DispatchQueue.main.async {
                    self.breeds = allBreeds.sorted()
                }

            } catch {
                print("Erro ao decodificar raças: \(error)")
            }
        }.resume()
    }

    func fetchDogImage(for breed: String) {
        let urlString = "https://dog.ceo/api/breed/\(breed)/images/random"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            do {
                let decoded = try JSONDecoder().decode(DogImageResponse.self, from: data)
                DispatchQueue.main.async {
                    self.dogImageURL = decoded.message
                    self.fetchBreedInfo(for: breed)
                }
            } catch {
                print("Erro ao buscar imagem: \(error)")
            }

        }.resume()
    }

    func fetchBreedInfo(for breed: String) {
        self.breedInfo = nil
        self.translatedDescription = nil
        self.isLoadingBreedInfo = true

        let searchTerm = breed.split(separator: "/")[0]
        guard let url = URL(string: "https://api.thedogapi.com/v1/breeds/search?q=\(searchTerm)") else { return }

        var request = URLRequest(url: url)
        request.addValue(dogAPIKey, forHTTPHeaderField: "x-api-key")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                self.isLoadingBreedInfo = false
            }

            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode([BreedInfo].self, from: data)
                if let info = result.first {
                    DispatchQueue.main.async {
                        self.breedInfo = info

                        if let textToTranslate = info.temperament {
                            self.translator.translate(text: textToTranslate) { translated in
                                DispatchQueue.main.async {
                                    self.translatedDescription = translated
                                }
                            }
                        }
                    }
                }
            } catch {
                print("Erro ao buscar descrição: \(error)")
            }
        }.resume()
    }

    func formatBreedName(_ breed: String) -> String {
        let parts = breed.split(separator: "/")
        if parts.count == 2 {
            return "\(parts[0].capitalized) (\(parts[1].capitalized))"
        } else {
            return breed.capitalized
        }
    }

    func fetchOnlyImage(for breed: String) {
        let endpoint = "https://dog.ceo/api/breed/\(breed)/images/random"
        guard let url = URL(string: endpoint) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(DogImageResponse.self, from: data),
                  error == nil else { return }

            DispatchQueue.main.async {
                self.dogImageURL = decoded.message
            }
        }.resume()
    }
}
