import SwiftUI
import Combine

class StepDetailViewModel: ObservableObject {
    @Published var responseContent: String?

    private let openAIKey = "" // Muista tallentaa turvallisesti

    func fetchStepImportance() {
        guard let url = URL(string: "https://api.openai.com/v1/completions") else {
            print("URL is invalid")
            return
        }

        let prompt = "Why are steps important for health? Write in a detailed but simple manner."

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "prompt": prompt,
            "max_tokens": 100,
            "temperature": 0.7
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            print("Request body successfully created.")
        } catch {
            print("Error creating request body: \(error)")
            return
        }

        print("Sending request to OpenAI API...")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request failed with error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Failed to get HTTP response.")
                return
            }

            print("Received response with status code: \(httpResponse.statusCode)")

            if httpResponse.statusCode == 429 {
                print("Rate limit exceeded. Please wait and try again later.")
                DispatchQueue.main.async {
                    self.responseContent = "Liian monta pyyntöä tehty. Yritä myöhemmin uudelleen."
                }
                return
            }

            guard let data = data else {
                print("No data received.")
                return
            }

            do {
                print("Parsing response data...")
                // Yritetään parsia, mutta käsitellään myös virhevastaukset
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let errorMessage = json["error"] as? [String: Any], let message = errorMessage["message"] as? String {
                        print("Error message from server: \(message)")
                        DispatchQueue.main.async {
                            self.responseContent = "Virhe: \(message)"
                        }
                    } else if let choices = json["choices"] as? [[String: Any]], let text = choices.first?["text"] as? String {
                        DispatchQueue.main.async {
                            self.responseContent = text.trimmingCharacters(in: .whitespacesAndNewlines)
                            print("Response content updated.")
                        }
                    } else {
                        print("Unexpected response structure.")
                    }
                }
            } catch {
                print("Error parsing response: \(error)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw response data: \(responseString)")
                }
            }
        }

        task.resume()
        print("Request sent.")
    }
}
