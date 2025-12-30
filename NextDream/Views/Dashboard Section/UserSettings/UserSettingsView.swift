//
//  UserSettings.swift
//  NextDream
//
//  Created by Jan on 31/03/2025.
//

import SwiftUI
import SwiftData

struct UserSettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthViewModel.self) private var auth
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    @AppStorage("isEmailVerified") var emailVerified: Bool = true
    
    @State var viewModel: UserSettingsViewModel
    
    init(modelContext: ModelContext){
        _viewModel = State(wrappedValue: UserSettingsViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        ScrollView {
            // Main card with liquid glass / ultraThinMaterial background and rounded corners + shadow
            VStack(alignment: .leading, spacing: 24){
                // Group Notification and Reschedule Toggles with section header
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notifications")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)
                    
                    createNotificationToggle
                    
                    createRescheduleToggle
                }
                .padding(.vertical)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Group Category Pie Section with section header style is already included inside
                
                VStack(alignment: .leading, spacing: 16){
                    Text("Task Categories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)
                    
                    categoryPieSection
                }
                .padding(.vertical)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding(.horizontal)
                
                // MARK: - Theme and Font Pickers have been commented out to disable them as per instructions
                /*
                createThemePicker
                
                createFontSizePicker
                */
                
                // Buttons section with more spacing and prominent style
                VStack(spacing: 20) {
                    Button {
                        auth.signOut()
                        isLoggedIn = false
                        emailVerified = false
                    } label: {
                        Text("Sign out")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Button {
                        auth.deleteAccount()
                        isLoggedIn = false
                        emailVerified = false
                    } label: {
                        Text("Delete Account")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
                
            }
            .padding(.top)
            .padding(.bottom, 40)
            // Add subtle shadow and border to the entire VStack card area
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground).opacity(0.75))
                    .background(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )
            )
            .padding()
        }
        .navigationTitle("User Settings")
        .background(
            // Background adjusted for cohesive app theme,
            // subtle gray with ultraThinMaterial blur to keep modern style
            Color.gray.opacity(0.15)
                .ignoresSafeArea()
        )
        .toolbar {
            saveButton
        }
    }
}

#Preview {
    NavigationStack{
        UserSettingsView(modelContext: MockModels.container.mainContext)
    }
}

extension UserSettingsView{
    
    private var categoryPieSection: some View{
        VStack(alignment: .center){
            Text("Categories")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.leading)
            
            pieSection
                .frame(width: 200, height: 200)
            
            categoryList
            
            
            Text(String(format: "Total Tasks: %.0f%", viewModel.total))
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.leading)
            
        }
        .frame(maxWidth: .infinity)
    }
    
    private var pieSection: some View{
        ZStack {
            
            
            ForEach(Array(viewModel.chartData.enumerated()), id: \.1.0) { index, element in
                PieSlice(
                    startAngle: viewModel.angles[index],
                    endAngle: viewModel.angles[index + 1]
                )
                .fill(element.0.color)
            }
        }
    }
    
    private var categoryList: some View{
        VStack(alignment: .leading){
            ForEach(viewModel.chartData, id: \.0) { key, value in
                HStack{
                    
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 50)
                        .foregroundColor(key.color)
                    
                    Text("\(key.rawValue)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                    
                    let percentage = (Double(value) / viewModel.total) * 100;
                    
                    Text(String(format: "%.0f%%", percentage))
                }
            }
        }
        .padding()
    }
    
    struct PieSlice: Shape {
        var startAngle: Angle
        var endAngle: Angle

        func path(in rect: CGRect) -> Path {
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2

            var path = Path()
            path.move(to: center)
            path.addArc(center: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false)
            path.closeSubpath()
            return path
        }
    }
    
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
    
    // MARK: - Theme Picker Commented Out to Disable
    /*
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
    */
    
    // MARK: - Font Size Picker Commented Out to Disable
    /*
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
    */
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
