class StepDetailViewModel: ObservableObject {
    @Published var responseContent: String?

    private let openAIKey = "YOUR_API_KEY" // Tallenna tämä turvallisesti, älä koskaan hardkoodaa tuotantoon!

    func fetchStepImportance() {
        guard let url = URL(string: "https://api.openai.com/v1/completions") else {
            return
        }

        let prompt = "Why are steps important for health? Write in a detailed but simple manner."

        let requestBody: [String: Any] = [
            "model": "text-davinci-003",
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
        } catch {
            print("Error creating request body: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Request failed: \(error?.localizedDescription ?? "No error description")")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let text = choices.first?["text"] as? String {
                    DispatchQueue.main.async {
                        self.responseContent = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
            } catch {
                print("Error parsing response: \(error)")
            }
        }

        task.resume()
    }
}
