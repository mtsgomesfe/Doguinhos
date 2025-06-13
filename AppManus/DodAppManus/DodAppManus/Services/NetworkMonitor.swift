//
//  NetworkMonitor.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import Foundation
import Network
import Combine

// MARK: - Monitor de conectividade de rede
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    
    @Published var isConnected = false
    @Published var connectionType: ConnectionType = .unknown
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.updateConnectionType(path)
            }
        }
        monitor.start(queue: queue)
    }
    
    private func updateConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
    
    deinit {
        monitor.cancel()
    }
}

// MARK: - Serviço de persistência local
class PersistenceService {
    static let shared = PersistenceService()
    
    private let userDefaults = UserDefaults.standard
    private let breedsKey = "cached_breeds"
    private let lastUpdateKey = "last_breeds_update"
    
    private init() {}
    
    // MARK: - Cache de raças
    func saveBreeds(_ breeds: [DogBreed]) {
        do {
            let data = try JSONEncoder().encode(breeds)
            userDefaults.set(data, forKey: breedsKey)
            userDefaults.set(Date(), forKey: lastUpdateKey)
        } catch {
            print("Erro ao salvar raças: \(error)")
        }
    }
    
    func loadBreeds() -> [DogBreed]? {
        guard let data = userDefaults.data(forKey: breedsKey) else { return nil }
        
        do {
            return try JSONDecoder().decode([DogBreed].self, from: data)
        } catch {
            print("Erro ao carregar raças: \(error)")
            return nil
        }
    }
    
    func getLastUpdateDate() -> Date? {
        return userDefaults.object(forKey: lastUpdateKey) as? Date
    }
    
    func shouldUpdateCache() -> Bool {
        guard let lastUpdate = getLastUpdateDate() else { return true }
        
        // Atualizar cache se passou mais de 1 hora
        let oneHourAgo = Date().addingTimeInterval(-3600)
        return lastUpdate < oneHourAgo
    }
    
    // MARK: - Cache de imagens de raças
    func saveBreedImages(_ images: [String], for breedId: String) {
        userDefaults.set(images, forKey: "images_\(breedId)")
    }
    
    func loadBreedImages(for breedId: String) -> [String]? {
        return userDefaults.object(forKey: "images_\(breedId)") as? [String]
    }
}

// MARK: - APIService atualizado com cache e conectividade
extension APIService {
    
    // MARK: - Buscar raças com cache
    func fetchBreedsWithCache() async throws -> [DogBreed] {
        let persistence = PersistenceService.shared
        let networkMonitor = NetworkMonitor.shared
        
        // Se não há conexão, tentar carregar do cache
        if !networkMonitor.isConnected {
            if let cachedBreeds = persistence.loadBreeds() {
                return cachedBreeds
            } else {
                throw APIError.networkError(NSError(
                    domain: "NetworkError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Sem conexão com a internet e nenhum dado em cache"]
                ))
            }
        }
        
        // Se há conexão, verificar se precisa atualizar
        if !persistence.shouldUpdateCache(),
           let cachedBreeds = persistence.loadBreeds() {
            return cachedBreeds
        }
        
        // Buscar dados atualizados da API
        do {
            let breeds = try await fetchBreeds()
            persistence.saveBreeds(breeds)
            return breeds
        } catch {
            // Se falhar, tentar carregar do cache como fallback
            if let cachedBreeds = persistence.loadBreeds() {
                return cachedBreeds
            } else {
                throw error
            }
        }
    }
    
    // MARK: - Buscar imagens com cache
    func fetchBreedImagesWithCache(for breedName: String, breedId: String) async throws -> [String] {
        let persistence = PersistenceService.shared
        let networkMonitor = NetworkMonitor.shared
        
        // Se não há conexão, tentar carregar do cache
        if !networkMonitor.isConnected {
            if let cachedImages = persistence.loadBreedImages(for: breedId) {
                return cachedImages
            } else {
                throw APIError.networkError(NSError(
                    domain: "NetworkError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Sem conexão com a internet"]
                ))
            }
        }
        
        // Buscar imagens da API
        do {
            let images = try await fetchBreedImages(for: breedName)
            persistence.saveBreedImages(images, for: breedId)
            return images
        } catch {
            // Se falhar, tentar carregar do cache como fallback
            if let cachedImages = persistence.loadBreedImages(for: breedId) {
                return cachedImages
            } else {
                throw error
            }
        }
    }
}

