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
extension DateSelectedFromPicker{
    func didSelectDate(optionType : Date,optionIndex: Int){
    }
}

class DatePickerViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var datePickerInfoView: UIView!
    @IBOutlet weak var datePickerInfoLabel: UILabel!
    var selectedFieldTag : Int!
    @IBOutlet weak var datePicker: UIDatePicker!
    weak var delegate:DateSelectedFromPicker?
    var shouldSetDateLimit : Bool = false
    var shouldShowTime : Bool = false
    var selectedDate : Date!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if(shouldSetDateLimit){
            datePicker.maximumDate = Date()
        }
    }

    @IBAction func cancel(_ sender: Any) {
        self.delegate?.didSelectDate(optionType: datePicker.date, optionIndex: -1)
    }
    @IBAction func dateSelected(_ sender: Any) {
        if(shouldShowTime && datePicker.datePickerMode == .date){
            selectedDate = self.datePicker.date
            self.datePicker.datePickerMode = .time
            return
        }
        if(shouldShowTime){
            var dayComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: datePicker.date)
            dayComponents.hour = timeComponents.hour
            dayComponents.minute = timeComponents.minute
            guard let date = Calendar.current.date(from: dayComponents) else { return  }
            self.delegate?.didSelectDate(optionType: date, optionIndex: selectedFieldTag)
            return
        }
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
