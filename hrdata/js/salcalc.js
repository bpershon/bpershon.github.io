const depts = ["Finance", "IT", "Marketing", "Sales", "HR"]
const pos = ["Intern", "Junior Developer", "Analyst", "Senior Developer", "Team Lead", "Manager"];

var jobObject = {
    "Finance":pos,
    "IT":pos,
    "Marketing":pos,
    "Sales":pos,
    "HR":pos,
};

window.onload = function() {
  var deptSel = document.getElementById("department");
  var posSel = document.getElementById("position");
  for (var x in jobObject) {
    deptSel.options[deptSel.options.length] = new Option(x, x);
  }
  deptSel.onchange = function() {
    //empty position drop down
    posSel.length = 1;
    //display correct values
    for (var y in jobObject[this.value]) {
      posSel.options[posSel.options.length] = new Option(pos[y], pos[y]);
    }
  }
}

function calcOffer(){
    const values = document.getElementById("form1").elements;
    const dept = values["department"]
    const posi = values["position"]
    console.log(dept)
    console.log(posi)
}