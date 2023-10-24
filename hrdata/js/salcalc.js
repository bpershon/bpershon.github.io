var saldict = {
    "Finance":{"Intern":[33770, 34076],
               "Junior Developer":[46910, 58688],
               "Analyst":[63299, 71604],
               "Senior Developer":[87114, 94110],
               "Team Lead":[101100, 107751],
               "Manager":[100719, 119895]
                },
    "IT":{"Intern":[32010, 37357],
               "Junior Developer":[47188, 59502],
               "Analyst":[63299, 70439],
               "Senior Developer":[84252, 93702],
               "Team Lead":[101133, 107279],
               "Manager":[100795, 119208]
                },
    "Marketing":{"Intern":[31878, 38303],
               "Junior Developer":[47322, 57478],
               "Analyst":[64858, 74918],
               "Senior Developer":[82101, 92954],
               "Team Lead":[92217, 107062],
               "Manager":[104216, 119567]
                },
    "Sales":{"Intern":[32903, 38878],
               "Junior Developer":[47294, 59877],
               "Analyst":[62727, 73916],
               "Senior Developer":[80793, 93569],
               "Team Lead":[94026, 108390],
               "Manager":[107080, 118466]
                },
    "HR":{"Intern":[31230, 39670],
               "Junior Developer":[50051, 54974],
               "Analyst":[66367, 71365],
               "Senior Developer":[80513, 94290],
               "Team Lead":[95289, 100865],
               "Manager":[105706, 116473]
                }
}

const formatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD'
});

function calcOffer(){
    const values = document.getElementById("form1").elements;
    const dept = values["dept"].value;
    const posi = values["pos"].value;
    const exper = values["exper"].value;

    var reg = 3189.09 * exper + 48013.07;
    var offer = Math.round(Math.max(saldict[dept][posi][0], Math.min(reg, saldict[dept][posi][1])));
    var offertext = "The Salary offer for a " + posi + " working in the " + dept + " department is: " + formatter.format(offer);
    var saltext = "Currently " + posi + " in the " + dept + " department make between " + formatter.format(saldict[dept][posi][0]) + " and " + formatter.format(saldict[dept][posi][1]);
    document.getElementById("result").innerHTML = offertext;
    document.getElementById("result2").innerHTML = saltext;
}