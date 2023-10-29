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
// MARK: - COREDATAMANAGER :
class CoreDataManager {
    
    static let instance = CoreDataManager() // singleton instance
    let container : NSPersistentContainer
    let context : NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "CoreDataContainer")
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
            print("saved succesfully, says CoreDataManager")
        } catch let error {
            print("Error saving CoreData \(error.localizedDescription)")
        }
    }
}

// MARK: - VIEWMODEL:

class CoreDataRelationshipsViewModel: ObservableObject {
    let manager = CoreDataManager.instance
    //sets up singleton that calls CoreDataManager()
    @Published var businesses: [BusinessEntity] = []
    // sets up an empty array of type BusinessEntity from the CoreDataModel
    @Published var departments: [DepartmentEntity] = []
    @Published var employees: [EmployeeEntity] = []
    
    init() {
        getBusinesses()
        getDepartments()
        getEmployees()
    }
    
    func getBusinesses() {
        let request = NSFetchRequest<BusinessEntity>(entityName: "BusinessEntity")
        // the entityName must match maybe better use an enum w string rawValue return ?
        
        // what if we wish to sort our businesses alphabetically ?
        let sort = NSSortDescriptor(keyPath: \BusinessEntity.name, ascending: true)
        request.sortDescriptors = [sort]
        
        // or if we wish to use Predicate ?
        // let filter = NSPredicate(format: "name == %@", "Apple")
        // request.predicate = filter
        
        
        do {
            businesses = try manager.context.fetch(request)
        } catch let error {
            print("Error fetching \(error.localizedDescription)")
        }
        
    }
    
    func getDepartments() {
        let request = NSFetchRequest<DepartmentEntity>(entityName: "DepartmentEntity")
        // the entityName must match maybe better use an enum w string rawValue return ?
        do {
            departments = try manager.context.fetch(request)
        } catch let error {
            print("Error fetching \(error.localizedDescription)")
        }
        
    }
    
    func getEmployees() {
        let request = NSFetchRequest<EmployeeEntity>(entityName: "EmployeeEntity")
        // the entityName must match maybe better use an enum w string rawValue return ?
        do {
            employees = try manager.context.fetch(request)
        } catch let error {
            print("Error fetching \(error.localizedDescription)")
        }
        
    }
    
    func addBusiness() {
        let newBusiness = BusinessEntity(context: manager.context)
        newBusiness.name = "Apple"
        
        // add existing dept to the new business
        // newBusiness.departments = []
        // add existing employees to the new business
        // newBusiness.employees = []
        // add newBusiness to existing dept
        // newBusiness.addToDepartments(value: DepartmentEntity)
        // add newBusiness to exisitng employee
        // newBusiness.addToEmployee(value: EmployeeEntity)
        
        // more default value to play with
        save()
    }
    
    func addDepartment() {
        let newDepartment = DepartmentEntity(context: manager.context)
        newDepartment.name = "Marketing"
        newDepartment.businesses = [businesses[0]]
        // ⬆️ adding a (default) business should only be possible if one exist since an NSSet? is expected
        // could add all the extra todos from addBusiness here to but custom for dept
        save()
    }
    
    func addEmployee() {
        let newEmployee = EmployeeEntity(context: manager.context)
        newEmployee.age = 25
        newEmployee.dateJoined = Date()
        newEmployee.name = "Chris"
        
        newEmployee.business = businesses[0]
        newEmployee.department = departments[0]
        save()
    }
    
    func deleteDepartment() {
// check Delete Rule in attribues editor.
        let department = departments[0]
        manager.context.delete(department)
        save()
        
    }
    
    func save() {
        businesses.removeAll()
        departments.removeAll()
        employees.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.manager.save()
            self.getBusinesses()
            self.getDepartments()
            self.getEmployees()
        }
    }
}

// ⬇️ instance of the class built above so its in memory within the someView UI
struct CoreDataRelationshipsBootcamp: View {
//data:
    @StateObject var vm = CoreDataRelationshipsViewModel()
    
    
    var body: some View {
// MARK: - someView UI
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Button {
                        vm.addEmployee()
                    } label: {
                        Text("Perform Action")
                            .foregroundStyle(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.cornerRadius(10))
                    }
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(alignment: .top) {
                            ForEach(vm.businesses) { business in
                            BusinessView(entity: business)
                            }
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(alignment: .top) {
                            ForEach(vm.departments) { department in
                           DepartmentView(entity: department)
                            }
                        }
                    }
                    
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(alignment: .top) {
                            ForEach(vm.employees) { employee in
                          EmployeeView(entity: employee)
                            }
                        }
                    }
                    
                } // end VStack
                .padding()
            } // end ScrollView
            .navigationTitle("relationShips")
        } //end navStack
    }
    // methods:
    
}

#Preview {
    CoreDataRelationshipsBootcamp()
}

// MARK: - otherVIEWS structs:

struct BusinessView: View {
    
    let entity: BusinessEntity
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20, content: {
            Text("Name: \(entity.name ?? "")")
                .bold()

            if let departments = entity.departments?.allObjects as? [DepartmentEntity] {
                Text("Departments:")
                    .bold()
                ForEach(departments) { department in
                    Text(department.name ?? "")
                    }
            }
            
            if let employees = entity.employees?.allObjects as? [EmployeeEntity] {
                Text("Employees")
                    .bold()
                ForEach(employees) { employee in
                    Text(employee.name ?? "")
                }
            }
        })
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.gray.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct DepartmentView: View {
    
    let entity: DepartmentEntity
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 20, content: {
            Text("Name: \(entity.name ?? "")")
                .bold()

            if let businesses = entity.businesses?.allObjects as? [BusinessEntity] {
                Text("Departments:")
                    .bold()
                ForEach(businesses) { business in
                    Text(business.name ?? "")
                    }
            }
            
            if let employees = entity.employees?.allObjects as? [EmployeeEntity] {
                Text("Employees")
                    .bold()
                ForEach(employees) { employee in
                    Text(employee.name ?? "")
                }
            }
        })
        .padding()
        .frame(maxWidth: 300, alignment: .leading)
        .background(Color.green.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct EmployeeView: View {
    
    let entity: EmployeeEntity
    
    var body: some View{
        VStack(alignment: .leading, spacing: 20, content: {
            Text("Name: \(entity.name ?? "")")
                .bold()
            Text("age: \(entity.age )")
                .fontWeight(.light)
            Text("Business")
                .bold()
            Text(entity.business?.name ?? "")
            
            Text("Department:")
                .bold()
            Text(entity.department?.name ?? "")
            
           
        })
        .padding()
        .frame(maxWidth: 260, alignment: .leading)
        .background(Color.blue.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

