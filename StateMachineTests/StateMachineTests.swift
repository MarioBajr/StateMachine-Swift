//
//  StateMachineTests.swift
//  StateMachineTests
//
//  Created by Mario Barbosa on 8/4/14.
//  Copyright (c) 2014 Mario Barbosa. All rights reserved.
//

import UIKit
import XCTest


enum StateEnum {
    case Initial
    case Open
    case OpenHalf
    case OpenCompletely
    case Close
    case CloseLocked
    case CloseUnlocked
}


class StateMachineTests: XCTestCase {
    
    var stateMachine:StateMachine<StateEnum>!
    
    override func setUp() {
        super.setUp()
        
        self.stateMachine = StateMachine<StateEnum>()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetInitialState(){
        var passed = false
        
        self.stateMachine.addState(StateEnum.Initial, onEnter: { (from, to, current) -> Void in
            passed = true
        })
        
        self.stateMachine.setInitialState(StateEnum.Initial)
        
        XCTAssertEqual(self.stateMachine.state, StateEnum.Initial, "State Not Initialized properly")
        XCTAssert(passed, "onEnter callback not called")
    }
    
    func testParentState(){
    
    }
}
