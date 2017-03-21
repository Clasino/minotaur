/*
 ==============================================================================
                                Nicolas Cotte
                                    TP 2
 ==============================================================================
*/

import LogicKit

/*
 ==============================================================================
                    Enumerations and structures declarations
 ==============================================================================
*/

let zero = Value (0)

struct Position : Equatable, CustomStringConvertible
{
    let x : Int
    let y : Int

    var description: String
    {
        return "\(self.x):\(self.y)"
    }

    static func ==(lhs: Position, rhs: Position) -> Bool
    {
      return lhs.x == rhs.x && lhs.y == rhs.y
    }

}

/*
 ==============================================================================
                            Functions declarations
 ==============================================================================
*/

func succ (_ of: Term) -> Map
{
    return ["succ": of]
}

func toNat (_ n: Int) -> Term
{
    var result : Term = zero
    for _ in 1...n
    {
        result = succ (result)
    }
    return result
}

func isNat (_ n: Term) -> Goal
{
    return (n === zero) ||
        delayed(fresh
            {
                x in
                (
                    (n === succ(x)) &&
                    isNat(x)
                )
            }
        )
}

// rooms are numbered:
// x:1,y:1 ... x:n,y:1
// ...             ...
// x:1,y:m ... x:n,y:m
func room (_ x: Int, _ y: Int) -> Term
{
    return Value (Position (x: x, y: y))
}

func isRoom (location: Term) -> Goal
{
    return (location === room(1, 1)) ||
           (location === room(1, 2)) ||
           (location === room(1, 3)) ||
           (location === room(1, 4)) ||
           (location === room(2, 1)) ||
           (location === room(2, 2)) ||
           (location === room(2, 3)) ||
           (location === room(2, 4)) ||
           (location === room(3, 1)) ||
           (location === room(3, 2)) ||
           (location === room(3, 3)) ||
           (location === room(3, 4)) ||
           (location === room(4, 1)) ||
           (location === room(4, 2)) ||
           (location === room(4, 3)) ||
           (location === room(4, 4))
}

func doors (from: Term, to: Term) -> Goal
{
    return ((from === room(1, 2)) && (to === room(1, 1))) ||
           ((from === room(1, 2)) && (to === room(2, 2))) ||

           ((from === room(1, 3)) && (to === room(1, 2))) ||

           ((from === room(1, 4)) && (to === room(1, 3))) ||


           ((from === room(2, 1)) && (to === room(1, 1))) ||

           ((from === room(2, 2)) && (to === room(3, 2))) ||

           ((from === room(2, 3)) && (to === room(1, 3))) ||
           ((from === room(2, 3)) && (to === room(2, 2))) ||

           ((from === room(2, 4)) && (to === room(2, 3))) ||


           ((from === room(3, 1)) && (to === room(2, 1))) ||

           ((from === room(3, 2)) && (to === room(3, 3))) ||
           ((from === room(3, 2)) && (to === room(4, 2))) ||

           ((from === room(3, 4)) && (to === room(2, 4))) ||
           ((from === room(3, 4)) && (to === room(3, 3))) ||


           ((from === room(4, 1)) && (to === room(3, 1))) ||

           ((from === room(4, 2)) && (to === room(4, 1))) ||
           ((from === room(4, 2)) && (to === room(4, 3))) ||

           ((from === room(4, 4)) && (to === room(3, 4)))
}

func entrance (location: Term) -> Goal
{
    return (location === room(1, 4)) ||
           (location === room(4, 4))
}

func exit (location: Term) -> Goal
{
    return (location === room(1, 1)) ||
           (location === room(4, 3))
}

func minotaur (location: Term) -> Goal
{
    return location === room(3, 2)
}

func path (from: Term, to: Term, through: Term) -> Goal
{
    return ((from === to) && (through === List.cons(from, List.empty))) ||
        delayed(fresh
            {
                first in fresh
                {
                    remainder in fresh
                    {
                        secondRemainder in
                        (
                            (through === List.cons(from, remainder)) &&
                            (remainder === List.cons(first, secondRemainder)) &&
                            doors(from: from, to: first) &&
                            path(from: first, to: to, through: remainder)
                        )
                    }
                }
            }
        )
}

func battery (through: Term, level: Term) -> Goal
{
    return ((through === List.empty) && isNat(level)) ||
        delayed(fresh
            {
                path in fresh
                {
                    first in fresh
                    {
                        nat in
                        (
                            (through === List.cons(first, path)) &&
                            (level === succ(nat)) &&
                            battery(through: path, level: nat)
                        )
                    }
                }
            }
        )
}

func minotaurInPath (through: Term) -> Goal
{
    return delayed(fresh
        {
            first in fresh
            {
                remainder in
                (
                    (through === List.cons(first, remainder)) &&
                    (minotaur(location: first) || minotaurInPath(through: remainder))
                )
            }
        }
    )
}

func winning (through: Term, level: Term) -> Goal
{
    return battery(through: through, level: level) &&
           minotaurInPath(through: through) &&
           fresh
           {
               first in fresh
               {
                   last in
                   (
                       entrance(location: first) &&
                       exit(location: last) &&
                       path(from: first, to: last, through: through)
                   )
               }
           }
}
