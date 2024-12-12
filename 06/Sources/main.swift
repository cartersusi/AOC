import Foundation

let InputFile: String = "Data/input"
let InputRaw: String = try String(contentsOfFile: InputFile, encoding: .utf8)
func sqsize(x: Int) -> Int {
    return Int((-1 + sqrt(Double(1 + 4 * x))) / 2)
}

enum Directions: Int {
    case up = 0
    case right, down, left, SizeDirections
}

struct Lab {
    var layout: [[Character]]
    let shape: (m: Int, n: Int)
    var _guard: (row: Int, col: Int, direction: Directions, has_escaped: Bool)

    mutating func FindGuard() {
        for i in 0...shape.m {
            for j in 0...shape.n {
                if layout[i][j] == "^" {
                    _guard.row = i
                    _guard.col = j
                    //print("Guard found at: \(i), \(j)");
                    return
                }
            }
        }

        print("Guard not found")
    }

    func ValidPosition() -> Bool {
        switch _guard.direction {
        case .left:
            if _guard.col - 1 <= shape.n && _guard.col - 1 >= 0 {
                return (layout[_guard.row][_guard.col - 1] != "#")
            }
        case .right:
            if _guard.col + 1 <= shape.n && _guard.col + 1 >= 0 {
                return (layout[_guard.row][_guard.col + 1] != "#")
            }
        case .down:
            if _guard.row + 1 <= shape.m && _guard.row + 1 >= 0 {
                return (layout[_guard.row + 1][_guard.col] != "#")
            }
        case .up:
            if _guard.row - 1 <= shape.m && _guard.row - 1 >= 0 {
                return (layout[_guard.row - 1][_guard.col] != "#")
            }
        default:
            print("Invalid direction")
            return false
        }

        return false
    }

    mutating func ChangeDirection() {
        _guard.direction =
            Directions(
                rawValue: (_guard.direction.rawValue + 1) % Directions.SizeDirections.rawValue)
            ?? .up  // wtf
    }

    mutating func MarkVisited() {
        layout[_guard.row][_guard.col] = "X"
    }

    mutating func MarkGuard() {
        layout[_guard.row][_guard.col] = "^"
    }

    mutating func Move() {
        MarkVisited()

        switch _guard.direction {
        case .left:
            _guard.col -= 1
        case .right:
            _guard.col += 1
        case .down:
            _guard.row += 1
        case .up:
            _guard.row -= 1
        default:
            print("Invalid direction")
            break
        }

        MarkGuard()
    }

    func FoundExit() -> Bool {
        switch _guard.direction {
        case .up:
            return (_guard.row == 0)
        case .right:
            return (_guard.col == shape.n)
        case .down:
            return (_guard.row == shape.m)
        case .left:
            return (_guard.col == 0)
        default:
            print("Error encountered in FoundExit()")
            return false
        }
    }

    func DisplayLab() {
        for i in 0...shape.m {
            for j in 0...shape.n {
                print(layout[i][j], terminator: " ")
            }
            print()
        }
    }

    func CountVisited() -> Int {
        return layout.flatMap { $0 }.filter { $0 == "X" }.count
    }

    mutating func GetOut() {
        var LIMIT: Int = 0

        while !_guard.has_escaped && (LIMIT < ((shape.m * shape.n) + shape.n)) {
            if ValidPosition() {
                Move()
            } else {
                ChangeDirection()
            }

            _guard.has_escaped = FoundExit()
            LIMIT += 1
        }
    }
}

let M: Int = sqsize(x: InputRaw.count + 1) - 1
/* Part 1
var lab = Lab(
    layout: InputRaw.split(separator: "\n").map { Array($0) },
    shape: (m: M, n: M),
    _guard: (row: 0, col: 0, direction: .up, has_escaped: false)
)
lab.FindGuard()
lab.GetOut()
print("The guard visited \(lab.CountVisited() + 1) positions")
*/

/* Part 2 */
var part2: Int = 0
for i in 0...M {
    for j in 0...M {
        var lab = Lab(
            layout: InputRaw.split(separator: "\n").map { Array($0) },
            shape: (m: M, n: M),
            _guard: (row: 0, col: 0, direction: .up, has_escaped: false)
        )

        lab.layout[i][j] = "#"
        lab.FindGuard()

        lab.GetOut()
        if !lab._guard.has_escaped {
            part2 += 1
        }
    }
}

print("\(part2) Guards did not escape")
