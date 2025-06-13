//
//  Extensions.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import Foundation
import SwiftUI

// MARK: - Extensões para String
extension String {
    /// Capitaliza a primeira letra de cada palavra
    var capitalizedWords: String {
        return self.split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    /// Remove caracteres especiais e espaços para uso em URLs
    var urlSafe: String {
        return self.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
    }
}

// MARK: - Extensões para View
extension View {
    /// Aplica um estilo de cartão padrão
    func cardStyle() -> some View {
        self
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.UI.cornerRadius)
            .shadow(radius: Constants.UI.shadowRadius, 
                   x: 0, y: 2)
    }
    
    /// Aplica padding padrão
    func defaultPadding() -> some View {
        self.padding(Constants.Spacing.medium)
    }
    
    /// Condicional para aplicar modificadores
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Extensões para Array
extension Array where Element == DogBreed {
    /// Filtra raças por nome
    func filtered(by searchText: String) -> [DogBreed] {
        guard !searchText.isEmpty else { return self }
        return self.filter { breed in
            breed.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    /// Ordena raças alfabeticamente
    func sortedAlphabetically() -> [DogBreed] {
        return self.sorted { $0.name < $1.name }
    }
}

// MARK: - Extensões para UserDefaults
extension UserDefaults {
    /// Salva lista de IDs de raças favoritas
    func setFavoriteBreeds(_ breedIDs: Set<String>) {
        set(Array(breedIDs), forKey: Constants.UserDefaults.favoriteBreeds)
    }
    
    /// Recupera lista de IDs de raças favoritas
    func getFavoriteBreeds() -> Set<String> {
        let array = object(forKey: Constants.UserDefaults.favoriteBreeds) as? [String] ?? []
        return Set(array)
    }
}

// MARK: - Extensões para Image
extension Image {
    /// Aplica estilo padrão para imagens de raças
    func breedImageStyle() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
    }
}

// MARK: - Extensões para AsyncImage
extension AsyncImage {
    /// Inicializador com placeholder personalizado
    init<Content: View>(
        url: URL?,
        @ViewBuilder placeholder: () -> Content
    ) where Content: View {
        self.init(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .breedImageStyle()
            case .failure(_):
                placeholder()
            case .empty:
                placeholder()
            @unknown default:
                placeholder()
            }
        }
    }
}

// MARK: - Modificadores personalizados
struct LoadingModifier: ViewModifier {
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 2 : 0)
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primary))
            }
        }
    }
}

extension View {
    func loading(_ isLoading: Bool) -> some View {
        modifier(LoadingModifier(isLoading: isLoading))
    }
}

