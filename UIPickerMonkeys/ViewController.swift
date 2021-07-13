//
//  ViewController.swift
//  UIPickerMonkeys
//
//  Created by Никита Ничепорук on 6/22/21.
//  Copyright © 2021 Никита Ничепорук. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var monkeysTable: UITableView!
    var monkeysList: Array<String> = []
    let picker = UIPickerView()
    var secVC: ImageViewController?
    
    let imageListMonkeys = ["https://givotniymir.ru/wp-content/uploads/2016/11/kapucin-obezyana-obraz-zhizni-i-sreda-obitaniya-obezyany-kapucin-7.jpg", "https://news.online.ua/proxy/news/r2-049315276a/280_5ad0afb902822.jpg", "https://upload.wikimedia.org/wikipedia/commons/d/de/Papio_cynocephalus02.jpg", "https://cdnimg.rg.ru/img/content/203/95/58/chimpanzee-3707270_1280_d_850.jpg", "https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Cebus_albifrons_edit.jpg/275px-Cebus_albifrons_edit.jpg", "https://static.wikia.nocookie.net/madagascar/images/a/ad/Julien-character-web-desktop.png/revision/latest/scale-to-width-down/250?cb=20210107113956&path-prefix=ru"]
    
    func toolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        let done = UIBarButtonItem(title: "Done",
                                   style: .done,
                                   target: self,
                                   action: #selector(selectItem))
        toolbar.setItems([done], animated: false)
        return toolbar
    }
    
    @objc func selectItem() {
        textFieldMonkeys.text =  "\(picker.selectedRow(inComponent: 0) + 1) " + monkeysList[picker.selectedRow(inComponent: 1)] //.0
        textFieldMonkeys.resignFirstResponder()
    }
    
    @IBOutlet weak var textFieldMonkeys: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        monkeysList = Parser.parseNamesFromJSON()?.list ?? []
        picker.delegate = self
        picker.dataSource = self
        textFieldMonkeys.inputView = picker
        textFieldMonkeys.inputAccessoryView = toolBar()
        monkeysTable.delegate = self
        monkeysTable.dataSource = self
        
        secVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "secVC") as? ImageViewController
    }
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 10
        case 1:
            return monkeysList.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row + 1)"
        case 1:
            return monkeysList[row]//.0
        default:
            return ""
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monkeysList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentName = monkeysList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = currentName
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = secVC else {return}
        _ = vc.view
        DispatchQueue.global(qos: .background).async {
            if let imageUrl = URL(string: self.imageListMonkeys[indexPath.row]),
                let imageData = try? Data(contentsOf: imageUrl) {
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    if image == nil {
                        let alert = UIAlertController(title: "Error",
                                                      message: "Picture not found",
                                                      preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK",
                                               style: .default,
                                               handler: nil)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        vc.imageView.image = image
                        self.navigationController?.show(vc, sender: nil)
                    }
                }
            }
            
        }
    }
    
}
