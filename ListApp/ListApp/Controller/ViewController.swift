//
//  ViewController.swift
//  ListApp
//
//  Created by Enes Yıldırım on 28.02.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController{
    
    var alertController = UIAlertController()
    
    var data = [NSManagedObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        

    }
    
    
    @IBAction func didRemoveBarButtonItemTapped(_ sender: UIBarButtonItem) {
        presentAlert(title: "UYARI",
                     message: "Listedeki bütün öğeleri sileceğinizi onaylıyor musunuz?",
                     defaulButtonTitle: "Evet",
                     cancelButtonTitle: "Vazgeç",
                     DefaultButtonHandler: {_ in
            
            let AppDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = AppDelegate?.persistentContainer.viewContext
            for item in self.data{
                managedObjectContext?.delete(item)
            }
          try?  managedObjectContext?.save()
            
            
            self.data.removeAll()
            self.fetch()
        })
   
    }
    
    @IBAction func didAddBarButtonItemTapped(_ sender: UIBarButtonItem){
        presentAddAlert()
    }
    func presentAlert(){
        
      
       
    }
    func presentAddAlert(){
        
        presentAlert(title: "Yeni Eleman Ekle",
                     message: nil,
                     preferredStyle: .alert,
                     defaulButtonTitle: "Ekle",
                     cancelButtonTitle:"Vazgeç",
                     isTextFieldAvailable: true,
                     DefaultButtonHandler: { [self]_ in
            let text = self.alertController.textFields?.first?.text
            if text != ""{
                
                let AppDelegate = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = AppDelegate?.persistentContainer.viewContext
                
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                
                listItem.setValue(text, forKey: "title")
                
               try? managedObjectContext?.save()
                
                
                self.fetch()
                
            }
            else{
                self.presentWarningAlert()
            }
        })
    }
    
    func presentWarningAlert(){

        presentAlert(title: "Uyarı",
                     message: "Boş Eleman Ekleyemezsin",
                     cancelButtonTitle: "Tamam")
        
    }
    
    func presentAlert(title:String?,
                      message: String?,
                      preferredStyle: UIAlertController.Style = .alert,
                      defaulButtonTitle: String? = nil,
                      cancelButtonTitle: String?,
                      isTextFieldAvailable: Bool = false,
                      DefaultButtonHandler: ((UIAlertAction) -> Void)? = nil

    
    ){
        
        alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: preferredStyle)
        if defaulButtonTitle != nil{
            let defaultButton = UIAlertAction(title: defaulButtonTitle, style: .default, handler: DefaultButtonHandler )
            alertController.addAction(defaultButton)

        }
        
        
        let cancelbutton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        if  isTextFieldAvailable {
            alertController.addTextField()
        }
        
        alertController.addAction(cancelbutton)
            present(alertController, animated: true)
    }
    
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fetchRequest) as! [NSManagedObject]
        tableView.reloadData()
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection
                   section: Int) -> Int {
        return data.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = (listItem.value(forKey: "title") as! String)
            return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Sil") { _, _, _ in
            
            let AppDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = AppDelegate?.persistentContainer.viewContext
            
            managedObjectContext?.delete(self.data[indexPath.row])
            
            try?    managedObjectContext?.save()
            
            
            self.fetch()
            
        }
        deleteAction.backgroundColor = .systemRed
        
        let removeAction = UIContextualAction(style: .normal, title: "Düzenle") { _, _, _ in
            self.presentAlert(title: "Elemanı Düzenle",
                         message: nil,
                         preferredStyle: .alert,
                         defaulButtonTitle: "Düzenle",
                         cancelButtonTitle:"Vazgeç",
                         isTextFieldAvailable: true,
                         DefaultButtonHandler: { [self]_ in
                let text = self.alertController.textFields?.first?.text
                if text != ""{
                    
                    let AppDelegate = UIApplication.shared.delegate as? AppDelegate
                    
                    let managedObjectContext = AppDelegate?.persistentContainer.viewContext
                    
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    
                    if managedObjectContext!.hasChanges {
                        
                     try?   managedObjectContext?.save()
                    }
                    
                    self.tableView.reloadData()
                }
                else{
                    self.presentWarningAlert()
                }
            })
        }
        
        let config = UISwipeActionsConfiguration(actions: [removeAction, deleteAction])
        return config
    }
}
