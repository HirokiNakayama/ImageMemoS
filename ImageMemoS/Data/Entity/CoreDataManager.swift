//
//  CoreDataManager.swift
//  ImageMemoS
//
//  Created by 中山浩樹 on 2018/01/01.
//  Copyright © 2018年 中山浩樹. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    
    /**
     * Core Data 登録
     */
    public static func save(fileName: String, memo: String) {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        
        do {
            let results = try managedObjectContext.fetch(createFetchRequest(fileName: fileName))
            for managedObject in results {
                managedObjectContext.delete(managedObject as! PhotoEntity);
            }
        } catch {
            
        }
        
        let managedObject = NSEntityDescription.insertNewObject(
            forEntityName: "Entity", into: managedObjectContext)
        
        let model = managedObject as! PhotoEntity
        model.fileName = fileName
        model.memo = memo

        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    /**
     * メモデータ取得
     */
    public static func getMemo(fileName: String) -> String {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        
        do {
            let results = try managedObjectContext.fetch(createFetchRequest(fileName: fileName))
            for managedObject in results {
                return (managedObject as! PhotoEntity).memo!;
            }
        } catch {
            
        }
        return ""
    }
    
    /**
     * fetchRequest 生成
     */
    private static func createFetchRequest(fileName: String) -> NSFetchRequest<NSFetchRequestResult> {
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer.viewContext
        
        let entityDiscription = NSEntityDescription.entity(forEntityName: "Entity", in: managedObjectContext);
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>();
        fetchRequest.entity = entityDiscription;
        
        let predicate = NSPredicate(format: "fileName = %@", fileName)
        fetchRequest.predicate = predicate
        
        return fetchRequest
    }
}
