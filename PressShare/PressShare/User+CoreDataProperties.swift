//
//  User+CoreDataProperties.swift
//  PressShare
//
//  Created by MacbookPRV on 09/09/2016.
//  Copyright © 2016 Pastouret Roger. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var user_newpassword: NSNumber?
    @NSManaged var user_pays: String?
    @NSManaged var user_ville: String?
    @NSManaged var user_codepostal: String?
    @NSManaged var user_adresse: String?
    @NSManaged var user_prenom: String?
    @NSManaged var user_nom: String?
    @NSManaged var user_level: NSNumber?
    @NSManaged var user_date: NSDate?
    @NSManaged var user_email: String?
    @NSManaged var user_pass: String?
    @NSManaged var user_pseudo: String?
    @NSManaged var user_id: NSNumber?

}
