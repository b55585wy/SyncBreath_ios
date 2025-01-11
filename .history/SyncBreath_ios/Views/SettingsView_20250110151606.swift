import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MeditationViewModel
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @State private var showHardwareConnection = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("设备连接")) {
                    Button(action: {
                        showHardwareConnection = true
                    }) {
                        HStack {
                            Image(systemName: bluetoothManager.isConnected ? "wave.3.right.circle.fill" : "wave.3.right.circle")
                                .foregroundColor(bluetoothManager.isConnected ? .blue : .gray)
                                .frame(width: 44, height: 44)
                            
                            VStack(alignment: .leading) {
                                Text("呼吸带")
                                    .font(.headline)
                                Text(bluetoothManager.isConnected ? "已连接" : "未连接")
                                    .font(.subheadline)
                                    .foregroundColor(bluetoothManager.isConnected ? .blue : .secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                    }
                }
                
                Section(header: Text("呼吸设置")) {
                    // 其他设置项...
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showHardwareConnection) {
                HardwareConnectionView()
            }
        }
    }
}

#Preview {
    SettingsView()
} 