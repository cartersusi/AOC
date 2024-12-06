import Foundation

let InputFile: String = "Data/input";
let InputRaw: String = try String(contentsOfFile: InputFile, encoding: .utf8);
func size(x: Int) -> Int {
    return Int((-1 + sqrt(Double(1 + 4 * x))) / 2);
};

enum Directions: Int {
    case up = 0, right, down, left, SizeDirections;
}

struct Lab {
    var layout: [[Character]];
    let OUB: (m: Int, n: Int);
    var _guard: (row: Int, col: Int, direction: Directions);

    mutating func FindGuard()  {
        for i in 0...OUB.m {
            for j in 0...OUB.n {
                if layout[i][j] == "^" {
                    _guard.row = i;
                    _guard.col = j;
                    print("Guard found at: \(i), \(j)");
                    return
                }
            }
        }
        
        print("Guard not found");
    }

    func ValidPosition() -> Bool {
        switch _guard.direction {
        case .left:
            if _guard.col - 1 <= OUB.n && _guard.col - 1 >= 0 {
                return(layout[_guard.row][_guard.col - 1] != "#");
            }
        case .right:
            if _guard.col + 1 <= OUB.n && _guard.col + 1 >= 0 {
                return(layout[_guard.row][_guard.col + 1] != "#");
            }
        case .down:
            if _guard.row + 1 <= OUB.m && _guard.row + 1 >= 0 {
                return(layout[_guard.row + 1][_guard.col] != "#");
            }
        case .up:
            if _guard.row - 1 <= OUB.m && _guard.row - 1 >= 0 {
                return(layout[_guard.row - 1][_guard.col] != "#");
            }
        default:
            print("Invalid direction");
            return false;
        }

        return false;
    }

    mutating func ChangeDirection() {
        _guard.direction = Directions(rawValue: (_guard.direction.rawValue + 1) % Directions.SizeDirections.rawValue) ?? .up; // wtf
    }

    mutating func MarkVisited(){
        layout[_guard.row][_guard.col] = "X";
    }

    mutating func MarkGuard(){
        layout[_guard.row][_guard.col] = "^";
    }

    mutating func Move() {
        MarkVisited();
        
        switch _guard.direction {
        case .left:
            _guard.col -= 1;
        case .right:
            _guard.col += 1;
        case .down:
            _guard.row += 1;
        case .up:
            _guard.row -= 1;
        default:
            break;
        }

        MarkGuard();
    }

    func FoundExit() -> Bool {
        switch _guard.direction {
        case .up:
            return(_guard.row == 0);
        case .right:
            return(_guard.col == OUB.n);
        case .down:
            return(_guard.row == OUB.m);
        case .left:
            return(_guard.col == 0);
        default:
            print("Error encountered in FoundExit()")
            return false;
        }
    }

    func DisplayLab() {
        for i in 0...OUB.m {
            for j in 0...OUB.n {
                print(layout[i][j], terminator: " ");
            }
            print();
        }
    }

    func CountVisited() -> Int {
        return layout.flatMap{$0}.filter{$0 == "X"}.count
    }

    mutating func GetOut() {
        var out: Bool = false;
        var LIMIT: Int = 0;

        while(!out && (LIMIT < ((OUB.m * OUB.n) + OUB.n))) {
            out = FoundExit();
            if ValidPosition() {
                Move();
            } else {
                ChangeDirection();
            }

            LIMIT += 1;
        }
    }
}


var lab = Lab(
    layout: InputRaw.split(separator: "\n").map { Array($0) }, 
    OUB: (m: size(x: InputRaw.count+1) - 1, n: size(x: InputRaw.count+1) - 1),
    _guard: (row: 0, col: 0, direction: .up)
)
lab.FindGuard()
lab.GetOut()
//lab.DisplayLab()
print(lab.CountVisited() + 1) // +1 for guard loc