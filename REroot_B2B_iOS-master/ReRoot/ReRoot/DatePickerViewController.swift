//
//  DatePickerViewController.swift
//  ReRoot
//
//  Created by Dhanunjay on 16/08/18.
//  Copyright © 2018 ReRoot. All rights reserved.
//

import UIKit
protocol DateSelectedFromPicker: class {
    func didSelectDate(optionType : Date,optionIndex: Int)
}

class DatePickerViewController: UIViewController {

    var selectedFieldTag : Int!
    @IBOutlet var datePicker: UIDatePicker!
    weak var delegate:DateSelectedFromPicker?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        datePicker.minimumDate = Date()
    }

    @IBAction func cancel(_ sender: Any) {
        self.delegate?.didSelectDate(optionType: datePicker.date, optionIndex: selectedFieldTag)

    }
    @IBAction func dateSelected(_ sender: Any) {
        print(datePicker.date)
        self.delegate?.didSelectDate(optionType: datePicker.date, optionIndex: selectedFieldTag)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
