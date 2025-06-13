//
//  BreedsListViewModel.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import Foundation
import Combine

// MARK: - ViewModel para a lista de raças
@MainActor
class BreedsListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var breeds: [DogBreed] = []
    @Published var filteredBreeds: [DogBreed] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var favoriteBreeds: Set<String> = []
    
    // MARK: - Private Properties
    private let apiService: APIServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
        setupSearchBinding()
        loadFavoriteBreeds()
    }
    
    // MARK: - Public Methods
    
    /// Carrega todas as raças da API com cache
    func loadBreeds() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedBreeds = try await apiService.fetchBreedsWithCache()
            breeds = fetchedBreeds.sortedAlphabetically()
            filterBreeds()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Recarrega as raças
    func refreshBreeds() async {
        await loadBreeds()
    }
    
    /// Alterna o status de favorito de uma raça
    func toggleFavorite(for breed: DogBreed) {
        if favoriteBreeds.contains(breed.id) {
            favoriteBreeds.remove(breed.id)
        } else {
            favoriteBreeds.insert(breed.id)
        }
        
        saveFavoriteBreeds()
        updateBreedsFavoriteStatus()
    }
    
    /// Verifica se uma raça é favorita
    func isFavorite(_ breed: DogBreed) -> Bool {
        return favoriteBreeds.contains(breed.id)
    }
    
    // MARK: - Private Methods
    
    /// Configura o binding para busca em tempo real
    private func setupSearchBinding() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterBreeds()
            }
            .store(in: &cancellables)
    }
    
    /// Filtra as raças baseado no texto de busca
    private func filterBreeds() {
        if searchText.isEmpty {
            filteredBreeds = breeds
        } else {
            filteredBreeds = breeds.filtered(by: searchText)
        }
    }
    
    /// Carrega raças favoritas do UserDefaults
    private func loadFavoriteBreeds() {
        favoriteBreeds = UserDefaults.standard.getFavoriteBreeds()
    }
    
    /// Salva raças favoritas no UserDefaults
    private func saveFavoriteBreeds() {
        UserDefaults.standard.setFavoriteBreeds(favoriteBreeds)
    }
    
    /// Atualiza o status de favorito nas raças
    private func updateBreedsFavoriteStatus() {
        for i in breeds.indices {
            breeds[i].isFavorite = favoriteBreeds.contains(breeds[i].id)
        }
        filterBreeds()
    }
}

// MARK: - Estados da View
extension BreedsListViewModel {
    var hasBreeds: Bool {
        !breeds.isEmpty
    }
    
    var hasFilteredResults: Bool {
        !filteredBreeds.isEmpty
    }
    
    var isSearching: Bool {
        !searchText.isEmpty
    }
    
    var shouldShowEmptyState: Bool {
        !isLoading && hasBreeds && !hasFilteredResults && isSearching
    }
    
    var shouldShowErrorState: Bool {
        !isLoading && errorMessage != nil
    }
}

