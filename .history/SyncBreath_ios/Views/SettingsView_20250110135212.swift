import SwiftUI

struct SettingsView: View {
    @StateObject private var bluetoothManager = BluetoothManager.shared
    @State private var showBluetoothView = false
    
    var body: some View {
        NavigationView {
            Form {
                // 蓝牙设备连接
                Section(header: Text("设备连接").font(.headline)) {
                    Button(action: {
                        showBluetoothView = true
                    }) {
                        HStack {
                            Image(systemName: "wave.3.right.circle.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text("蓝牙设备")
                                    .foregroundColor(.primary)
                                Text(bluetoothManager.isConnected ? "已连接" : "未连接")
                                    .font(.caption)
                                    .foregroundColor(bluetoothManager.isConnected ? .green : .gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // 主题设置
                Section(header: Text("主题设置").font(.headline)) {
                    Toggle("跟随系统", isOn: .constant(true))
                    Toggle("深色模式", isOn: .constant(false))
                }
                
                // 音频设置
                Section(header: Text("音频设置").font(.headline)) {
                    Toggle("背景音乐", isOn: .constant(true))
                    Toggle("呼吸引导音", isOn: .constant(true))
                    Toggle("屏息提示音", isOn: .constant(true))
                }
                
                // 关于
                Section(header: Text("关于").font(.headline)) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("设置")
        }
        .sheet(isPresented: $showBluetoothView) {
            BluetoothDeviceView()
        }
    }
}

#Preview {
    SettingsView()
} 