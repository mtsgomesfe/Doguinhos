//
//  BreedRowView.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import SwiftUI

// MARK: - View para cada item da lista de raças
struct BreedRowView: View {
    let breed: DogBreed
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    let onTap: () -> Void
    
    @State private var breedImage: String?
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Constants.Spacing.medium) {
                // Imagem da raça
                breedImageView
                
                // Informações da raça
                breedInfo
                
                Spacer()
                
                // Botão de favorito e seta
                rightSection
            }
            .padding(Constants.Spacing.medium)
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.UI.cornerRadius)
            .shadow(radius: Constants.UI.shadowRadius, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .task {
            await loadBreedImage()
        }
    }
    
    // MARK: - Imagem da raça
    private var breedImageView: some View {
        Group {
            if let imageURL = breedImage, let url = URL(string: imageURL) {
                AsyncImage(url: url) {
                    RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                        .fill(Constants.Colors.secondary.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primary))
                        }
                }
                .frame(width: 80, height: 80)
                .cornerRadius(Constants.UI.cornerRadius)
            } else {
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                    .fill(Constants.Colors.secondary.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: Constants.Icons.photo)
                            .font(.title2)
                            .foregroundColor(Constants.Colors.secondary)
                    }
            }
        }
    }
    
    // MARK: - Informações da raça
    private var breedInfo: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.small) {
            Text(breed.name)
                .font(.headline)
                .foregroundColor(Constants.Colors.text)
                .lineLimit(1)
            
            Text(breed.description)
                .font(.body)
                .foregroundColor(Constants.Colors.secondaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            HStack(spacing: Constants.Spacing.medium) {
                Label(breed.lifeSpanText, systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.secondaryText)
                
                if breed.hypoallergenic {
                    Label("Hipoalergênico", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.primary)
                }
            }
        }
    }
    
    // MARK: - Seção direita (favorito + seta)
    private var rightSection: some View {
        VStack(spacing: Constants.Spacing.small) {
            Button(action: onFavoriteToggle) {
                Image(systemName: isFavorite ? Constants.Icons.heartFilled : Constants.Icons.heart)
                    .font(.title3)
                    .foregroundColor(isFavorite ? .red : Constants.Colors.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Image(systemName: Constants.Icons.chevronRight)
                .font(.caption)
                .foregroundColor(Constants.Colors.secondary)
        }
        .frame(height: 80)
    }
    
    // MARK: - Métodos privados
    
    /// Carrega uma imagem aleatória da raça
    private func loadBreedImage() async {
        do {
            let imageURL = try await APIService.shared.fetchRandomBreedImage(for: breed.name)
            await MainActor.run {
                self.breedImage = imageURL
            }
        } catch {
            // Falha silenciosa - a view mostrará o placeholder
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        BreedRowView(
            breed: DogBreed(
                id: "1",
                name: "Golden Retriever",
                description: "Uma raça amigável e inteligente, perfeita para famílias.",
                hypoallergenic: false,
                life: LifeSpan(min: 10, max: 12),
                maleWeight: WeightRange(min: 30, max: 35),
                femaleWeight: WeightRange(min: 25, max: 30)
            ),
            isFavorite: false,
            onFavoriteToggle: {},
            onTap: {}
        )
        
        BreedRowView(
            breed: DogBreed(
                id: "2",
                name: "Poodle",
                description: "Cão inteligente e hipoalergênico, ideal para pessoas com alergias.",
                hypoallergenic: true,
                life: LifeSpan(min: 12, max: 15),
                maleWeight: WeightRange(min: 20, max: 25),
                femaleWeight: WeightRange(min: 18, max: 23)
            ),
            isFavorite: true,
            onFavoriteToggle: {},
            onTap: {}
        )
    }
    .padding()
    .background(Constants.Colors.background)
}

