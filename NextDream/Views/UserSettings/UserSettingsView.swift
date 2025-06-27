//
//  UserSettings.swift
//  NextDream
//
//  Created by Jan on 31/03/2025.
//

import SwiftUI

enum Theme: String, CaseIterable{
    case light = "light"
    case dark = "dark"
    case custom = "custom"
}

enum FontSize: String, CaseIterable{
    case largeTitle = "Extremly Big"
    case title2 = "Big"
    case headline = "Normal"
    case body = "Small"
}

struct UserSettingsView: View {
    
    @State var notification: Bool = false;
    @State var autoReschedule: Bool = false;
    @State var selectedTheme: Theme = .light;
    @State var selectedFontSize: FontSize = .body;
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading){
                createNotificationToggle()
                
                createRescheduleToggle()
                
                createThemePicker()
                
                createFontSizePicker()
                
                HStack{
                    Button {
                        
                    } label: {
                        Text("Export")
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("Categories")
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("Import")
                    }
                }
                .padding()

                
            }
            .padding()
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
        Toggle("Notification", isOn: $notification)
            .font(.title3)
            .fontWeight(.semibold)
            .onLongPressGesture {
                // Add a mini explication for every thing
            }
            .padding()
    }
    
    private func createRescheduleToggle() -> some View{
        Toggle("Auto-Reschedule", isOn: $autoReschedule)
            .font(.title3)
            .fontWeight(.semibold)
            .padding()
    }
    
    private func createThemePicker() -> some View{
        HStack{
            Text("Theme: ")
                .font(.title3)
                .fontWeight(.semibold)
            
            Picker("Select Theme", selection: $selectedTheme) {
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
            
            Picker("", selection: $selectedFontSize) {
                ForEach(FontSize.allCases, id: \.self) { size in
                    Text(size.rawValue);
                }
            }
        }
        .padding()
    }
}
