//
//  DataExportManager.swift
//  NextDream
//
//  Created by Jan on 14/05/2025.
//

import SwiftUI
import UIKit
import CoreGraphics

class DataExportManager{
    
    static let shared = DataExportManager()
    
    private init(){}

    
    func convertToJSON(tasks: [TaskModel]) -> Data?{
        
        let newTasksArray = TaskDashboardViewModel.asDictionaryList(tasks: tasks)
        
        return try? JSONSerialization.data(withJSONObject: newTasksArray, options: .prettyPrinted)
    }
    
    func convertToCSV(tasks: [TaskModel]) -> Data?{
        
        let newTasksArray = TaskDashboardViewModel.asDictionaryList(tasks: tasks)
        
        let headers = Array(newTasksArray[0].keys)
        var csvString = headers.joined(separator: ",") + "\n"
        
        for dict in newTasksArray {
                let row = headers.map { key in
                    if let value = dict[key] {
                        return "\"\(value)\""
                    } else {
                        return ""
                    }
                }.joined(separator: ",")
                csvString += row + "\n"
            }
        
        print(csvString);

        // Convert the CSV string to Data using UTF-8 encoding
        return csvString.data(using: .utf8)
    }
}

//MARK: PDF Region

extension DataExportManager{
    func exportTaskTreePDF(to url: URL, root: TaskModelTreeData) {
        let pageWidth: CGFloat = 595.2   // A4 width
        let pageHeight: CGFloat = 841.8  // A4 height
        var mediaBox = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        guard let context = CGContext(url as CFURL, mediaBox: &mediaBox, nil) else { return }
        context.beginPDFPage(nil)

        // Root starts at top center with a top margin
        let topMargin: CGFloat = 720
        let startX: CGFloat = pageWidth / 2
        let startY: CGFloat = topMargin

        drawNode(node: root, at: CGPoint(x: startX, y: startY), in: context)

        context.endPDFPage()
        context.closePDF()
    }
    
    func drawNode(node: TaskModelTreeData, at position: CGPoint, in context: CGContext) {
        // Configuration
        let boxSize = CGSize(width: 98, height: 50)
        let cornerRadius: CGFloat = 12

        // Determine colors based on completion
        let fillColor: UIColor = node.isCompleted ? UIColor.systemGreen : UIColor.systemGray3
        let strokeColor: UIColor = UIColor.label
        let textColor: UIColor = UIColor.label

        // Compute rect centered on provided position.x, starting at provided position.y
        // position is treated as the top-center anchor
        let origin = CGPoint(x: position.x - boxSize.width / 2, y: position.y)
        let rect = CGRect(origin: origin, size: boxSize)
        
        // Draw rounded rectangle using UIKit path with the CGRect
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        context.saveGState()
        context.setFillColor(fillColor.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()

        // Stroke for definition
        context.addPath(path.cgPath)
        context.setStrokeColor(strokeColor.withAlphaComponent(0.4).cgColor)
        context.setLineWidth(1)
        context.strokePath()
        context.restoreGState()
        
        context.saveGState()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]

        let text = "Task 1"
        let attributedText = NSAttributedString(string: text, attributes: attributes)

        // Vertical center
        let textSize = attributedText.boundingRect(with: rect.size, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        let textRect = CGRect(
            x: rect.origin.x,
            y: rect.origin.y + (rect.height - textSize.height)/2,
            width: rect.width,
            height: textSize.height
        )

        attributedText.draw(in: textRect)
        context.restoreGState()
        
    }
    
    func fetchChildren(_ parentID: String) -> [TaskModelTreeData] {
        return [
            TaskModelTreeData(id: parentID + "-1", title: "Subtask A", isCompleted: true, deadline: .now),
            TaskModelTreeData(id: parentID + "-2", title: "Subtask B", isCompleted: false, deadline: .now),
            TaskModelTreeData(id: parentID + "-3", title: "Subtask C", isCompleted: true, deadline: .now)
        ]
    }
}

