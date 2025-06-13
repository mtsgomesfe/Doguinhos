//
//  NetworkStatusView.swift
//  DogBreedsApp
//
//  Created on 12/06/2025.
//

import SwiftUI

// MARK: - Componente para mostrar status da rede
struct NetworkStatusView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        if !networkMonitor.isConnected {
            HStack {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.white)
                
                Text("Sem conexão com a internet")
                    .font(.caption)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, Constants.Spacing.medium)
            .padding(.vertical, Constants.Spacing.small)
            .background(Color.red)
        }
    }
}

// MARK: - Modificador para adicionar status de rede
struct NetworkStatusModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            NetworkStatusView()
            content
        }
    }
}

extension View {
    func withNetworkStatus() -> some View {
        modifier(NetworkStatusModifier())
    }
}

