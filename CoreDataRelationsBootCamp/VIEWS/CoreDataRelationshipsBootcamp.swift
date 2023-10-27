//
//  CoreDataRelationshipsBootcamp.swift
//  CoreDataRelationsBootCamp
//  by Nick @SwiftfulThinking on YouTube
//  Created by yannemal on 27/10/2023.
//

import SwiftUI
import CoreData

// 3 entities
// businessEntity
// DepartmentEntity
// EmploymeeEntity.


//other structs:
class CoreDataManager {
    
    static let instance = CoreDataManager() // singleton instance
    let container : NSPersistentContainer
    let context : NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error loading CoreData.  \(error)")
            }
        }
        context = container.viewContext
    }
    // class method
    func save() {
        do {        
            try context.save()
        } catch let error {
            print("Error saving CoreData \(error.localizedDescription)")
        }
    }
}


class CoreDataRelationshipsViewModel: ObservableObject {
    let manager = CoreDataManager.instance
}


struct CoreDataRelationshipsBootcamp: View {
//data:
    @StateObject var vm = CoreDataRelationshipsViewModel()
    
    
    var body: some View {
      //someView:
        
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
    // methods:
    
}

#Preview {
    CoreDataRelationshipsBootcamp()
}
