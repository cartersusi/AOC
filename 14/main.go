package main

import (
	"flag"
	"fmt"
)

var FPATH = []string{"data/example", "data/input"}

func main() {
	fpath := FPATH[1]
	ex := flag.Bool("e", false, "Use example data")
	flag.Parse()

	if *ex {
		fpath = FPATH[0]
	}
	fmt.Println("fpath:", fpath)

	r := Robots{}
	r.Load(fpath)
	r.SetBathroom()
	r.Simulate(100)
	//r.Print()

	fmt.Println("Result: ", r.Quadrants())
}
