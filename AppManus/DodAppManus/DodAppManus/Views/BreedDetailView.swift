//
//  BreedDetailView.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import SwiftUI

// MARK: - View de detalhes da raça
struct BreedDetailView: View {
    let breed: DogBreed
    @StateObject private var viewModel: BreedDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(breed: DogBreed) {
        self.breed = breed
        self._viewModel = StateObject(wrappedValue: BreedDetailViewModel(breed: breed))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Constants.Spacing.large) {
                // Header com imagem principal
                headerSection
                
                // Informações básicas
                basicInfoSection
                
                // Características
                characteristicsSection
                
                // Galeria de fotos
                photosSection
            }
            .padding(.bottom, Constants.Spacing.large)
        }
        .navigationTitle(breed.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                favoriteButton
            }
        }
        .task {
            await viewModel.loadImages()
        }
        .refreshable {
            await viewModel.refreshImages()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Constants.Spacing.medium) {
            // Imagem principal
            if let firstImage = viewModel.images.first,
               let url = URL(string: firstImage) {
                AsyncImage(url: url) {
                    RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                        .fill(Constants.Colors.secondary.opacity(0.3))
                        .frame(height: 250)
                        .overlay {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primary))
                        }
                }
                .frame(height: 250)
                .cornerRadius(Constants.UI.cornerRadius)
                .padding(.horizontal, Constants.Spacing.medium)
            } else {
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                    .fill(Constants.Colors.secondary.opacity(0.3))
                    .frame(height: 250)
                    .overlay {
                        VStack {
                            Image(systemName: Constants.Icons.photo)
                                .font(.system(size: 40))
                                .foregroundColor(Constants.Colors.secondary)
                            
                            if viewModel.isLoadingImages {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primary))
                                    .padding(.top, Constants.Spacing.small)
                            }
                        }
                    }
                    .padding(.horizontal, Constants.Spacing.medium)
            }
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text("Sobre a Raça")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.text)
                
                Spacer()
            }
            
            Text(breed.description)
                .font(.body)
                .foregroundColor(Constants.Colors.text)
                .lineSpacing(4)
        }
        .padding(.horizontal, Constants.Spacing.medium)
    }
    
    // MARK: - Characteristics Section
    private var characteristicsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text(Constants.Texts.characteristics)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.text)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Constants.Spacing.medium) {
                ForEach(viewModel.breedFacts, id: \.title) { fact in
                    BreedFactCard(fact: fact)
                }
            }
        }
        .padding(.horizontal, Constants.Spacing.medium)
    }
    
    // MARK: - Photos Section
    private var photosSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
            HStack {
                Text(Constants.Texts.photos)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.text)
                
                Spacer()
                
                if viewModel.isLoadingImages {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primary))
                }
            }
            .padding(.horizontal, Constants.Spacing.medium)
            
            if viewModel.hasImages {
                ImageCarouselView(images: viewModel.images)
            } else if viewModel.shouldShowImagesError {
                errorStateView
            } else if viewModel.shouldShowEmptyImages {
                emptyImagesView
            }
        }
    }
    
    // MARK: - Favorite Button
    private var favoriteButton: some View {
        Button(action: {
            viewModel.toggleFavorite()
        }) {
            Image(systemName: viewModel.isFavorite ? Constants.Icons.heartFilled : Constants.Icons.heart)
                .font(.title3)
                .foregroundColor(viewModel.isFavorite ? .red : Constants.Colors.primary)
        }
    }
    
    // MARK: - Error State View
    private var errorStateView: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(Constants.Colors.secondary)
            
            Text("Erro ao carregar fotos")
                .font(.headline)
                .foregroundColor(Constants.Colors.text)
            
            Button(action: {
                Task {
                    await viewModel.refreshImages()
                }
            }) {
                Text(Constants.Texts.tryAgain)
                    .padding(.horizontal, Constants.Spacing.large)
                    .padding(.vertical, Constants.Spacing.small)
                    .background(Constants.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(Constants.UI.cornerRadius)
            }
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.UI.cornerRadius)
        .padding(.horizontal, Constants.Spacing.medium)
    }
    
    // MARK: - Empty Images View
    private var emptyImagesView: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Image(systemName: Constants.Icons.photo)
                .font(.system(size: 40))
                .foregroundColor(Constants.Colors.secondary)
            
            Text("Nenhuma foto disponível")
                .font(.headline)
                .foregroundColor(Constants.Colors.text)
            
            Text("Não foi possível encontrar fotos desta raça")
                .font(.body)
                .foregroundColor(Constants.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.UI.cornerRadius)
        .padding(.horizontal, Constants.Spacing.medium)
    }
}

// MARK: - Breed Fact Card
struct BreedFactCard: View {
    let fact: BreedFact
    
    var body: some View {
        VStack(spacing: Constants.Spacing.small) {
            HStack {
                Image(systemName: fact.icon)
                    .font(.title3)
                    .foregroundColor(Constants.Colors.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(fact.title)
                        .font(.caption)
                        .foregroundColor(Constants.Colors.secondaryText)
                    
                    Spacer()
                }
                
                HStack {
                    Text(fact.value)
                        .font(.headline)
                        .foregroundColor(Constants.Colors.text)
                    
                    Spacer()
                }
                
                HStack {
                    Text(fact.description)
                        .font(.caption2)
                        .foregroundColor(Constants.Colors.secondaryText)
                        .lineLimit(2)
                    
                    Spacer()
                }
            }
        }
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.UI.cornerRadius)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        BreedDetailView(breed: DogBreed(
            id: "1",
            name: "Golden Retriever",
            description: "O Golden Retriever é uma raça de cão originária da Escócia, desenvolvida durante o reinado da Rainha Vitória. São cães amigáveis, inteligentes e devotos. Os Golden Retrievers são excelentes cães de família e são particularmente pacientes com crianças.",
            hypoallergenic: false,
            life: LifeSpan(min: 10, max: 12),
            maleWeight: WeightRange(min: 30, max: 35),
            femaleWeight: WeightRange(min: 25, max: 30)
        ))
    }
}

