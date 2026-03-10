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
    
    func generatePromptForAsingleSubTasks(goalName: String, goalQuestion: String, goalDescription: String,
                                          otherTaskName: String, mainParentType: TaskType, childrenTaskType: TaskType) -> String{
        return """
            You are an AI agent that generates subtask for a given task.
            Always return the output in the following strict format:
                •    Data recived for me will be inside [] for every point 
                •    Each subtask response must be wrapped inside [].
                •    Each subtask must have two parts inside brackets:
                •    You must return only one response, don't add brakets for them both, only for name and describtion
                •    You must give a name to the month, don't leave it as Month x or Week y ( Don't add them at all in the title )
                •    Don't add a Month name or Year name because I handle this alone.
                •    All task comes in chronological order
                •    You will have to generate a task for where the subTask contains. "This is the main task:"
        
                This is how you must return ( Nothing else )
                -  [Subtask Name] - [Subtask Description]

            You will be given:
                1    Main Task Name
                2    Asked Question
                3    User Responses (to the main task)
                4    Existing Subtask Names (if there are dates, just ignore them, every task will be followed by ',' , then start's a new one)
                5    Parent Type (e.g., Year, Month, Week, day)
                6    Child Type (e.g., Year, Month, Week, day)
        
            There is the data: 
                1. [\(goalName)]
                2. [\(goalQuestion)]
                3. [\(goalDescription)]
                4. [\(otherTaskName)]
                4. [\(mainParentType)]
                5. [\(childrenTaskType)]
        """
    }
    
    func generatePropmptForSubTasks(goalName: String, goalQuestion: String, goalDescription: String, numberOfSubTasks: Int, taskData: String, taskType: TaskType) -> String{
        return """
                You are a task planning assistant.

                I will provide:
                1. The overall goal
                2. Asked Question to asses main level
                3. The current situation (responses to the questions)
                4. The number of subtasks to break it into
                5. SubTasks data [Start Date+ End Date+TaskType] (each task will end with ',', and they will come in chronological order)
                6. Main Task Type ( Month, Week, Days, etc )
            
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

                subtask title
                what to do here
            
                Data provided: 
                1. [\(goalName)]
                2. [\(goalQuestion)]
                3. [\(goalDescription)]
                4. [\(numberOfSubTasks)]
                5. [\(taskData)]
                6. [\(taskType.displayName)]
            """
    }
    
    func generateSubTasks(goalName: String, goalQuesetion: String, goalDescription: String, numberOfSubTasks: Int, taskData: String, taskType: TaskType) async -> [(name: String, description: String)]{
        let prompt = generatePropmptForSubTasks(goalName: goalName, goalQuestion: goalQuesetion, goalDescription: goalDescription, numberOfSubTasks: numberOfSubTasks, taskData: taskData, taskType: taskType)
        
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
        
        if resultArray.count > numberOfSubTasks {
            let difference = resultArray.count - numberOfSubTasks
            
            for _ in 0..<difference {
                resultArray.removeLast()
            }
        }
        
        return resultArray
    }
    
    func generateSubTask(goalName: String, goalQuestion: String, goalDescription: String,
                          otherTaskName: String, mainParentType: TaskType, childrenTaskType: TaskType) async -> (name: String, description: String) {
        let prompt = generatePromptForAsingleSubTasks(
            goalName: goalName,
            goalQuestion: goalQuestion,
            goalDescription: goalDescription,
            otherTaskName: otherTaskName,
            mainParentType: mainParentType,
            childrenTaskType: childrenTaskType
        )
        
        let returnedData = await generateCode(prompt: prompt)
        
        print(returnedData)
        
        let regex = /\[(.*?)\]/
        let matches = returnedData.matches(of: regex)
        
        let results = matches.map { String($0.1) }
        
        if results.count < 2 {
            return ("", "")
        }
        
        return (results[0], results[1])
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
