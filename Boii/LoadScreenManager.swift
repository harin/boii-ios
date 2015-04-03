//
//  LoadScreenManager.swift
//  Boii
//
//  Created by Harin Sanghirun on 3/4/58.
//  Copyright (c) พ.ศ. 2558 Harin Sanghirun. All rights reserved.
//

import Foundation

/*
Purpose - to manage the loading screen for different processes.
Maintain a counter of asynchronouse activities that is fetching data.

Display loading animation until the count is 0
*/

private let _sharedInstance = LoadScreenManager()

class LoadScreenManager {
    //Singleton
    class var sharedInstance: LoadScreenManager {
        return _sharedInstance
    }
    
    
    
}