//
//  StateMachineTests.swift
//  StateMachineTests
//
//  Created by Mario Barbosa on 8/4/14.
//  Copyright (c) 2014 Mario Barbosa. All rights reserved.
//

import UIKit
import XCTest


enum StateEnum: CustomStringConvertible {
    
    case Initial
    case Open
    case OpenHalf
    case OpenCompletely
    case Close
    case CloseLocked
    case CloseUnlocked
    
    var description:String {
        switch self {
        case .Initial:
            return "Initial"
        case .OpenHalf:
            return "Open"
        default:
            return "Lala"
        }
    }
}


class StateMachineTests: XCTestCase {
    
    var stateMachine:StateMachine<StateEnum>!
    
    override func setUp() {
        super.setUp()
        
        stateMachine = StateMachine<StateEnum>()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSetInitialState() {
        var passed = false
        
        stateMachine.addState(state: StateEnum.Initial, onEnter: { (from, to, current) -> Void in
            passed = true
        })
        
        stateMachine.setInitialState(state: StateEnum.Initial)
        
        XCTAssertEqual(self.stateMachine.state, StateEnum.Initial, "State Not Initialized properly")
        XCTAssert(passed, "onEnter callback not called")
    }
    
    func testChangeState() {
        var passedOnEnter = false
        var passedOnExit = false
        var passedOnTransaction = false
        
        stateMachine.addState(state: StateEnum.Initial, onExit: { (from, to, current) -> Void in
            passedOnExit = true
        })
        stateMachine.addState(state: StateEnum.Open, fromStates: [StateEnum.Initial],
            onEnter: { (from, to, current) -> Void in
            passedOnEnter = true
        })
        
        stateMachine.setInitialState(state: StateEnum.Initial)
        
        stateMachine.onStateChangeSucceeded = { (from, to, current) -> Void in
            passedOnTransaction = true
        }
        
        stateMachine.gotoState(state: StateEnum.Open)
        
        XCTAssert(passedOnEnter && passedOnExit && passedOnTransaction, "State transaction Didn't worked")
    }
    
    func testCanChangeToState() {
        stateMachine.addState(state: StateEnum.Initial)
        stateMachine.addState(state: StateEnum.Open, fromStates:[StateEnum.Initial])
        stateMachine.addState(state: StateEnum.Close)
        stateMachine.setInitialState(state: StateEnum.Initial)
        
        XCTAssert(stateMachine.canChangeState(state: StateEnum.Open), "State change validation failed")
        XCTAssert(!stateMachine.canChangeState(state: StateEnum.Close), "State change validation failed")
    }
    
    func testParentState() {
        
        var checkpoint1 = false
        var checkpoint2 = false
        var checkpoint3 = false
        
        let onEnterOpenState:(_ from:StateEnum?, _ to:StateEnum, _ current:StateEnum)->Void = {(from, to, current) in
            checkpoint1 = true
        }
        
        let onEnterOpenCompletelyState:(StateEnum?, StateEnum, StateEnum)->Void = {(from, to, current) in
            checkpoint2 = true
        }
        
        let onEnterOpenHalfState:(StateEnum?, StateEnum, StateEnum)->Void = {(from, to, current) in
            checkpoint3 = true
        }
        
        stateMachine.addState(state: StateEnum.Initial)
        stateMachine.addState(state: StateEnum.Open, onEnter:onEnterOpenState)
        stateMachine.addState(state: StateEnum.OpenCompletely, fromStates:[StateEnum.Initial], parent:StateEnum.Open, onEnter:onEnterOpenCompletelyState)
        stateMachine.addState(state: StateEnum.OpenHalf, fromStates:[StateEnum.Initial], parent:StateEnum.Open, onEnter:onEnterOpenHalfState)
        stateMachine.setInitialState(state: StateEnum.Initial)
        
        stateMachine.gotoState(state: StateEnum.OpenCompletely)
        
        XCTAssert(checkpoint1 && checkpoint2 && !checkpoint3, "Change of state with hierarchy failed")
    }
    
    func testParentState2() {
        var checkpoint1 = false
        var checkpoint2 = false
        var checkpoint3 = false
        
        let onEnterOpenState:(StateEnum?, StateEnum, StateEnum)->Void = {(from, to, current) in
            checkpoint1 = true
        }
        
        let onEnterOpenCompletelyState:(StateEnum?, StateEnum, StateEnum)->Void = {(from, to, current) in
            checkpoint2 = true
        }
        
        let onEnterOpenHalfState:(StateEnum?, StateEnum, StateEnum)->Void = {(from, to, current) in
            checkpoint3 = true
        }
        
        stateMachine.addState(state: StateEnum.Initial)
        stateMachine.addState(state: StateEnum.Open, fromStates:[StateEnum.Initial], onEnter:onEnterOpenState)
        stateMachine.addState(state: StateEnum.OpenCompletely, fromStates:[StateEnum.Initial], parent:StateEnum.Open, onEnter:onEnterOpenCompletelyState)
        stateMachine.addState(state: StateEnum.OpenHalf, fromStates:[StateEnum.Initial], parent:StateEnum.Open, onEnter:onEnterOpenHalfState)
        stateMachine.setInitialState(state: StateEnum.Initial)
        
        stateMachine.gotoState(state: StateEnum.Open)
        
        XCTAssert(checkpoint1 && !checkpoint2 && !checkpoint3, "Change of state with hierarchy failed")
    }
}
