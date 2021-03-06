import XCTest
import LogicKit
@testable import minotaur

struct Wrapper : Equatable, CustomStringConvertible
{
  let term : Term

  var description: String
  {
      return "\(self.term)"
  }

  static func ==(lhs: Wrapper, rhs: Wrapper) -> Bool
  {
    return (lhs.term).equals (rhs.term)
  }

}

func resultsOf (goal: Goal, variables: [Variable]) -> [[Variable: Wrapper]]
{
    var result = [[Variable: Wrapper]] ()
    for s in solve (goal)
    {
        let solution  = s.reified ()
        var subresult = [Variable: Wrapper] ()
        for v in variables
        {
            subresult [v] = Wrapper (term: solution [v])
        }
        if !result.contains (where: { x in x == subresult })
        {
            result.append (subresult)
        }
    }
    return result
}

class minotaurTests: XCTestCase
{

    func testExemple()
    {
        print("\n ======================================== Test ======================================== \n")

        let r = Variable(named: "r")
        let s = Variable(named: "s")
        let t = Variable(named: "t")

        for solution in solve (doors(from: r, to: s))
        {
            print("* There is a door from \(solution[r]) to \(solution[s])")
        }

        print("")
        for solution in solve (entrance(location: r))
        {
            print("* There is an entrance at \(solution[r])")
        }

        print("")
        for solution in solve (exit(location: r))
        {
            print("* There is an exit at \(solution[r])")
        }

        print("")
        for solution in solve (minotaur(location: r))
        {
            print("* There is a Minotaur at \(solution[r])")
        }

        print("")
        var i : Int = 0
        for solution in solve (path(from: r, to: s, through: t) && entrance(location: r) && exit(location: s))
        {
            print("* There is a path form \(solution[r]) to \(solution[s]) through \(solution[t])")
            i += 1
        }
        print("* There are \(i) paths")

        print("")
        for solution in solve (path(from: room(4, 4), to: room(3, 2), through: t) && battery(through: t, level: toNat(7)))
        {
            print("* There is enough battery in the path form room(4, 4) to room(3, 2) through \(solution[t])")
        }

        print("")
        for solution in solve (path(from: room(4, 4), to: room(3, 2), through: t) && minotaurInPath(through: t))
        {
            print("* There is a minotaur in the path form room(4, 4) to room(3, 2) through \(solution[t])")
        }

        print("")
        for solution in solve (path(from: r, to: s, through: t) && winning(through: t, level: toNat(7)))
        {
            print("* You win if you start from \(solution[r]) to \(solution[s]) through \(solution[t]) with 7 battery charges")
        }

        print("\n ======================================== Test ======================================== \n")
    }

    func testDoors()
    {
        let from = Variable (named: "from")
        let to   = Variable (named: "to")
        let goal = doors (from: from, to: to)
        XCTAssertEqual(resultsOf (goal: goal, variables: [from, to]).count, 18, "number of doors is incorrect")
    }

    func testEntrance()
    {
        let location = Variable (named: "location")
        let goal     = entrance (location: location)
        XCTAssertEqual(resultsOf (goal: goal, variables: [location]).count, 2, "number of entrances is incorrect")
    }

    func testExit()
    {
        let location = Variable (named: "location")
        let goal     = exit (location: location)
        XCTAssertEqual(resultsOf (goal: goal, variables: [location]).count, 2, "number of exits is incorrect")
    }

    func testMinotaur()
    {
        let location = Variable (named: "location")
        let goal     = minotaur (location: location)
        XCTAssertEqual(resultsOf (goal: goal, variables: [location]).count, 1, "number of minotaurs is incorrect")
    }

    func testPath()
    {
        let through = Variable (named: "through")
        let goal    = path (from: room (4,4), to: room (3,2), through: through)
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 2, "number of paths is incorrect")
    }

    func testBattery()
    {
        let through = Variable (named: "through")
        let goal    = path (from: room (4,4), to: room (3,2), through: through) &&
                      battery (through: through, level: toNat (7))
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 1, "number of paths is incorrect")
    }

    func testLosing()
    {
        let through = Variable (named: "through")
        let goal    = winning (through: through, level: toNat (6))
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 0, "number of paths is incorrect")
    }

    func testWinning()
    {
        let through = Variable (named: "through")
        let goal    = winning (through: through, level: toNat (7))
        XCTAssertEqual(resultsOf (goal: goal, variables: [through]).count, 1, "number of paths is incorrect")
    }


    static var allTests : [(String, (minotaurTests) -> () throws -> Void)]
    {
        return [
            ("testExemple", testExemple),
            ("testDoors", testDoors),
            ("testEntrance", testEntrance),
            ("testExit", testExit),
            ("testMinotaur", testMinotaur),
            ("testPath", testPath),
            ("testBattery", testBattery),
            ("testLosing", testLosing),
            ("testWinning", testWinning)
        ]
    }
}
