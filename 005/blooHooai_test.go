
package bloo_hooai

import (
	"testing"
	"encoding/json"
)

func Test_ReadJSON(tea *testing.T) {
	dewd := ReadJSON("sample_vacrentals.json")
	
	if dewd == nil {
		tea.Error("ReadJSON should not return nil for a proper json file")
	} else if len(dewd) == 0 {
		tea.Error("ReadJSON should have found some items")
	} else if dewd[0].Name == "" {
		r, e := json.Marshal(dewd[0])
		tea.Errorf("ReadJSON should have parsed the first name: | %s | %s", string(r), e )
	} else if dewd[0].Name != "Fern Grove Lodge" {
		tea.Errorf("ReadJSON got %s instead of the correct name, 'Fern Grove Lodge'", dewd[0].Name)
	} else if len(dewd[0].Seasons) == 0 {
		r, e := json.Marshal(dewd[0])
		tea.Errorf("ReadJSON didn't get any seasons. | %s | %s ", string(r), e)
	} else if dewd[0].Seasons[0]["one"].Start != "05-01" {
		tea.Error("ReadJSON didn't get the first season name.")
	}

}
