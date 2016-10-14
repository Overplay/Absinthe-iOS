//
//  EditAccountViewController.swift
//  Absinthe-iOS
//
//  Created by Alyssa Torres on 10/14/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit

class EditAccountViewController: UIViewController {

    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBAction func closeEditAccount(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Should we get these values from somewhere else?
        // TODO: set first and last names in settings
        self.firstName.text = Settings.sharedInstance.userFirstName
        self.lastName.text = Settings.sharedInstance.userLastName
   
        self.email.text = Settings.sharedInstance.userEmail
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
