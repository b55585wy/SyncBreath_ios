.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button {
            showSettings.toggle()
        } label: {
            Image(systemName: "gear")
        }
    }
}
.sheet(isPresented: $showSettings) {
    SettingsView(viewModel: viewModel)
} 