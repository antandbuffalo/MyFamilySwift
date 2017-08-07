//
//  ViewController.swift
//  MyFamily
//
//  Created by iNET Admin on 2/8/17.
//  Copyright © 2017 AntAndBuffalo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    var members: [Members] = [];
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath);
        
        cell.textLabel?.text = members[indexPath.row].mName;
        
        return cell;
    }
    
    func fetchData() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate);
        let context = appDelegate.persistentContainer.viewContext;

        do {
            members = try context.fetch(Members.fetchRequest())
        } catch {
            print("Fetching Failed")
        }
        print(members);
    }
    
    func deleteAllData() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate);
        let context = appDelegate.persistentContainer.viewContext;
        
        do {
            members = try context.fetch(Members.fetchRequest());
            members.removeAll(keepingCapacity: false);
            var couples = try context.fetch(Couples.fetchRequest());
            couples.removeAll(keepingCapacity: false);
            
        } catch {
            print("Fetching Failed")
        }
    }
    
    func insertData() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate);
        let context = appDelegate.persistentContainer.viewContext;
        
        if let path = Bundle.main.path(forResource: "myFamilyData", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            // use swift dictionary as normal
            print(dict);
            
            //loading members table
            if let innerArray:Array<AnyObject> = dict["Members"] as? Array {
                //print(innerArray);
                for item in innerArray {
                    let member = Members(context: context);
                    
                    print(item["mName"]);
                    //name = item["name"]
                    if let mName = item["mName"] as? String {
                        member.mName = mName;
                    }
                    if let coupleId = item["coupleId"] as? Int {
                        member.coupleId = Int16(coupleId);
                    }
                    if let isDied = item["isDied"] as? Bool {
                        member.isDied = isDied;
                    }
                    if let mId = item["mId"] as? Int {
                        member.mId = Int16(mId);
                    }
                    appDelegate.saveContext();
                }
            }
            
            
            //loading couples table
            if let innerArray:Array<AnyObject> = dict["Couples"] as? Array {
                //print(innerArray);
                for item in innerArray {
                    let couple = Couples(context: context);
                    
                    if let coupleId = item["coupleId"] as? Int {
                        couple.coupleId = Int16(coupleId);
                    }
                    if let pId = item["coupleId"] as? Int {
                        couple.pId = Int16(pId);
                    }
                    if let husbandId = item["husbandId"] as? Int {
                        couple.husbandId = Int16(husbandId);
                    }
                    if let wifeId = item["wifeId"] as? Int {
                        couple.wifeId = Int16(wifeId);
                    }
                    appDelegate.saveContext();
                }
            }
        }
        else {
            print("something is null");
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self;
        tableView.dataSource = self;
        
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate);
        let context = appDelegate.persistentContainer.viewContext;
        let member = Members(context: context);
        member.mId = 101;
        member.coupleId = 0;
        member.mName = "Sundharrajaiyar";
//        appDelegate.saveContext();
        
        insertData();
        fetchData();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

