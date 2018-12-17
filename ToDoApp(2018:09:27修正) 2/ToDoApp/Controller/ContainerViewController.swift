//
//  ContainerViewController.swift
//  ToDoApp
//
//  Created by 土井　麻菜美 on 2018/08/22.
//  Copyright © 2018年 Manami. All rights reserved.
//

import UIKit
@objc protocol MyDelegate {
    func didTapTrashButton()
}

class ContainerViewController: UIViewController, ListDelegate,NewTodo{

    @IBOutlet weak var countTodo: UILabel!
    var tableViewController: TodoListTableViewController!
    var todoNum = 0
    var todoNumKey = "todoNum"
    weak static var delegate: MyDelegate? = nil
    var b:[Todo] = []
    //TodoCollectionクラスのインスタンスを定義
    let todoCollection = TodoCollection.sharedInstance
    let todoListController = TodoListTableViewController.sharedInstance
    override func viewDidLoad() {
       super.viewDidLoad()
      //todoNum = todoCollection.todos.count
        let defaults = UserDefaults.standard
       todoNum =  defaults.integer(forKey: todoNumKey)
        TodoListTableViewController.delegate = self
        NewTodoViewController.delegate = self
        if todoCollection.todos.isEmpty{
            countTodo.text = "ToDo \(todoCollection.todos.count)"
        }else{
            countTodo.text = "ToDos \(todoCollection.todos.count)"
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //新規作成画面を開く
    @IBAction func newTodo(_ sender: UIButton) {
        self.performSegue(withIdentifier: "PresentNewTodoViewController", sender: self)
    }
    @IBAction func deleteTodo(_ sender: UIButton) {
        ContainerViewController.delegate?.didTapTrashButton()
    }
    func todoCount(){
        if todoCollection.todos.isEmpty{
            countTodo.text = "ToDo \(todoCollection.todos.count)"
        }else{
            countTodo.text = "ToDos \(todoCollection.todos.count)"
        }
        save()
    }
    func save(){
        let defaults = UserDefaults.standard
        defaults.set(todoNum,forKey: todoNumKey)
        print(todoNum)
    }
}
