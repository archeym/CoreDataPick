//
//  TableViewController.swift
//  WishList
//
//  Created by Arkadijs Makarenko on 26/07/2017.
//  Copyright © 2017 ArchieApps. All rights reserved.
//

import UIKit
import CoreData


class TableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

//    var topGirls = [["name":"Zoe", "image":"image1", "item": "First Pick"],["name":"Lilly", "image":"image2", "item": "Second Pick"],["name":"Becky", "image":"image3", "item": "Third Pick"],["name":"Blue", "image":"image4", "item": "Fourth Pick"],["name":"Kelly", "image":"image5", "item": "Fifth Pick"],["name":"Jin", "image":"image6", "item": "Sixth Pick"]]
    var picks = [Girls]()
    
    var managedObjectContext:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.text = "Pick"
        label.font = UIFont(name:"Redressed", size: 30)
        label.textColor = .white
        label.sizeToFit()
        
        let label2 = UILabel()
        label2.text = "Girl"
        label2.font = UIFont(name:"Papyrus", size: 30)
        label2.textColor = .white
        label2.sizeToFit()
        
        
        
        let stackView = UIStackView(arrangedSubviews: [label,label2])
        stackView.axis = .horizontal
        stackView.frame.size.width = label.frame.width + label2.frame.width
        stackView.frame.size.height = max(label.frame.height, label2.frame.height)
        
        navigationItem.titleView = stackView
        
//        let iconImageView = UIImageView(image: UIImage(named: "document"))
//        self.navigationItem.titleView = iconImageView
        
        // to remove nav bar style should be:default, translucent, bar tint:default
        //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //navigationController?.navigationBar.shadowImage = UIImage()
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        loadData()
    }
    
    func loadData(){
        let pickRequest:NSFetchRequest<Girls> = Girls.fetchRequest()
        
        do {
            picks = try managedObjectContext.fetch(pickRequest)
            self.tableView.reloadData()
        }catch{
            print("could not load data from CoreData\(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // warning Incomplete implementation, return the number of rows
        return picks.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            // remove the deleted item from the model
            
            let context: NSManagedObjectContext = managedObjectContext
            context.delete(picks[indexPath.row] )
            picks.remove(at: indexPath.row)
            do {
                try context.save()
            } catch _ {
            }
            
            // remove the deleted item from the `UITableView`
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        default:
            return
        }
        loadData()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell

        let girlPick = picks[indexPath.row]
        
        if let imagePick = UIImage(data: girlPick.image! as Data) {
           
            cell.backgroundImageView.image = imagePick
            
        }
        
        cell.nameLabel.text = girlPick.name
        cell.itemLabel.text = girlPick.pick

        return cell
    }
    
    @IBAction func addNewGirl(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            picker.dismiss(animated: true, completion: { 
                self.pickNewGirl(with: image)
            })
            
        }
    }
    
    func pickNewGirl(with image:UIImage ){
        
        let pickItem = Girls(context: managedObjectContext)
        pickItem.image = NSData(data: UIImageJPEGRepresentation(image, 0.3)!)
        
        let alert = UIAlertController (title: "New Pick", message: "Enter Girls Name and Pick", preferredStyle: .alert)
        
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = "Girl"
        }
        
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = "Pick"
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action:UIAlertAction) in
            
            let nameTextField = alert.textFields?.first
            let pickTextField = alert.textFields?.last
            
            if nameTextField?.text != "" && pickTextField?.text != "" {
                
                pickItem.name = nameTextField?.text
                pickItem.pick = pickTextField?.text
                
                do {
                    try self.managedObjectContext.save()
                    self.loadData()
                }catch {
                    
                    print("Could not save data\(error.localizedDescription)")
                }
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
}





