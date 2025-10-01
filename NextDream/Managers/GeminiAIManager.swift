//
//  GeminiAIManager.swift
//  NextDream
//
//  Created by Belexiu Eugeniu on 01.10.2025.
//

import Foundation
import FirebaseAI

class GeminiAIManager{
    
    let ai = FirebaseAI.firebaseAI(backend: .googleAI())
    let model: GenerativeModel
    
    init() {
        self.model = ai.generativeModel(modelName: "gemini-2.5-flash")
    }
    
    func createPrompt(goalName: String) -> String{
        return """
        You are an assistant that analyzes a user’s goal and produces a set of starting-point metrics or questions to evaluate their current baseline.
        
        The user will provide a goal (for example, a fitness goal like "do 100 pushups" or a career goal like "achieve mid-level Swift developer skills").

        Your task:
        1. Identify the key dimensions that define someone’s current ability to reach that goal.
        2. Output a structured list of "starting metrics" that the user should provide about themselves.
        3. Tailor the metrics to the domain of the goal (fitness → weight, stamina, lifestyle; programming → current skills, knowledge areas, projects, etc.).

        Format your output as:

        Goal: [repeat user’s goal]
        Starting Metrics:
        1. ...
        2. ...
        3. ...
        
        
        The Goal is the following: \(goalName)
        
        Keep in mind: 
        1. Keep them short,
        2. Don't add bolt to them ***,
        """
    }
    
    func generatePropmptForSubTasks(goalName: String, goalQuestion: String, goalDescription: String, numberOfSubTasks: Int, taskType: TaskType) -> String{
        return """
                You are a task planning assistant.

                I will provide:
                1. The overall goal
                2. Asked Question to asses main level
                3. The current situation (responses to the questions)
                4. The number of subtasks to break it into
                5. Main Task Type ( Month, Week, Days, etc )
            
                - (Everything i provide will start with [ and end with ])

                Your job:
                - Break the goal into the requested number of subtasks.
                - Organize them according to the given time scale.
                - For each subtask, generate:
                   - A short, clear **Title** (like a headline).
                - Make sure tasks are actionable and ordered logically.
                - Don't add anything before the format I will provide and nothing after.
                - add [ sign before and ] at the ending of every Title/Description

                Format your output as:

                Number 
                subtask title
                what to do here
            
                Data provided: 
                1. [\(goalName)]
                2. [\(goalQuestion)]
                3. [\(goalDescription)]
                4. [\(numberOfSubTasks)]
                5. [\(taskType.rawValue)]
            """
    }
    
    func generateSubTasks(goalName: String, goalQuesetion: String, goalDescription: String, numberOfSubTasks: Int, taskType: TaskType) async -> [(name: String, description: String)]{
        let prompt = generatePropmptForSubTasks(goalName: goalName, goalQuestion: goalQuesetion, goalDescription: goalDescription, numberOfSubTasks: numberOfSubTasks, taskType: taskType)
        
        print(prompt)
        
        let returnedData = await generateCode(prompt: prompt)
        
        let regex = /\[(.*?)\]/
        let matches = returnedData.matches(of: regex)

        let results = matches.map { String($0.1) }
        
        var resultArray: [(name: String, description: String)] = []

        for i in stride(from: 0, to: results.count, by: 2) {
            guard i + 1 < results.count else { break }
            let name = results[i]
            let description = results[i + 1]
            resultArray.append((name: name, description: description))
        }
        
        return resultArray
    }
    
    func generateText(goalName: String) async -> String{
        
        let prompt = createPrompt(goalName: goalName)
        
        return await generateCode(prompt: prompt)
    }
    
    func generateCode(prompt: String) async -> String{
        var response = ""
        
        do{
            response = try await model.generateContent(prompt).text ?? "There was an error generating content."
        } catch{
            print("There was an error: \(error.localizedDescription)")
        }
        
        return response
    }

}
