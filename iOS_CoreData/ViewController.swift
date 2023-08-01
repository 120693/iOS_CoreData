//
//  ViewController.swift
//  iOS_CoreData
//
//  Created by jhchoi on 2023/07/31.
//

import UIKit

class ViewController: UIViewController {

    //  Core Data를 사용할 때, Core Data 관련 작업을 수행하기 위해 사용되는 NSManagedObjectContext를 생성하는 코드
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // UIApplication은 iOS 애플리케이션의 중심적인 객체로, 앱의 상태를 관리하고 이벤트를 처리합니다. shared는 앱 전체에서 유일한 UIApplication 인스턴스를 가져옵니다.
    // 결과적으로, 위의 코드는 앱에서 Core Data를 사용하기 위해 기본적으로 제공되는 NSManagedObjectContext를 가져와 context라는 이름의 상수에 할당합니다. 이제 context를 사용하여 Core Data를 통해 데이터를 저장, 조회, 수정, 삭제하는 작업을 수행할 수 있습니다.
    
    let tableView : UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        title = "CoreData To Do List"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Item", message: "Enter New Item", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            
            self?.createItem(name: text)
        }))
        
        present(alert, animated: true)
    }


    // Core Data
    // Core Data를 사용하여 데이터베이스에서 저장된 모든 항목을 가져오는 함수
    // ToDoListItem은 Core Data의 NSManagedObject를 서브클래싱한 클래스, Core Data 엔티티
    func getAllItems() {
        do {
            models = try context.fetch(ToDoListItem.fetchRequest()) // fetchRequest()는 해당 엔티티에 대한 NSFetchRequest 인스턴스를 반환, NSFetchRequest는 데이터를 검색하는데 사용되는 쿼리
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            // error
        }
    }
    
    func createItem(name: String) {
        let newItem = ToDoListItem(context: context) // 새로운 ToDoListItem 객체를 생성
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            try context.save() //  변경된 내용을 실제 Core Data 데이터베이스에 저장
            getAllItems()
        }
        catch {
            
        }
    }
    
    func deleteItem(item: ToDoListItem) {
        context.delete(item)
        
        do {
            try context.save() //  변경된 내용을 실제 Core Data 데이터베이스에 저장
            getAllItems()
        }
        catch {
            
        }
    }
    
    func updateItem(item: ToDoListItem, newName: String) {
        item.name = newName
        
        do {
            try context.save()
            getAllItems()
        }
        catch {
            
        }
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = models[indexPath.row]
        
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "cancle", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            let alert = UIAlertController(title: "Edit Item", message: "Edit your Item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                
                self?.updateItem(item: item, newName:newName)
            }))
            
            self.present(alert, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item)
        }))
        
        present(sheet, animated: true)
    }
}
