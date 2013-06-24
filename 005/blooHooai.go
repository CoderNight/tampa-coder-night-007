
package bloo_hooai

import (
	"io/ioutil"
	"encoding/json"
	"sort"
)

type Season struct {
	Start string `json: "start"`
	End string `json: "end"`
	Rate string `json: "rate"`
}

type Resort struct {
	Name string `json: "name"`
	Seasons []map[string]Season `json: "seasons"`
	Rate string `json: "rate"`
	Fee string `json: "cleaning fee"`
}

func (h *Resort) getSeason(i int) Season {
	var result Season
	for k, _ := range h.Seasons[i] {
		result = h.Seasons[i][k] //mondo lame
	}
	return result
}

func (h *Resort) Len() int {
	return len(h.Seasons)
}
func (h* Resort) Less(i, j int) bool {
	return h.getSeason(i).Start < h.getSeason(j).Start
}
func (h *Resort) Swap(i, j int) {
	I := h.Seasons[i]
	h.Seasons[i] = h.Seasons[j]
	h.Seasons[j] = I
}
func (h *Resort) order() {
	sort.Sort(h)
}

const tax = 0.0411416

func ReadJSON(path string) []Resort {
	var result []Resort;
	
	file, durr := ioutil.ReadFile(path)
	if durr != nil {
		return nil
	}
	
	json.Unmarshal(file, &result)
	return result;
}