//
//  BreedDetailViewModel.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import Foundation
import Combine

// MARK: - ViewModel para detalhes da raça
@MainActor
class BreedDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var breed: DogBreed
    @Published var images: [String] = []
    @Published var isLoadingImages: Bool = false
    @Published var errorMessage: String?
    @Published var isFavorite: Bool = false
    
    // MARK: - Private Properties
    private let apiService: APIServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(breed: DogBreed, apiService: APIServiceProtocol = APIService.shared) {
        self.breed = breed
        self.apiService = apiService
        self.isFavorite = UserDefaults.standard.getFavoriteBreeds().contains(breed.id)
    }
    
    // MARK: - Public Methods
    
    /// Carrega imagens da raça com cache
    func loadImages() async {
        isLoadingImages = true
        errorMessage = nil
        
        do {
            let fetchedImages = try await apiService.fetchBreedImagesWithCache(for: breed.name, breedId: breed.id)
            images = fetchedImages
        } catch {
            errorMessage = "Erro ao carregar imagens: \(error.localizedDescription)"
        }
        
        isLoadingImages = false
    }
    
    /// Recarrega as imagens
    func refreshImages() async {
        await loadImages()
    }
    
    /// Alterna o status de favorito
    func toggleFavorite() {
        isFavorite.toggle()
        
        var favoriteBreeds = UserDefaults.standard.getFavoriteBreeds()
        
        if isFavorite {
            favoriteBreeds.insert(breed.id)
        } else {
            favoriteBreeds.remove(breed.id)
        }
        
        UserDefaults.standard.setFavoriteBreeds(favoriteBreeds)
    }
    
    // MARK: - Computed Properties
    
    var hasImages: Bool {
        !images.isEmpty
    }
    
    var shouldShowImagesError: Bool {
        !isLoadingImages && images.isEmpty && errorMessage != nil
    }
    
    var shouldShowEmptyImages: Bool {
        !isLoadingImages && images.isEmpty && errorMessage == nil
    }
    
    // MARK: - Curiosidades e informações adicionais
    var breedFacts: [BreedFact] {
        var facts: [BreedFact] = []
        
        // Expectativa de vida
        facts.append(BreedFact(
            icon: "clock",
            title: "Expectativa de Vida",
            value: breed.lifeSpanText,
            description: "Tempo médio de vida da raça"
        ))
        
        // Peso dos machos
        facts.append(BreedFact(
            icon: "figure.walk",
            title: "Peso dos Machos",
            value: breed.maleWeightText,
            description: "Faixa de peso típica para machos"
        ))
        
        // Peso das fêmeas
        facts.append(BreedFact(
            icon: "figure.walk",
            title: "Peso das Fêmeas",
            value: breed.femaleWeightText,
            description: "Faixa de peso típica para fêmeas"
        ))
        
        // Hipoalergênico
        facts.append(BreedFact(
            icon: breed.hypoallergenic ? "checkmark.circle" : "xmark.circle",
            title: "Hipoalergênico",
            value: breed.hypoallergenicText,
            description: breed.hypoallergenic ? "Produz menos alérgenos" : "Pode causar alergias"
        ))
        
        return facts
    }
}

// MARK: - Estrutura para fatos sobre a raça
struct BreedFact {
    let icon: String
    let title: String
    let value: String
    let description: String
}

