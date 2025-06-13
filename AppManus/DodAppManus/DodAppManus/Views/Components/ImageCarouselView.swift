//
//  ImageCarouselView.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import SwiftUI

// MARK: - Componente de carrossel de imagens
struct ImageCarouselView: View {
    let images: [String]
    @State private var selectedImageIndex: Int = 0
    @State private var showingFullScreen: Bool = false
    
    var body: some View {
        VStack(spacing: Constants.Spacing.medium) {
            // Imagem principal
            mainImageView
            
            // Thumbnails
            if images.count > 1 {
                thumbnailsView
            }
        }
        .sheet(isPresented: $showingFullScreen) {
            FullScreenImageView(
                images: images,
                selectedIndex: $selectedImageIndex
            )
        }
    }
    
    // MARK: - Imagem principal
    private var mainImageView: some View {
        Group {
            if let imageURL = images[safe: selectedImageIndex],
               let url = URL(string: imageURL) {
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
                .onTapGesture {
                    showingFullScreen = true
                }
            }
        }
        .padding(.horizontal, Constants.Spacing.medium)
    }
    
    // MARK: - Thumbnails
    private var thumbnailsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Spacing.small) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, imageURL in
                    if let url = URL(string: imageURL) {
                        AsyncImage(url: url) {
                            RoundedRectangle(cornerRadius: Constants.UI.cornerRadius / 2)
                                .fill(Constants.Colors.secondary.opacity(0.3))
                                .frame(width: 60, height: 60)
                                .overlay {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primary))
                                        .scaleEffect(0.7)
                                }
                        }
                        .frame(width: 60, height: 60)
                        .cornerRadius(Constants.UI.cornerRadius / 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.UI.cornerRadius / 2)
                                .stroke(
                                    selectedImageIndex == index ? Constants.Colors.primary : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: Constants.UI.animationDuration)) {
                                selectedImageIndex = index
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.medium)
        }
    }
}

// MARK: - Tela cheia para visualização de imagens
struct FullScreenImageView: View {
    let images: [String]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, imageURL in
                    if let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        .tag(index)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fechar") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(selectedIndex + 1) de \(images.count)")
                        .foregroundColor(.white)
                        .font(.caption)
                }
            }
        }
    }
}

// MARK: - Extensão para acesso seguro a arrays
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview
#Preview {
    ImageCarouselView(images: [
        "https://images.dog.ceo/breeds/retriever-golden/n02099601_100.jpg",
        "https://images.dog.ceo/breeds/retriever-golden/n02099601_101.jpg",
        "https://images.dog.ceo/breeds/retriever-golden/n02099601_102.jpg"
    ])
    .padding()
    .background(Constants.Colors.background)
}

