//
//  UserSettings.swift
//  NextDream
//
//  Created by Jan on 31/03/2025.
//

import SwiftUI

struct UserSettingsView: View {
    
    @State var viewModel = UserSettingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                createNotificationToggle()
                
                createRescheduleToggle()
                
                createThemePicker()
                
                createFontSizePicker()
            }
            .padding(.top)
        }
        .navigationTitle("User Settings")
        .background(.gray.opacity(0.4))
    }
}

#Preview {
    NavigationStack{
        UserSettingsView()
    }
}

extension UserSettingsView{
    
    private func createNotificationToggle() -> some View{
        Toggle("Notification", isOn: $viewModel.notification)
            .font(.title3)
            .fontWeight(.semibold)
            .onLongPressGesture {
                // Add a mini explication for every thing
            }
            .padding()
    }
    
    private func createRescheduleToggle() -> some View{
        VStack{
            Toggle("Auto-Reschedule", isOn: $viewModel.autoReschedule)
                .font(.title3)
                .fontWeight(.semibold)
                .padding()
            
            
            HStack{
                
                if viewModel.autoReschedule{
                    
                    Text("Add your time")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    DatePicker(
                        "Add your hour",
                        selection: $viewModel.autoRescheduleTime,
                        displayedComponents: .hourAndMinute
                    )
                    .disabled(!viewModel.autoReschedule)
                    .labelsHidden()
                }
            }
            .frame(height: 30)
            .padding(.horizontal)
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.autoReschedule)
    }
    
    private func createThemePicker() -> some View{
        HStack{
            Text("Theme: ")
                .font(.title3)
                .fontWeight(.semibold)
            
            Picker("Select Theme", selection: $viewModel.selectedTheme) {
                ForEach(Theme.allCases, id: \.self) { theme in
                    Text(theme.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
    }
    
    private func createFontSizePicker() -> some View{
        HStack{
            Text("Font Size:")
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
            
            Picker("", selection: $viewModel.selectedFontSize) {
                ForEach(FontSize.allCases, id: \.self) { size in
                    Text(size.rawValue);
                }
            }
        }
        .padding()
    }
}
