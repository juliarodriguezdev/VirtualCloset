//
//  User.swift
//  VirtualCloset
//
//  Created by Julia Rodriguez on 7/29/19.
//  Copyright © 2019 Julia Rodriguez. All rights reserved.
//

import Foundation
import CloudKit

class User {
    
    // properties
    let closetName: String
    let email: String
    let password: String
    let verifyPassword: String
    let gender: String
    
    // cloudKit Properties
    var ckRecordID: CKRecord.ID?
    let appleUserReference: CKRecord.Reference
    
    // memberwise init
    init(closetName: String, email: String, password: String, verifyPassword: String, gender: String, appleUserReference: CKRecord.Reference) {
        self.closetName = closetName
        self.email = email
        self.password = password
        self.verifyPassword = verifyPassword
        self.appleUserReference = appleUserReference
        self.gender = gender
    }
    
    // failable init
    init?(ckRecord: CKRecord) {
        // ckRecord is formatted as a dictionary
        guard let closetName = ckRecord[UserKeys.closetNameKey] as? String,
            let email = ckRecord[UserKeys.emailKey] as? String,
            let password = ckRecord[UserKeys.passwordKey] as? String,
            let verifyPassword = ckRecord[UserKeys.verifyPasswordKey] as? String,
            let gender = ckRecord[UserKeys.genderKey] as? String,
            let appleUserReference = ckRecord[UserKeys.appleUserReferenceKey] as? CKRecord.Reference else { return nil }
        
        self.closetName = closetName
        self.email = email
        self.password = password
        self.verifyPassword = verifyPassword
        self.gender = gender
        self.appleUserReference = appleUserReference
        self.ckRecordID = ckRecord.recordID
    }
}
extension CKRecord {
    
    convenience init(user: User) {
        // if there exists a record assign it else create a new recordID
        let recordID = user.ckRecordID ?? CKRecord.ID(recordName: UUID().uuidString)
        
        // designated initializer
        self.init(recordType: UserKeys.userKey, recordID: recordID)
        
        // set key: value pairs
        self.setValue(user.closetName, forKey: UserKeys.closetNameKey)
        self.setValue(user.email, forKey: UserKeys.emailKey)
        self.setValue(user.password, forKey: UserKeys.passwordKey)
        self.setValue(user.verifyPassword, forKey: UserKeys.verifyPasswordKey)
        self.setValue(user.appleUserReference, forKey: UserKeys.appleUserReferenceKey)
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email
        && lhs.password == rhs.password
        && lhs.verifyPassword == rhs.verifyPassword
    }
    
    
}

struct UserKeys {
    
    static let userKey = "User"
    static let closetNameKey = "closetName"
    static let emailKey = "email"
    static let passwordKey = "password"
    static let verifyPasswordKey = "verifyPassword"
    static let genderKey = "gender"
    static let appleUserReferenceKey = "appleUserReference"
}
