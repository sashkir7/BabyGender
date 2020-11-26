//
//  Stack.swift
//  BabyGenderPlanning
//
//  Created by Nikita Velichkin on 09/04/2020.
//  Copyright © 2020 BytePace. All rights reserved.
//

public struct Stack<T> {
    private var array = [T]()

    var isEmpty: Bool {
        return array.isEmpty
    }

    var count: Int {
        return array.count
    }

    mutating func push(_ element: T) {
        array.append(element)
    }

    @discardableResult
    mutating func pop() -> T? {
        return array.popLast()
    }

    var top: T? {
        return array.last
    }
}

extension Stack: Sequence {
  public func makeIterator() -> AnyIterator<T> {
    var curr = self
    return AnyIterator {
      return curr.pop()
    }
  }
}
