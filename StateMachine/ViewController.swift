//
//  ViewController.swift
//  StateMachine
//
//  Created by Mario Barbosa on 8/4/14.
//  Copyright (c) 2014 Mario Barbosa. All rights reserved.
//

import UIKit

enum StatesEnum:String {
    case InitialState="a",FinalState="b"
}


class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let stateMachine = StateMachine<StatesEnum>()
        stateMachine.addState(StatesEnum.FinalState,
            fromStates:[StatesEnum.InitialState, StatesEnum.FinalState])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

