import SwiftUI

struct DogBreedsView: View {
    @StateObject private var viewModel = DogBreedsViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Escolha uma raça de cachorro")
                .font(.headline)

            // Menu personalizado
            Menu {
                ForEach(viewModel.breeds, id: \.self) { breed in
                    Button(action: {
                        viewModel.selectedBreed = breed
                        viewModel.fetchDogImage(for: breed)
                    }) {
                        Text(viewModel.formatBreedName(breed))
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.selectedBreed.isEmpty ? "Escolha uma raça" : viewModel.formatBreedName(viewModel.selectedBreed))
                        .font(.body)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(radius: 4)
            }

            // Imagem com gesto para os dois lados
            if let imageURL = viewModel.dogImageURL,
               let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .cornerRadius(15)
                            .shadow(radius: 8)
                            .gesture(
                                DragGesture(minimumDistance: 50, coordinateSpace: .local)
                                    .onEnded { value in
                                        if abs(value.translation.width) > abs(value.translation.height) {
                                            // Swipe para esquerda ou direita
                                            viewModel.fetchDogImage(for: viewModel.selectedBreed)
                                        }
                                    }
                            )
                            .animation(.easeInOut, value: viewModel.dogImageURL)
                    case .failure(_):
                        Text("Erro ao carregar imagem")
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            }

            // Descrição da raça com tradução
            if viewModel.isLoadingBreedInfo {
                ProgressView("Carregando descrição...")
            } else if let info = viewModel.breedInfo {
                VStack(alignment: .leading, spacing: 10) {
                    Text("🐾 \(info.name)")
                        .font(.title2)
                        .bold()
                    if let origin = info.origin {
                        Text("🌍 Origem: \(origin)")
                    }
                    if let bredFor = info.bred_for {
                        Text("🎯 Criado para: \(bredFor)")
                    }

                    if let translated = viewModel.translatedDescription {
                        Text("🧠 Temperamento: \(translated)")
                    } else if let temperament = info.temperament {
                        Text("🧠 Temperamento (EN): \(temperament)")
                    }

                    if let lifeSpan = info.life_span {
                        Text("⏳ Vida média: \(lifeSpan)")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 4)
                .padding(.horizontal)
                .foregroundColor(.white)
            }

            Spacer()
        }
        .padding()
        .foregroundColor(.black)
        .background(Color.orange.ignoresSafeArea())
    }
}
