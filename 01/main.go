package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"
)

func Abs(a int) int {
	if a < 0 {
		return -a
	}
	return a
}

func FindN(a int, arr []int) int {
	res := 0
	for _, val := range arr {
		if val == a {
			res++
		}
		if val > a {
			return res
		}
	}

	return res
}

func main() {
	fpath := "input"

	file, err := os.Open(fpath)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	sc := bufio.NewScanner(file)

	var left []int
	var right []int
	for sc.Scan() {
		line := sc.Text()
		numbers := strings.Split(line, "   ")
		left_n, err := strconv.ParseInt(numbers[0], 10, 64)
		if err != nil {
			panic(err)
		}
		right_n, err := strconv.ParseInt(numbers[1], 10, 64)
		if err != nil {
			panic(err)
		}
		left = append(left, int(left_n))
		right = append(right, int(right_n))
	}

	sort.Ints(left)
	sort.Ints(right)

	res := 0
	for i := range left {
		// Part 1
		//res += Abs(left[i] - right[i])

		res += left[i] * FindN(left[i], right)
	}

	fmt.Println(res)

}
