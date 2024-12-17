package main

import (
	"fmt"
	"os"
)

const fpath = "data/example"

type Input struct {
	RegisterA int64
	RegisterB int64
	RegisterC int64
	Program   []int64
}

func readInput(fpath string) *Input {
	f, err := os.Open(fpath)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	var a, b, c int64
	var program []int64
	_, err = fmt.Fscanf(f, "Register A: %d\nRegister B: %d\nRegister C: %d", &a, &b, &c)
	_, err = fmt.Fscanf(f, "\nProgram:")

	for {
		var instr int64
		_, err := fmt.Fscanf(f, "%d", &instr)
		if err != nil {
			break
		}
		program = append(program, instr)
	}

	return &Input{
		RegisterA: a,
		RegisterB: b,
		RegisterC: c,
		Program:   program,
	}
}

func main() {
	fmt.Println("Hello, playground")

	input := readInput(fpath)
	fmt.Println(input)

}
