//
//  AddGroupViewController.swift
//  UICollectionViewGroupingAndRanking
//
//  Created by 坂本龍哉 on 2022/02/27.
//

import UIKit

final class AddGroupViewController: UIViewController {
    
    private var createGroupHandler: ((Group) -> Void) = { _ in }
    
    @IBOutlet private weak var groupNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func didTapCreateGroupButton(_ sender: Any) {
        createGroupHandler(Group(id: UUID().uuidString,
                                 name: groupNameTextField.text ?? ""))
        dismiss(animated: true, completion: nil)
    }
    
    func makeGroup(createGroup: @escaping (Group) -> Void) {
        createGroupHandler = createGroup
    }
    
    static func instantiate() -> AddGroupViewController {
        guard let VC = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "AddGroupViewController")
                as? AddGroupViewController
        else { fatalError("AddGroupViewControllerが見つかりません。") }
        return VC
    }
    
}
