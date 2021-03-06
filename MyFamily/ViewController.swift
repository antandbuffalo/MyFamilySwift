//
//  ViewController.swift
//  MyFamily
//
//  Created by iNET Admin on 2/8/17.
//  Copyright © 2017 AntAndBuffalo. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    var members: [Members] = [];
    var couples: [Couples] = [];
    var displayData: [Dictionary<String, String>] = [];
    var parentId : [Int] = [];
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        if parentId.count > 0 {
            fetchProperData(pid: parentId.popLast()!);
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayData.count;
        //return members.count;
        //return couples.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath);
        
        let label: UILabel = cell.viewWithTag(101) as! UILabel;
        label.text = displayData[indexPath.row]["title"];
        
        //cell.textLabel?.text = displayData[indexPath.row]["title"];
        
        //cell.textLabel?.text = members[indexPath.row].mName;
        
        //cell.textLabel?.text = String(couples[indexPath.row].coupleId);
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(displayData[indexPath.row]);
        if let pid = displayData[indexPath.row]["coupleId"] {
            if Int(pid) != 0 {
                parentId.append(Int(displayData[indexPath.row]["parentId"]!)!);
                fetchProperData(pid: Int(pid)!);
            }
        }
    }
    
    func fetchProperData(pid: Int) {
        
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate);
        let context = appDelegate.persistentContainer.viewContext;
        
        let parentPredicate = NSPredicate(format: "%K = %d", "pId", pid);
        let fetchRequest: NSFetchRequest = Couples.fetchRequest();
        fetchRequest.predicate = parentPredicate;
        
        displayData.removeAll();
        
        do {
            let couples = try context.fetch(fetchRequest)
            //print(couples)
            for couple in couples {
                
                let memberPredicate = NSPredicate(format: "%K = %d", "coupleId", couple.cId);
                let fetchMembers: NSFetchRequest = Members.fetchRequest();
                fetchMembers.predicate = memberPredicate;
                
                let husWife = try context.fetch(fetchMembers);
                
                var dic = ["title" : "", "coupleId": ""];
                dic["coupleId"] = String(couple.cId);
                //dic["parentId"] = String(couple.pId);
                
                for mem in husWife {
                    
                    dic["title"] = dic["title"]! + " " + mem.mName!;
                }
                displayData.append(dic);
                print(displayData);
            }
            
            
        } catch {
            
        }
        tableView.reloadData();
        if parentId.count > 0 {
            backButton.isHidden = false;
        }
        else {
            backButton.isHidden = true;
        }
    };
    
    func fetchData() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate);
        let context = appDelegate.persistentContainer.viewContext;

        do {
            members = try context.fetch(Members.fetchRequest())
            couples = try context.fetch(Couples.fetchRequest())
        } catch {
            print("Fetching Failed")
        }
        print(members);
    }
    
    func deleteAllData() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate);
        let context = appDelegate.persistentContainer.viewContext;
        
        let fetchMembers = NSFetchRequest<NSFetchRequestResult>(entityName: "Members")
        let requestMembers = NSBatchDeleteRequest(fetchRequest: fetchMembers)
        
        let fetchCouples = NSFetchRequest<NSFetchRequestResult>(entityName: "Couples")
        let requestCouples = NSBatchDeleteRequest(fetchRequest: fetchCouples)

        
        do {
            try context.execute(requestMembers)
            try context.execute(requestCouples)
            
            try context.save()
        } catch {
            print ("There was an error")
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
                    if let mId = item["mId"] as? Int {
                        member.mId = Int16(mId);
                    }
                    if let mName = item["mName"] as? String {
                        member.mName = mName;
                    }
//                    if let coupleId = item["coupleId"] as? Int {
//                        member.parentId = Int16(coupleId);
//                    }
//                    if let isDied = item["isDied"] as? Bool {
//                        member.isDied = isDied;
//                    }
                    appDelegate.saveContext();
                }
            }
            
            
            //loading couples table
            if let innerArray:Array<AnyObject> = dict["Couples"] as? Array {
                print(innerArray);
                for item in innerArray {
                    let couple = Couples(context: context);
                    
                    if let coupleId = item["coupleId"] as? Int {
                        couple.cId = Int16(coupleId);
                    }
//                    if let pId = item["pId"] as? Int {
//                        couple.pId = Int16(pId);
//                    }
                    if let husbandId = item["husbandId"] as? Int {
                        couple.husbandId = Int16(husbandId);
                    }
                    if let wifeId = item["wifeId"] as? Int {
                        couple.wifeId = Int16(wifeId);
                    }
                    
                    //Linking the relationship
                    let parentPredicate = NSPredicate(format: "%K = %d", "mId", item["husbandId"] as! Int);
                    let fetchRequest: NSFetchRequest = Members.fetchRequest();
                    fetchRequest.predicate = parentPredicate;
                    do {
                        let member = try context.fetch(fetchRequest)
                        if member.count == 1 {
                            member[0].parent = couple;
                        }
                    }
                    catch {
                        print("Some error during relationship linking");
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
        
        deleteAllData();
        insertData();
        //fetchData();
        fetchProperData(pid: 0);
        
        //fetchProperData(pid: 1001);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

