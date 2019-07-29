//
//  Closet.swift
//  VirtualCloset
//
//  Created by Julia Rodriguez on 7/29/19.
//  Copyright © 2019 Julia Rodriguez. All rights reserved.
//

import UIKit
import CloudKit

class Closet {
    
    // class properties
    let closetName: String
    let gender: String
    var clothingCategory: [String]
    var occasion: [String]
    var clothingInventory: Int
    var clothingLimit: Int
    var clothingImageData: Data?
    let ckRecordID: CKRecord.ID
    
    var clothingImage: UIImage? {
        get {
            // check if image data is available
            guard let clothingImageData = clothingImageData else { return nil }
            return UIImage(data: clothingImageData)
        }
        set {
            clothingImageData = newValue?.jpegData(compressionQuality: 0.5)
        }
    }
    
    var clothingImageAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirectoryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirectoryURL.appendingPathComponent(ckRecordID.recordName).appendingPathExtension("jpg")
            do {
                try clothingImageData?.write(to: fileURL)
            } catch let error {
                print("Error writing to temp url \(error) \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    // class initializers
    init(closetName: String, gender: String, clothingCategory: [String], occasion: [String], clothingInventory: Int, clothingLimit: Int, clothingImage: UIImage?, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        
        self.closetName = closetName
        self.gender = gender
        self.clothingCategory = clothingCategory
        self.occasion = occasion
        self.clothingInventory = clothingInventory
        self.clothingLimit = clothingLimit
        self.ckRecordID = ckRecordID
        self.clothingImage = clothingImage
        
    }
    
    // falliable initializer to pass in CKRecord
    convenience init?(record: CKRecord) {
        
        guard let closetName = record[ClosetConstants.ClosetNameKey] as? String,
            let gender = record[ClosetConstants.GenderKey] as? String,
            let clothingCategory = record[ClosetConstants.ClothingCategoryKey] as? [String],
            let occasion = record[ClosetConstants.OccasionKey] as? [String],
            let clothingInventory = record[ClosetConstants.ClothingInventoryKey] as? Int,
            let clothingLimit = record[ClosetConstants.ClothingLimitKey] as? Int,
            let clothingImageAsset = record[ClosetConstants.ClothingImageKey] as? CKAsset
            else { return nil }
        
        // convenience inits stay within the block, not related to class properties 
        var clothingImage: UIImage?
        
        if let clothingImageAssetFileURL = clothingImageAsset.fileURL {
            do {
                let clothingImageData = try Data(contentsOf: clothingImageAssetFileURL)
                clothingImage = UIImage(data: clothingImageData)
            } catch {
                print("There was an error in \(#function) : \(error) \(error.localizedDescription)")
                return nil
            }
        }
        
        // set designated / class initializers
        self.init(closetName: closetName, gender: gender, clothingCategory: clothingCategory, occasion: occasion, clothingInventory: clothingInventory, clothingLimit: clothingLimit, clothingImage: clothingImage, ckRecordID: record.recordID)
        
    }
    
}

extension CKRecord {
    
    convenience init(closet: Closet) {
        self.init(recordType: ClosetConstants.RecordType, recordID: closet.ckRecordID)
        self.setValue(closet.closetName, forKey: ClosetConstants.ClosetNameKey)
        self.setValue(closet.gender, forKey: ClosetConstants.GenderKey)
        self.setValue(closet.clothingCategory, forKey: ClosetConstants.ClothingCategoryKey)
        self.setValue(closet.occasion, forKey: ClosetConstants.OccasionKey)
        self.setValue(closet.clothingInventory, forKey: ClosetConstants.ClothingInventoryKey)
        self.setValue(closet.clothingLimit, forKey: ClosetConstants.ClothingLimitKey)
        self.setValue(closet.clothingImage, forKey: ClosetConstants.ClothingImageKey)
        
    }
}
struct ClosetConstants {
    static let ClosetNameKey = "closetName"
    static let GenderKey = "gender"
    static let ClothingCategoryKey = "clothingCategory"
    static let OccasionKey = "occasion"
    static let ClothingInventoryKey = "clothingInventory"
    static let ClothingLimitKey = "clothingLimit"
    static let ClothingIconKey = "clothingIcon"
    static let ClothingImageKey = "clothingImage"
    static let RecordType = "Closet"
    
}
