//
//  ErrorHandling.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import Foundation
import SwiftUI

// MARK: - Tratamento de erros melhorado
extension APIError {
    var userFriendlyMessage: String {
        switch self {
        case .invalidURL:
            return "Erro interno da aplicação. Tente novamente."
        case .invalidResponse:
            return "Servidor indisponível. Verifique sua conexão e tente novamente."
        case .decodingError(_):
            return "Erro ao processar dados do servidor. Tente novamente mais tarde."
        case .networkError(let error):
            if error.localizedDescription.contains("offline") || error.localizedDescription.contains("internet") {
                return "Sem conexão com a internet. Verifique sua conexão."
            }
            return "Erro de rede. Verifique sua conexão e tente novamente."
        }
    }
    
    var icon: String {
        switch self {
        case .invalidURL, .decodingError(_):
            return "exclamationmark.triangle"
        case .invalidResponse:
            return "server.rack"
        case .networkError(_):
            return "wifi.slash"
        }
    }
}

// MARK: - View para exibir erros
struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Image(systemName: errorIcon)
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.secondary)
            
            Text("Ops! Algo deu errado")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.text)
            
            Text(errorMessage)
                .font(.body)
                .foregroundColor(Constants.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.Spacing.large)
            
            Button(action: retryAction) {
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
    
    private var errorMessage: String {
        if let apiError = error as? APIError {
            return apiError.userFriendlyMessage
        }
        return error.localizedDescription
    }
    
    private var errorIcon: String {
        if let apiError = error as? APIError {
            return apiError.icon
        }
        return "exclamationmark.triangle"
    }
}

// MARK: - Loading View melhorada
struct LoadingView: View {
    let message: String
    
    init(message: String = Constants.Texts.loading) {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: Constants.Spacing.medium) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primary))
            
            Text(message)
                .font(.headline)
                .foregroundColor(Constants.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(Constants.Colors.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.text)
            
            Text(message)
                .font(.body)
                .foregroundColor(Constants.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.Spacing.large)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .padding()
                        .background(Constants.Colors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.UI.cornerRadius)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Constants.Spacing.large)
    }
}

// MARK: - Modificador para estados de carregamento
struct StateViewModifier<LoadingContent: View, ErrorContent: View, EmptyContent: View>: ViewModifier {
    let isLoading: Bool
    let error: Error?
    let isEmpty: Bool
    let loadingContent: () -> LoadingContent
    let errorContent: (Error) -> ErrorContent
    let emptyContent: () -> EmptyContent
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(shouldShowContent ? 1 : 0)
            
            if isLoading {
                loadingContent()
            } else if let error = error {
                errorContent(error)
            } else if isEmpty {
                emptyContent()
            }
        }
    }
    
    private var shouldShowContent: Bool {
        !isLoading && error == nil && !isEmpty
    }
}

extension View {
    func stateView<LoadingContent: View, ErrorContent: View, EmptyContent: View>(
        isLoading: Bool,
        error: Error? = nil,
        isEmpty: Bool = false,
        @ViewBuilder loadingContent: @escaping () -> LoadingContent = { LoadingView() },
        @ViewBuilder errorContent: @escaping (Error) -> ErrorContent = { error in ErrorView(error: error, retryAction: {}) },
        @ViewBuilder emptyContent: @escaping () -> EmptyContent = { EmptyView() }
    ) -> some View {
        modifier(StateViewModifier(
            isLoading: isLoading,
            error: error,
            isEmpty: isEmpty,
            loadingContent: loadingContent,
            errorContent: errorContent,
            emptyContent: emptyContent
        ))
    }
}

