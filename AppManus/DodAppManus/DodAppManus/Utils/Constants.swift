//
//  Constants.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import Foundation
import SwiftUI

// MARK: - Constantes da aplicação
struct Constants {
    
    // MARK: - URLs das APIs
    struct API {
        static let dogAPIBaseURL = "https://dogapi.dog/api/v2"
        static let dogCEOBaseURL = "https://dog.ceo/api"
    }
    
    // MARK: - Chaves para UserDefaults
    struct UserDefaults {
        static let favoriteBreeds = "favorite_breeds"
    }
    
    // MARK: - Configurações de UI
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Double = 0.1
        static let animationDuration: Double = 0.3
        static let imageAspectRatio: CGFloat = 4/3
    }
    
    // MARK: - Cores personalizadas
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let background = Color(.systemBackground)
        static let cardBackground = Color(.systemGray6)
        static let text = Color.primary
        static let secondaryText = Color.secondary
    }
    
    // MARK: - Tamanhos de fonte
    struct FontSizes {
        static let title: CGFloat = 24
        static let headline: CGFloat = 18
        static let body: CGFloat = 16
        static let caption: CGFloat = 14
        static let small: CGFloat = 12
    }
    
    // MARK: - Espaçamentos
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }
    
    // MARK: - Textos da aplicação
    struct Texts {
        static let appTitle = "Raças de Cachorros"
        static let searchPlaceholder = "Buscar raças..."
        static let noResults = "Nenhuma raça encontrada"
        static let loading = "Carregando..."
        static let error = "Erro ao carregar dados"
        static let tryAgain = "Tentar novamente"
        static let characteristics = "Características"
        static let photos = "Fotos"
        static let lifeSpan = "Expectativa de vida"
        static let weight = "Peso"
        static let male = "Macho"
        static let female = "Fêmea"
        static let hypoallergenic = "Hipoalergênico"
        static let yes = "Sim"
        static let no = "Não"
        static let favorite = "Favorito"
        static let addToFavorites = "Adicionar aos favoritos"
        static let removeFromFavorites = "Remover dos favoritos"
    }
    
    // MARK: - Ícones SF Symbols
    struct Icons {
        static let search = "magnifyingglass"
        static let heart = "heart"
        static let heartFilled = "heart.fill"
        static let photo = "photo"
        static let info = "info.circle"
        static let chevronRight = "chevron.right"
        static let xmark = "xmark"
        static let refresh = "arrow.clockwise"
    }
}

// MARK: - Extensões úteis
extension Color {
    static let primaryBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
}

