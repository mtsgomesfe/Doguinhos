//
//  TranslationService.swift
//  TestesDeAPI
//
//  Created by Matheus on 07/06/25.
//

import Foundation

struct TranslationResponse: Decodable {
    let translatedText: String
}

class TranslationService {
    func translate(text: String, from sourceLang: String = "en", to targetLang: String = "pt", completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://libretranslate.com/translate") else {
            completion(nil)
            return
        }

        let parameters: [String: Any] = [
            "q": text,
            "source": sourceLang,
            "target": targetLang,
            "format": "text"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Erro ao codificar JSON: \(error)")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print("Erro na requisição: \(error?.localizedDescription ?? "Desconhecido")")
                completion(nil)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(TranslationResponse.self, from: data)
                completion(decoded.translatedText)
            } catch {
                print("Erro ao decodificar tradução: \(error)")
                completion(nil)
            }
        }.resume()
    }
}
