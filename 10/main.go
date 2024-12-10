package main

import (
	"errors"
	"flag"
	"fmt"
	"math"
	"os"
	"sort"

	"github.com/cartersusi/stdext/set"
)

const (
	Example = iota
	Input
)

var fpath = []string{"data/example", "data/input"}
var NaN = math.NaN()

const LOW = 0
const HIGH = 9

func Assert(cond bool, msg string) {
	if !cond {
		panic(msg)
	}
}

func Mat(fpath string) ([][]int64, error) {
	var matrix [][]int64
	file, err := os.Open(fpath)
	if err != nil {
		fmt.Println(err)
		return nil, errors.New("Error opening file")
	}
	defer file.Close()

	for {
		var row []int64
		for {
			var cell rune
			_, err := fmt.Fscanf(file, "%c", &cell)
			if err != nil || cell == '\n' {
				break
			}
			row = append(row, int64(cell-'0'))
		}
		if len(row) == 0 {
			break
		}

		matrix = append(matrix, row)
	}

	return matrix, nil
}

type mem struct {
	i, j, d int
}

func ValidPaths(matrix [][]int64, start_i, start_j int) int {
	m := len(matrix)
	n := len(matrix[0])

	directions := [][2]int{{-1, 0}, {1, 0}, {0, -1}, {0, 1}}

	memo := make(map[mem]int)

	var lfn func(i, j, d int) int
	lfn = func(i, j, d int) int {
		if d == HIGH {
			return 1
		}

		key := mem{i, j, d}
		if val, exists := memo[key]; exists {
			return val
		}

		next := d + 1
		valid := 0
		for _, direction := range directions {
			ni := i + direction[0]
			nj := j + direction[1]
			if ni < 0 || ni >= m || nj < 0 || nj >= n {
				continue
			}
			if int(matrix[ni][nj]) == next {
				valid += lfn(ni, nj, next)
			}
		}

		memo[key] = valid
		return valid
	}

	return lfn(start_i, start_j, 0)
}

func main() {
	example := flag.Bool("e", false, "Use example data")
	flag.Parse()

	fp := fpath[Input]
	if *example {
		fp = fpath[Example]
	}

	matrix, err := Mat(fp)
	if err != nil {
		fmt.Println(err)
		return
	}
	m := len(matrix)
	n := len(matrix[0])
	Assert(m > 0 && n > 0, "Invalid matrix")

	s := set.NewSet[int]()
	for i := range matrix {
		for j := range matrix[i] {
			if matrix[i][j] == 0 {
				s.Add(i*n + j)
			}
		}
	}

	zeroes := s.Elements()
	sort.Ints(zeroes)
	fmt.Println(zeroes)
	Assert(zeroes[len(zeroes)-1] < m*n, "Invalid zeroes")

	score := 0
	for _, z := range zeroes {
		i, j := z/n, z%n
		score += ValidPaths(matrix, i, j)
	}

	fmt.Println(score)
}
