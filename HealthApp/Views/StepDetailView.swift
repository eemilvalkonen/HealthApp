import SwiftUI

struct StepDetailView: View {
    @StateObject private var viewModel = StepDetailViewModel()

    var body: some View {
        VStack {
            Text("Askelten yksityiskohdat")
                .font(.largeTitle)
                .bold()

            Spacer()

            if let content = viewModel.responseContent {
                Text(content)
                    .font(.title2)
                    .padding()
            } else {
                Text("Ladataan tietoja askelten tärkeydestä...")
                    .font(.title2)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.fetchStepImportance()
        }
    }
}
