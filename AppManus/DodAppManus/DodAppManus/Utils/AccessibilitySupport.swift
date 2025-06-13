//
//  AccessibilitySupport.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import SwiftUI

// MARK: - Suporte a acessibilidade
extension View {
    /// Adiciona suporte a acessibilidade para botões
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
    
    /// Adiciona suporte a acessibilidade para imagens
    func accessibleImage(label: String) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isImage)
    }
    
    /// Adiciona suporte a acessibilidade para texto
    func accessibleText(label: String? = nil) -> some View {
        self
            .accessibilityLabel(label ?? "")
    }
}

// MARK: - Extensões para melhorar acessibilidade
extension BreedRowView {
    var accessibilityLabel: String {
        var label = "Raça \(breed.name). "
        label += breed.description + ". "
        label += "Expectativa de vida: \(breed.lifeSpanText). "
        
        if breed.hypoallergenic {
            label += "Hipoalergênico. "
        }
        
        if isFavorite {
            label += "Marcado como favorito. "
        }
        
        return label
    }
    
    var accessibilityHint: String {
        return "Toque duas vezes para ver detalhes da raça"
    }
}

extension BreedDetailView {
    var headerAccessibilityLabel: String {
        return "Imagem da raça \(breed.name)"
    }
}

// MARK: - Constantes de acessibilidade
extension Constants {
    struct Accessibility {
        static let favoriteButton = "Botão de favorito"
        static let favoriteHint = "Toque duas vezes para adicionar ou remover dos favoritos"
        static let searchField = "Campo de busca de raças"
        static let searchHint = "Digite o nome da raça que deseja encontrar"
        static let clearSearch = "Limpar busca"
        static let refreshList = "Atualizar lista de raças"
        static let breedImage = "Imagem da raça"
        static let photoGallery = "Galeria de fotos"
        static let fullScreenImage = "Imagem em tela cheia"
        static let closeFullScreen = "Fechar visualização em tela cheia"
        static let networkStatus = "Status da conexão de rede"
        static let retryButton = "Tentar novamente"
        static let loadingIndicator = "Carregando conteúdo"
    }
}

// MARK: - Suporte a Dynamic Type
extension Font {
    static func scaledFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .default)
    }
}

// MARK: - Suporte a cores de alto contraste
extension Color {
    static var adaptiveText: Color {
        Color.primary
    }
    
    static var adaptiveSecondaryText: Color {
        Color.secondary
    }
    
    static var adaptiveBackground: Color {
        Color(.systemBackground)
    }
    
    static var adaptiveCardBackground: Color {
        Color(.secondarySystemBackground)
    }
}

