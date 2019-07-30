//
//  UserController.swift
//  VirtualCloset
//
//  Created by Julia Rodriguez on 7/29/19.
//  Copyright © 2019 Julia Rodriguez. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    // singleton: shared instance
    static let sharedInstance = UserController()
    
    // source of truth
    var currentUser: User? {
        didSet{
            DispatchQueue.main.async {
                // signal Notification
                NotificationCenter.default.post(name: .userCreated, object: nil)
            }
        }
    }
    // database the users live in
    let dataBase = CKContainer.default().privateCloudDatabase
    
    // MARK: - CRUD Functions
    
    // Create
    func createUserWith(closetName: String, email: String, password: String, verifyPassword: String, gender: String, completion: @escaping (_ success: Bool) -> Void) {
        
        // default users: that already exists within CloudKit
        CKContainer.default().fetchUserRecordID { (appleUserReferenceID, error) in
            if let error = error {
                print("error creating user: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let appleUserReferenceID = appleUserReferenceID else { completion(false) ; return }
            
            let appleUserReference = CKRecord.Reference(recordID: appleUserReferenceID, action: CKRecord_Reference_Action.deleteSelf)
            
            let user = User(closetName: closetName, email: email, password: password, verifyPassword: verifyPassword, gender: gender, appleUserReference: appleUserReference)
            let userRecord = CKRecord(user: user)
            
            self.dataBase.save(userRecord, completionHandler: { (record, error) in
                if let error = error {
                    print("there was an error saving user: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                // unwrap record
                guard let record = record else { completion(false) ; return }
                // unwrap user and init
                guard let user = User(ckRecord: record) else { return }
                // set currentUser to unwrapped user
                self.currentUser = user
                completion(true)
            })
        }
    }
    // Fetch user
    func fetchCurrentUser(completion: @escaping (_ success: Bool) -> Void) {
        
        CKContainer.default().fetchUserRecordID { (appleUserReferenceID, error) in
            // check for error
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // unwrap recordID and convert to reference
            guard let appleUserReferenceID = appleUserReferenceID else { return }
            let appleUserReference = CKRecord.Reference(recordID: appleUserReferenceID, action: .deleteSelf)
            
            // the return; references of the current user
            let predicate = NSPredicate(format: "appleUserReference == %@", appleUserReference)
            let query = CKQuery(recordType: "User", predicate: predicate)
            
            self.dataBase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
                if let error = error {
                    print("There was a database error \(error.localizedDescription)")
                    completion(false)
                    return
                }
                // optional chaining
                // unwrap array of records
                guard let records = records,
                    // get the first record
                      let firstRecords = records.first,
                    // create a new user from that first record
                    let currentUser = User(ckRecord: firstRecords) else { completion(false); return }
                
                // set the source of truth (self.currentUser) to a new object: currentUser
                self.currentUser = currentUser
                completion(true)
            })
        }
    }
}
