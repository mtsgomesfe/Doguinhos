//
//  BreedsListView.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import SwiftUI

// MARK: - View principal da lista de raças
struct BreedsListView: View {
    @StateObject private var viewModel = BreedsListViewModel()
    @State private var selectedBreed: DogBreed?
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        NavigationStack {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Status da rede
                    NetworkStatusView()
                    
                    // Barra de busca
                    searchBar
                    
                    // Conteúdo principal
                    mainContent
                }
            }
            .navigationTitle(Constants.Texts.appTitle)
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refreshBreeds()
            }
            .task {
                if !viewModel.hasBreeds {
                    await viewModel.loadBreeds()
                }
            }
            .navigationDestination(item: $selectedBreed) { breed in
                BreedDetailView(breed: breed)
            }
        }
    }
    
    // MARK: - Barra de busca
    private var searchBar: some View {
        HStack {
            Image(systemName: Constants.Icons.search)
                .foregroundColor(Constants.Colors.secondaryText)
            
            TextField(Constants.Texts.searchPlaceholder, text: $viewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: Constants.Icons.xmark)
                        .foregroundColor(Constants.Colors.secondaryText)
                }
            }
        }
        .padding(Constants.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.UI.cornerRadius)
        .padding(.horizontal, Constants.Spacing.medium)
        .padding(.top, Constants.Spacing.small)
    }
    
    // MARK: - Conteúdo principal
    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isLoading {
            loadingView
        } else if viewModel.shouldShowErrorState {
            errorView
        } else if viewModel.shouldShowEmptyState {
            emptyStateView
        } else {
            breedsList
        }
    }
    
    // MARK: - Lista de raças
    private var breedsList: some View {
        List(viewModel.filteredBreeds) { breed in
            BreedRowView(
                breed: breed,
                isFavorite: viewModel.isFavorite(breed),
                onFavoriteToggle: {
                    viewModel.toggleFavorite(for: breed)
                },
                onTap: {
                    selectedBreed = breed
                }
            )
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(PlainListStyle())
        .padding(.top, Constants.Spacing.small)
    }
    
    // MARK: - Estado de carregamento
    private var loadingView: some View {
        VStack(spacing: Constants.Spacing.medium) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primary))
            
            Text(Constants.Texts.loading)
                .font(.headline)
                .foregroundColor(Constants.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Estado de erro
    private var errorView: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.secondary)
            
            Text(Constants.Texts.error)
                .font(.headline)
                .foregroundColor(Constants.Colors.text)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(Constants.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Spacing.large)
            }
            
            Button(action: {
                Task {
                    await viewModel.refreshBreeds()
                }
            }) {
                HStack {
                    Image(systemName: Constants.Icons.refresh)
                    Text(Constants.Texts.tryAgain)
                }
                .padding()
                .background(Constants.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(Constants.UI.cornerRadius)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Constants.Spacing.large)
    }
    
    // MARK: - Estado vazio (sem resultados de busca)
    private var emptyStateView: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Image(systemName: Constants.Icons.search)
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.secondary)
            
            Text(Constants.Texts.noResults)
                .font(.headline)
                .foregroundColor(Constants.Colors.text)
            
            Text("Tente buscar por outro nome de raça")
                .font(.body)
                .foregroundColor(Constants.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Constants.Spacing.large)
    }
}

// MARK: - Preview
#Preview {
    BreedsListView()
}

