//
//  UserSettings.swift
//  NextDream
//
//  Created by Jan on 31/03/2025.
//

import SwiftUI

struct UserSettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State var viewModel = UserSettingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                createNotificationToggle
                
                createRescheduleToggle
                
                createThemePicker
                
                createFontSizePicker
            }
            .padding(.top)
        }
        .navigationTitle("User Settings")
        .background(.gray.opacity(0.4))
        .toolbar {
            saveButton
        }
    }
}

#Preview {
    NavigationStack{
        UserSettingsView()
    }
}

extension UserSettingsView{
    
    private var createNotificationToggle: some View{
        Toggle("Notification", isOn: $viewModel.notification)
            .font(.title3)
            .fontWeight(.semibold)
            .onLongPressGesture {
                // Add a mini explication for every thing
            }
            .padding()
            .onChange(of: viewModel.notification) {
                Task{ await viewModel.updateNotificationStatus() }
            }
    }
    
    private var createRescheduleToggle: some View{
        VStack{
            if viewModel.notification{
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
        }
        .frame(height: 90)
        .animation(.easeInOut(duration: 0.3), value: viewModel.autoReschedule)
        .animation(.easeOut(duration: 0.3), value: viewModel.notification)
    }
    
    private var createThemePicker: some View{
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
    
    private var createFontSizePicker: some View{
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

extension UserSettingsView{
    private var saveButton: ToolbarItem<Void, some View>{
        ToolbarItem(placement: .topBarTrailing) {
            Button("Save"){
                Task{
                    await viewModel.saveData()
                }
                dismiss()
            }
        }
    }
}
