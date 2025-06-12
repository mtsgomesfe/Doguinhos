import SwiftUI

struct DogBreedsView: View {
    @StateObject private var viewModel = DogBreedsViewModel()
    @State private var isMenuPresented = false
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.orange
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Imagem com swipe e animação fluida
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
                                    .offset(x: dragOffset.width)
                                    .gesture(
                                        DragGesture()
                                            .updating($dragOffset) { value, state, _ in
                                                state = value.translation
                                            }
                                            .onEnded { value in
                                                if abs(value.translation.width) > 100 {
                                                    withAnimation(.easeInOut) {
                                                        viewModel.fetchDogImage(for: viewModel.selectedBreed)
                                                    }
                                                }
                                            }
                                    )
                                    .animation(.easeOut(duration: 0.2), value: dragOffset)
                            case .failure(_):
                                Text("Erro ao carregar imagem")
                            case .empty:
                                ProgressView()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    // Descrição da raça
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
                        .background(Color(.gray).opacity(0.6))
                        .cornerRadius(10)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                        .foregroundColor(.white)
                    }
                    
                    Spacer(minLength: 120) // Espaço para não cobrir conteúdo
                }
                .padding()
            }
            
            // Botão fixo na parte inferior
            Button(action: {
                isMenuPresented.toggle()
            }) {
                Image("doguinho-button") // Sua imagem personalizada
                    .resizable()
                    .frame(width: 120, height: 120)
                    .padding()
                    .shadow(radius: 4)
            }
            .padding(.bottom, 30)
            
            // Menu flutuante com fundo translúcido
            if isMenuPresented {
                ZStack {
                    // Fundo escurecido
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isMenuPresented = false
                        }
                    
                    // Menu no centro da tela
                    VStack {
                        
                        ScrollView {
                            ForEach(viewModel.breeds, id: \.self) { breed in
                                Button(action: {
                                    viewModel.selectedBreed = breed
                                    viewModel.fetchDogImage(for: breed)
                                    isMenuPresented = false
                                }) {
                                    Text(viewModel.formatBreedName(breed))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(8)
                                        .foregroundColor(.white)
                                        .font(.system(size: 28))
                                        	
                                    
                                }
                                Divider()
                                    .background(Color.black)
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                    .frame(width: 300, height: 400)
                    .background(Color.gray.opacity(0.6))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
            }
        }
    }
}
