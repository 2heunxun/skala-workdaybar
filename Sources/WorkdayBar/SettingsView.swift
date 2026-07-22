import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @AppStorage(PreferenceKeys.clockInHour) private var clockInHour = 9
    @AppStorage(PreferenceKeys.clockInMinute) private var clockInMinute = 0
    @AppStorage(PreferenceKeys.clockOutHour) private var clockOutHour = 18
    @AppStorage(PreferenceKeys.clockOutMinute) private var clockOutMinute = 0
    @AppStorage(PreferenceKeys.dimAlpha) private var dimAlpha = 0.15
    @AppStorage(PreferenceKeys.fillDirection) private var fillDirectionRaw = FillDirectionPreference.leftToRight.rawValue
    @AppStorage(PreferenceKeys.hideOnWeekend) private var hideOnWeekend = false
    @AppStorage(PreferenceKeys.launchAtLogin) private var launchAtLogin = false

    @State private var customImageName: String? = CustomImageStore.currentImageURL()?.lastPathComponent
    @State private var launchAtLoginError: String?

    private var clockInBinding: Binding<Date> {
        Binding(
            get: { Self.date(hour: clockInHour, minute: clockInMinute) },
            set: { newValue in
                let (h, m) = Self.components(from: newValue)
                clockInHour = h
                clockInMinute = m
            }
        )
    }

    private var clockOutBinding: Binding<Date> {
        Binding(
            get: { Self.date(hour: clockOutHour, minute: clockOutMinute) },
            set: { newValue in
                let (h, m) = Self.components(from: newValue)
                clockOutHour = h
                clockOutMinute = m
            }
        )
    }

    var body: some View {
        Form {
            Section("근무 시간") {
                DatePicker("출근 시각", selection: clockInBinding, displayedComponents: .hourAndMinute)
                DatePicker("퇴근 시각", selection: clockOutBinding, displayedComponents: .hourAndMinute)
            }

            Section("아이콘") {
                HStack {
                    Text(customImageName ?? "기본 이미지 사용 중")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("이미지 선택…") { chooseImage() }
                    if customImageName != nil {
                        Button("기본값으로") { resetImage() }
                    }
                }

                VStack(alignment: .leading) {
                    Text("미경과 구간 투명도: \(Int(dimAlpha * 100))%")
                    Slider(value: $dimAlpha, in: 0...0.5)
                }

                Picker("채움 방향", selection: $fillDirectionRaw) {
                    ForEach(FillDirectionPreference.allCases) { direction in
                        Text(direction.displayName).tag(direction.rawValue)
                    }
                }
            }

            Section("동작") {
                Toggle("주말엔 아이콘 숨기기", isOn: $hideOnWeekend)
                Toggle("로그인 시 자동 실행", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        applyLaunchAtLogin(newValue)
                    }
                if let error = launchAtLoginError {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .padding(20)
        .frame(width: 420)
        .onAppear {
            launchAtLogin = LaunchAtLogin.isRegistered
        }
    }

    private func chooseImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.title = "메뉴바 아이콘으로 사용할 이미지 선택"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            let stored = try CustomImageStore.importImage(from: url)
            customImageName = stored.lastPathComponent
        } catch {
            let alert = NSAlert()
            alert.messageText = "이미지를 가져오지 못했습니다"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
    }

    private func resetImage() {
        CustomImageStore.resetToDefault()
        customImageName = nil
    }

    private func applyLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try LaunchAtLogin.register()
            } else {
                try LaunchAtLogin.unregister()
            }
            launchAtLoginError = nil
        } catch {
            launchAtLoginError = "로그인 시 자동 실행 설정에 실패했습니다: \(error.localizedDescription)"
            launchAtLogin = LaunchAtLogin.isRegistered
        }
    }

    private static func date(hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }

    private static func components(from date: Date) -> (Int, Int) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0, components.minute ?? 0)
    }
}
