//
//  StateMachine.swift
//  StateMachine
//
//  Created by Mario Barbosa on 8/4/14.
//  Copyright (c) 2014 Mario Barbosa. All rights reserved.
//

import Foundation

class StateMachine <T:Hashable> {
    
    typealias StateChangeHandler = (from:T?, to:T, current:T)->Void
    
    private var currentState:State<T>!
    private var states = [T:State<T>]()
    
    var onStateChangeSucceeded:StateChangeHandler?
    var onStateChangeFailed:StateChangeHandler?
    var state:T {
        return self.currentState.value
    }
    
    init(){
        
    }
    
    func setInitialState(state:T){
        let modelState:State<T>? = self.states[state]
        
        if (!self.currentState && self.states[state] != nil){
            self.currentState = self.states[state]
            if (self.currentState.root != nil) {
                let parents = self.currentState.parents
                for parent in parents{
                    parent.onEnterHandler?(from: nil, to: state, current: parent.value)
                }
            }
            
            self.currentState.onEnterHandler?(from: nil, to: state, current: state)
            self.onStateChangeSucceeded?(from: nil, to: state, current: self.currentState!.value)
        } else {
            println("[StateMachine] Error: Initial state already setted or state \(state) not found")
        }
    }
    
    func canChangeState(state:T)->Bool{
        if let modelState = states[state]{
            if !modelState.fromStates.isEmpty{
                if let strongState = self.currentState{
                    let isCurrentState = (state == strongState.value)
                    return !isCurrentState && contains(strongState.fromStates, state)
                }
            }
        }
        
        return false
    }
    
    func addState(state:T, fromStates:[T]? = nil,
        onEnter:(StateChangeHandler)? = nil,
        onExit:(StateChangeHandler)? = nil){
            var fromStatesList = [T]()
            if let strongFromStates = fromStates {
                fromStatesList = strongFromStates
            }
            
            let stateModel = State<T>(value:state, fromStates:fromStatesList)
            stateModel.onEnterHandler = onEnter
            stateModel.onExitHandler = onExit
            self.states[state] = stateModel
    }
    
    func gotoState(state:T){
        
        func findPathToState(from:T, to:T)->(Int, Int){
            var fromState = self.states[from]
            var c = 0, d = 0
            
            while let strongFromState = fromState {
                d = 0
                var toState = self.states[to]
                while let strongToState = toState {
                    if strongFromState.value == strongToState.value {
                        return (c, d)
                    }
                    d++
                    toState = strongToState.parent
                }
                c++
                fromState = strongFromState.parent
            }
            
            return (c, d)
        }
        
        let fromValue = self.currentState.value
        let toState = states[state]
        
        if let strongToState = toState {
            
            if (!canChangeState(state)) {
                self.onStateChangeFailed?(from: fromValue, to: state, current: fromValue)
                return
            }
            
            let (a, b) = findPathToState(self.currentState.value, state)
            
            if (a > 0) {
                self.currentState.onExitHandler?(from: fromValue, to: state, current: fromValue)
                
                var parentState = self.currentState
                for _ in 0..<a-1 {
                    parentState = parentState.parent
                    self.currentState.onExitHandler?(from: fromValue, to: state, current: parentState.value)
                }
            }
            
            let oldState = self.currentState!
            self.currentState = strongToState
            
            if (b > 0){
                if (strongToState.root != nil){
                    let parentStates = strongToState.parents
                    var i = b-2
                    while (i-- >= 0) {
                        let parentState = parentStates[i]
                        parentState.onEnterHandler?(from: fromValue, to: strongToState.value, current: parentState.value)
                    }
                }
                
                oldState.onEnterHandler?(from: fromValue, to: strongToState.value, current: strongToState.value)
            }
            
            self.onStateChangeSucceeded?(from: fromValue, to: strongToState.value, current: strongToState.value)
            
        } else {
            println("[StateMachine] Error: State \(state) not defined")
        }
    }
}

// MARK: State

private class State<T> {
    
    typealias StateChangeHandler = (from:T?, to:T, current:T)->Void
    
    weak var parent:State<T>? {
        didSet{
            self.parent!.children.append(self)
        }
    }
    
    var root:State<T>? {
        var parentState:State<T>? = self.parent
        while(parentState?.parent != nil){
            parentState = parentState?.parent
        }
        return parentState
    }
    
    var parents:[State<T>] {
        var list:[State<T>] = []
        var parentState = self.parent
        while(parentState != nil){
            list.append(parentState!)
            parentState = parentState?.parent
        }
        return list
    }
    
    var value:T
    var fromStates = [T]()
    var children = [State<T>]()
    var onEnterHandler:StateChangeHandler?
    var onExitHandler:StateChangeHandler?
    
    init(value:T, fromStates:[T]){
        self.value = value
        self.fromStates = fromStates
    }
}