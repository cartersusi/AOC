package main

import (
	"bufio"
	"fmt"
	"os"
)

type position struct {
	x, y int
}

type velocity struct {
	x, y int
}

type Robot struct {
	p position
	v velocity
}

type Robots struct {
	Robots       []Robot
	Bathroom     [][]int
	BathroomSize [2]uint
}

func abs(a int) int {
	if a < 0 {
		return -a
	}
	return a
}

func assert(condition bool, msg ...string) {
	e := "Assertion failed"
	if len(msg) > 0 {
		e = msg[0]
	}
	if !condition {
		panic(e)
	}

}

func (r *Robots) Quadrants() int {
	qx := int(r.BathroomSize[0]) / 2
	qy := int(r.BathroomSize[1]) / 2
	q := [4]int{}

	for _, robot := range r.Robots {
		if robot.p.x == qx || robot.p.y == qy {
			continue
		}
		if robot.p.x < qx && robot.p.y < qy {
			q[0]++
		} else if robot.p.x >= qx && robot.p.y < qy {
			q[1]++
		} else if robot.p.x < qx && robot.p.y >= qy {
			q[2]++
		} else {
			q[3]++
		}
	}

	assert(q[0]*q[1]*q[2]*q[3] > 0, "No robots in a quadrant")
	return q[0] * q[1] * q[2] * q[3]
}

func (r *Robots) Move() {
	for i := range r.Robots {
		r.Bathroom[r.Robots[i].p.y][r.Robots[i].p.x]--

		px_f := r.Robots[i].p.x + r.Robots[i].v.x
		py_f := r.Robots[i].p.y + r.Robots[i].v.y

		px_f = (px_f%(int(r.BathroomSize[0])+1) + (int(r.BathroomSize[0]) + 1)) % (int(r.BathroomSize[0]) + 1)
		py_f = (py_f%(int(r.BathroomSize[1])+1) + (int(r.BathroomSize[1]) + 1)) % (int(r.BathroomSize[1]) + 1)

		r.Robots[i].p.x = px_f
		r.Robots[i].p.y = py_f
		r.Bathroom[r.Robots[i].p.y][r.Robots[i].p.x]++
	}
}

func (r *Robots) Simulate(sec uint) {
	for i := uint(0); i < sec; i++ {
		r.Move()
	}
}

func (r *Robots) SetBathroom() {
	for _, v := range r.Robots {
		r.BathroomSize[0] = max(r.BathroomSize[0], uint(v.p.x))
		r.BathroomSize[1] = max(r.BathroomSize[1], uint(v.p.y))
	}

	assert(r.BathroomSize[0] > 0, "Bathroom size is 0")
	assert(r.BathroomSize[1] > 0, "Bathroom size is 0")

	r.Bathroom = make([][]int, r.BathroomSize[1]+1)
	for i := range r.Bathroom {
		r.Bathroom[i] = make([]int, r.BathroomSize[0]+1)
	}

	for _, v := range r.Robots {
		r.Bathroom[v.p.y][v.p.x]++
	}
}

func (r *Robots) Load(fpath string) {
	f, err := os.Open(fpath)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	sc := bufio.NewScanner(f)
	for sc.Scan() {
		var tmp Robot
		fmt.Sscanf(sc.Text(), "p=%d,%d v=%d,%d", &tmp.p.x, &tmp.p.y, &tmp.v.x, &tmp.v.y)
		r.Robots = append(r.Robots, tmp)
	}
}

func (r *Robots) Print() {
	fmt.Println("Robots:")
	fmt.Println("Bathroom size:", r.Bathroom)
	for _, v := range r.Robots {
		fmt.Printf("p=%d,%d v=%d,%d\n", v.p.x, v.p.y, v.v.x, v.v.y)
	}

	for i := 0; i <= int(r.BathroomSize[1]); i++ {
		for j := 0; j <= int(r.BathroomSize[0]); j++ {
			c := r.Bathroom[i][j]
			if c == 0 {
				fmt.Print(".")
			} else {
				fmt.Print(c)
			}
		}
		fmt.Println()
	}
}
