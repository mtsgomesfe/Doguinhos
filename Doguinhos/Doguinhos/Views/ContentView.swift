import SwiftUI

struct DogBreedsView: View {
    @StateObject private var viewModel = DogBreedsViewModel()
    @State private var isMenuPresented = false
    @GestureState private var dragOffset: CGSize = .zero
    @State private var imageOffset: CGFloat = 0
    @State private var isImageVisible: Bool = true

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
                                    .padding(.top, 110)
                                    .padding(.horizontal, 10)
                                    .frame(height: 400)
                                    .cornerRadius(40)
                                    .shadow(radius: 8)
                                    .offset(x: dragOffset.width + imageOffset)
                                    .opacity(isImageVisible ? 1 : 0) // 👈 isso mantém o espaço
                                    .gesture(
                                        DragGesture(minimumDistance: 30)
                                            .updating($dragOffset) { value, state, _ in
                                                state = value.translation
                                            }
                                            .onEnded { value in
                                                if abs(value.translation.width) > 100 {
                                                    withAnimation(.easeInOut(duration: 0.3)) {
                                                        imageOffset = value.translation.width > 0 ? 1000 : -1000
                                                        isImageVisible = false
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                        viewModel.fetchOnlyImage(for: viewModel.selectedBreed)
                                                        imageOffset = 0
                                                        isImageVisible = true
                                                    }
                                                }
                                            }
                                    )
                                    .animation(.easeInOut, value: dragOffset)


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
                                Text("🧠 Temperamento : \(temperament)")
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

                    Spacer(minLength: 120)
                }
            }
            Spacer()
            // Botão fixo na parte inferior
            Button(action: {
                
                isMenuPresented.toggle()
            }) {

                Image("doguinho-button")
                    .resizable()
                    .frame(width: 110, height: 120)
                    .padding(.top, 100)
                    .shadow(radius: 4)
            }

            // Menu flutuante
            if isMenuPresented {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isMenuPresented = false
                        }

                    VStack {
                        Spacer()
                        ScrollView {
                            ForEach(viewModel.breeds, id: \.self) { breed in
                                Button(action: {
                                    viewModel.selectedBreed = breed
                                    viewModel.fetchDogImage(for: breed) // Aqui atualiza tudo
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
                    .frame(width: 300, height: 350)
                    .background(Color.gray.opacity(0.6))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
            }
        }
    }
}

#Preview {
    DogBreedsView()
}
