//
//  ViewController.swift
//  LocalDatabase
//
//  Created by 123 on 06.08.17.
//  Copyright © 2017 taras team. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {
    
    var database: Connection!
    let usersTable = Table("users")
    let id = Expression<Int>("id")
    let name = Expression<String>("name")
    let email = Expression<String>("email")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            
            let database = try Connection("\(path)/db.sqlite3")
            self.database = database
        } catch {
            print(error)
        }
    }
    
    @IBAction func CreateTableTapped(_ sender: Any) {
        print("CREATE TAPPED")
        
        let createTable = self.usersTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.name)
            table.column(self.email)
        }
        do {
            try self.database.run(createTable)
            print("Table Created")
        } catch {
            print(error)
        }
    }
    
    @IBAction func InsertUserTapped(_ sender: Any) {
        print("INSERT TAPPED")
        let alert = UIAlertController(title: "Insert User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "name"
        }
        alert.addTextField { (tf) in
            tf.placeholder = "email"
        }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let name = alert.textFields?.first?.text, let email = alert.textFields?.last?.text else { return }
            print(name)
            print(email)
            let insertUser = self.usersTable.insert(self.name <- name, self.email <- email)
            
            do {
                try self.database.run(insertUser)
                print("Inserted user")
            } catch {
                print(error)
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func listUserTapped(_ sender: Any) {
        print("List tapped")
        do {
            let users = try self.database.prepare(self.usersTable)
            for user in users {
                print(user.get(self.id))
                print(user.get(self.name))
                print(user.get(self.email))
            }
        } catch {
            print(error)
        }
    }
    
    @IBAction func updateUserTapped(_ sender: Any) {
        print("UPDATE TAPPED")
        let alert = UIAlertController(title: "Update User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "User ID"
        }
        alert.addTextField { (tf) in
            tf.placeholder = "email"
        }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let userIDString = alert.textFields?.first?.text,
                let userId = Int(userIDString),
                let email = alert.textFields?.last?.text else { return }
            print(userId)
            print(email)
            do {
                let user = self.usersTable.filter(self.id == userId)
                let updateUser = user.update(self.email <- email)
                try self.database.run(updateUser)
            } catch {
                print(error)
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteUserTapped(_ sender: Any) {
        print("DELETE TAPPED")
        let alert = UIAlertController(title: "DELETE User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in
            tf.placeholder = "User ID"
        }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let userIDString = alert.textFields?.first?.text,
            let userID = Int(userIDString) else { return }
            print(userID)
            
            let user = self.usersTable.filter(self.id == userID)
            let deletedUser = user.delete()
            do {
                try self.database.run(deletedUser)
            } catch {
                print(error)
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

