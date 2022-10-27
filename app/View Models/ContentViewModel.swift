//
//  ContentViewModel.swift
//  GiphyExplorer
//
//  Created by RqwerKnot on 01/06/2022.
//

import Foundation

extension ContentView {
    
    @MainActor class ContentViewModel: ObservableObject {
        
        // Grid View model
        let gridViewModel = GridViewModel()
        
        // Task for bouncing support
        private var updateTask: Task<Void, Error>?
        
        // Search bar text
        var userSearchText: String = "" {
            didSet(oldValue) {
                if let newQuery = newQuery(using: oldValue, and: userSearchText) {
                    updateQuery(with: newQuery)
                }
            }
        }
        
        // Return the new query for the grid, or nil if we shouldn't update the grid
        func newQuery(using oldValue: String, and newValue: String) -> String? {
            
            let oldValueTrimmed = oldValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let newValueTrimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if newValueTrimmed != oldValueTrimmed {
                return newValueTrimmed
            }
            return nil
        }
        
        // Update the grid model with a new query, after bouncing
        func updateQuery(with newQuery: String) {
            
            // Cancel the current search task, if any:
            if let task = updateTask {
                task.cancel()
            }
            
            // Create a new task with the new query
            let newTask = Task {
                // Add a minor delay before triggering an update of the query:
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                // Update the grid view to show content based on the new query:
                gridViewModel.updateWith(newQuery)

                updateTask = nil
            }
            
            // Assign the new task to the current update task
            updateTask = newTask
        }
    }
}
