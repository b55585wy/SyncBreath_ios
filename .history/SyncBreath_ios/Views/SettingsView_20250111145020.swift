import SwiftUI

/// 设置视图，用于展示和管理应用的各项设置
struct SettingsView: View {
    // 蓝牙管理器单例，用于处理蓝牙设备连接
    @StateObject private var bluetoothManager = BluetoothManager.shared
    // 控制蓝牙设备视图的显示状态
    @State private var showBluetoothView = false
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - 蓝牙设备连接部分
                // 显示蓝牙连接状态和设备管理入口
                Section(header: Text("设备连接").font(.headline)) {
                    Button(action: {
                        showBluetoothView = true
                    }) {
                        HStack {
                            // 蓝牙图标
                            Image(systemName: "wave.3.right.circle.fill")
                                .foregroundColor(.blue)
                            // 显示连接状态信息
                            VStack(alignment: .leading) {
                                Text("蓝牙设备")
                                    .foregroundColor(.primary)
                                Text(bluetoothManager.isConnected ? "已连接" : "未连接")
                                    .font(.caption)
                                    .foregroundColor(bluetoothManager.isConnected ? .green : .gray)
                            }
                            Spacer()
                            // 导航箭头
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // MARK: - 主题设置部分
                // 控制应用的外观主题
                Section(header: Text("主题设置").font(.headline)) {
                    Toggle("跟随系统", isOn: .constant(true))  // 是否跟随系统主题
                    Toggle("深色模式", isOn: .constant(false)) // 手动控制深色模式
                }
                
                // MARK: - 音频设置部分
                // 管理应用内各种音频的开关状态
                Section(header: Text("音频设置").font(.headline)) {
                    Toggle("背景音乐", isOn: .constant(true))    // 控制背景音乐
                    Toggle("呼吸引导音", isOn: .constant(true))  // 控制呼吸练习的引导音
                    Toggle("屏息提示音", isOn: .constant(true))  // 控制屏息阶段的提示音
                }
                
                // MARK: - 关于部分
                // 显示应用版本等信息
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
    }
}

// 预览提供器
#Preview {
    SettingsView()
} 
