//
//  ImageService.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import Foundation
import SwiftUI

// MARK: - Serviço para cache e gerenciamento de imagens
class ImageService: ObservableObject {
    static let shared = ImageService()
    
    private let cache = NSCache<NSString, NSData>()
    private let session = URLSession.shared
    
    private init() {
        // Configurar cache
        cache.countLimit = 100 // Máximo 100 imagens em cache
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB máximo
    }
    
    // MARK: - Carregar imagem com cache
    func loadImage(from urlString: String) async -> Data? {
        let cacheKey = NSString(string: urlString)
        
        // Verificar cache primeiro
        if let cachedData = cache.object(forKey: cacheKey) {
            return cachedData as Data
        }
        
        // Baixar da rede
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }
            
            // Armazenar no cache
            cache.setObject(NSData(data: data), forKey: cacheKey)
            
            return data
        } catch {
            return nil
        }
    }
    
    // MARK: - Limpar cache
    func clearCache() {
        cache.removeAllObjects()
    }
    
    // MARK: - Pré-carregar imagens
    func preloadImages(_ urls: [String]) {
        Task {
            for urlString in urls {
                await loadImage(from: urlString)
            }
        }
    }
}

// MARK: - AsyncImage personalizada com cache
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var imageData: Data?
    @State private var isLoading = false
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let imageData = imageData,
               let uiImage = UIImage(data: imageData) {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        isLoading = true
        
        Task {
            let data = await ImageService.shared.loadImage(from: url.absoluteString)
            
            await MainActor.run {
                self.imageData = data
                self.isLoading = false
            }
        }
    }
}

// MARK: - Extensão para facilitar o uso
extension CachedAsyncImage where Content == Image, Placeholder == ProgressView<EmptyView, EmptyView> {
    init(url: URL?) {
        self.init(
            url: url,
            content: { $0 },
            placeholder: { ProgressView() }
        )
    }
}

