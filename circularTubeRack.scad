
// total number 

tubesPerSegment = 3; // at least 2
numberOfSegments = 9; // at least 2

// CALCULATED
totalNumberOfTubes = tubesPerSegment * numberOfSegments;

// Tube parameters
tubeRadius = 14.25;
tubeHeight = 100;
holderHeight = 70;

// Bolt parameters
boltDiameter = 3;
boltHeadRadius = 2;
boltLength = 10;
nutWidth = 5.6;
nutHeight = 2.2;
boltPosition = 3;

// Spacing between the tubes is determined by both material thickness and the extra userdefined padding

// defined by the material you use
materialThickness = 3;
// set this yourself
extraPadding = 2;

// CALCULATED
totalPadding = materialThickness+extraPadding+boltHeadRadius;

bottomHolderZPosition = 20;



spacerTeethSize = 4;

laserCutPieceSpacing = 20;

// Laser cutter parameters
paserCutLaserMargin = -0.05;

connectionPadding = boltDiameter * 3;


PI = 3.14159265359;

// Calculated vars
rackTubeCenterLinePerimeter = totalNumberOfTubes*(tubeRadius*2+totalPadding);
echo(str("outline distance: ",rackTubeCenterLinePerimeter,"mm"));

rackTubeCenterLineRadius = (rackTubeCenterLinePerimeter/PI)/2;
echo(str("tube center line radius: ",rackTubeCenterLineRadius,"mm"));

rackTubeCenterLineDiameter = rackTubeCenterLineRadius*2;

rackInnerRadius = rackTubeCenterLineRadius-tubeRadius-totalPadding;
rackInnerDiameter = rackInnerRadius*2;
rackOuterRadius = rackTubeCenterLineRadius+tubeRadius+totalPadding;
rackOuterDiameter = rackOuterRadius*2;



module mainCircle(dimensions) {
    difference() {
        if(dimensions == "3D") {
            cylinder(materialThickness, rackOuterRadius, rackOuterRadius, $fn=100);
        } else if(dimensions == "2D") {
            circle(rackOuterRadius, $fn=100);
        }
        if(dimensions == "3D") {
            translate([0,0,-0.5]) {
                cylinder(materialThickness+1, rackInnerRadius, rackInnerRadius, $fn=100);
            }
        } else if(dimensions == "2D") {
            circle(rackInnerRadius, $fn=100);
        }
    }
}

module testTubes(dimensions) {
    union() {
        for (i = [1:totalNumberOfTubes]) {
            rotate([0,0,(360/totalNumberOfTubes)*i]) {
                translate([rackTubeCenterLineRadius,0,0]) {
                    if(dimensions == "3D") {
                        translate([0,0,-materialThickness*2]) {
                            cylinder(materialThickness*4,tubeRadius,tubeRadius);
                        }
                    } else if(dimensions == "2D") {
                        circle(tubeRadius, $fn=100);
                    }
                }
            }
        }
    }
}

module spacerCutOut(dimensions) {
    union() {
        translate([-tubeRadius-totalPadding+spacerTeethSize,0,0]) {
            translate([-spacerTeethSize-1,-materialThickness/2,-0.5]) {
                if(dimensions == "3D") {
                    cube([spacerTeethSize+1,materialThickness,materialThickness+1]);
                } else if(dimensions == "2D") {
                translate([0,0,0.5]) {
                    square([spacerTeethSize+1, materialThickness]);
                    }
                }
            }
        }
        
        translate([tubeRadius+totalPadding-spacerTeethSize,0,0]) {
            translate([0,-materialThickness/2,-0.5]) {
                if(dimensions == "3D") {
                    cube([spacerTeethSize+1,materialThickness,materialThickness+1]);
                } else if(dimensions == "2D") {
                translate([0,0,0.5]) {
                    square([spacerTeethSize+1, materialThickness]);
                    }
                }
            }
        }
        translate([(tubeRadius+totalPadding)/2,0,-0.5]) {
            if(dimensions == "3D") {
                cylinder(materialThickness+1,boltDiameter/2,boltDiameter/2, $fn=100);
            } else if(dimensions == "2D") {
                translate([0,0,0.5]) {
                    circle(boltDiameter/2,$fn=100);
                }
            }
        }
         translate([(tubeRadius+totalPadding)/-2,0,-0.5]) {
            if(dimensions == "3D") {
                cylinder(materialThickness+1,boltDiameter/2,boltDiameter/2, $fn=100);
            } else if(dimensions == "2D") {
                translate([0,0,0.5]) {
                    circle(boltDiameter/2,$fn=100);
                }
            }
        }
    }
}

module cutOutsCircular(dimensions) {
    union() {
        rotation = 360/totalNumberOfTubes;
        for (i = [1:totalNumberOfTubes]) {
            rotate([0,0,rotation*i+rotation/2]) {
                translate([rackTubeCenterLineRadius,0,0]) {
                    spacerCutOut(dimensions);
                }
            }
        }
    }
}

module holderCircle(dimensions) {
    difference() {
        mainCircle(dimensions);
        testTubes(dimensions);
        cutOutsCircular(dimensions);
    }
}

module bottomPlate(dimensions) {
    difference() {
        mainCircle(dimensions);
        cutOutsCircular(dimensions);
    }
}

module BoltSilhouetteCutout(dimensions)
{

    translate([0,-nutWidth/2,0]) {
        union() {
            translate([0,nutWidth/2-boltDiameter/2,0]) {
                if(dimensions == "3D") {
                    translate([-0.5,0,-0.5]) {
                        cube([boltLength-materialThickness+0.5,
                            boltDiameter,
                            materialThickness+1]);
                    }
                } else if(dimensions == "2D") {
                    square([boltLength,boltDiameter]);
                }
            }
            translate([boltPosition,0,0]) {
                if(dimensions == "3D") {
                    translate([0,0,-0.5]) {
                        cube([nutHeight,nutWidth,materialThickness+1]);
                    }
                } else if(dimensions == "2D") {
                    square([nutHeight,nutWidth]);
                }
            }
        }
    }
}

module bottomHolderSpacer(dimensions) {
    masterSpacer(dimensions,bottomHolderZPosition);
}

module topHolderSpacer(dimensions) {
    masterSpacer(dimensions,holderHeight-bottomHolderZPosition);
}

module masterSpacer(dimensions, height) {
    height = height+materialThickness;
    difference() {
        if(dimensions == "3D") {
            cube([height,tubeRadius*2+totalPadding*2,materialThickness]);
        } else if(dimensions == "2D") {
            square([height,tubeRadius*2+totalPadding*2]);
        }
        translate([-1,spacerTeethSize,-0.5]) {
            if(dimensions == "3D") {
                cube([materialThickness+1,
                    tubeRadius*2+totalPadding*2-spacerTeethSize*2,
                    materialThickness+1]);
            } else if(dimensions == "2D") {
                translate([0,0,0.5]) {
                    square([materialThickness+1,tubeRadius*2+totalPadding*2-spacerTeethSize*2]);
                }
            }
        }
        translate([height-materialThickness,spacerTeethSize,-0.5]) {
            if(dimensions == "3D") {
                cube([materialThickness+1,
                    tubeRadius*2+totalPadding*2-spacerTeethSize*2,
                    materialThickness+1]);
            } else if(dimensions == "2D") {
                translate([0,0,0.5]) {
                    square([materialThickness+1,
                        tubeRadius*2+totalPadding*2-spacerTeethSize*2]);
                }
            }
        }
        translate([materialThickness,(tubeRadius+totalPadding)*1.5,0]) {
            BoltSilhouetteCutout(dimensions);
        }
         translate([height-materialThickness,(tubeRadius+totalPadding)/2,0]) {
             rotate([0,0,180]) {
                BoltSilhouetteCutout(dimensions);
            }
        }
    }
}

module bottomHolderSpacerRing(dimensions) {
    tubeAngle = 360/totalNumberOfTubes;
    segmentAngle = 360/numberOfSegments;
    for(i = [1:numberOfSegments]) {
        rotate([0,0,segmentAngle*i+tubeAngle/2]) {
            translate([rackTubeCenterLineRadius,0,bottomHolderZPosition/2+materialThickness]){
                rotate([0,90,90]) {
                    translate([-bottomHolderZPosition/2,
                        -tubeRadius-totalPadding,
                        -materialThickness/2]) {
            
                        bottomHolderSpacer(dimensions);
                    }
                }
            }
        }
    }
}

module topHolderSpacerRing(dimensions) {
    tubeAngle = 360/totalNumberOfTubes;
    segmentAngle = 360/numberOfSegments;
    for(i = [1:totalNumberOfTubes]) {
        floored = floor(i/tubesPerSegment);
        echo(str("floored: ",floored));
        divided = i/tubesPerSegment;
        echo(str("divided: ",divided));
        if(floored != divided) {
            rotate([0,0,tubeAngle*i+tubeAngle/2]) {
                translate([rackTubeCenterLineRadius,0,bottomHolderZPosition/2+materialThickness]){
                    rotate([0,90,90]) {
                        translate([-bottomHolderZPosition/2,
                            -tubeRadius-totalPadding,
                            -materialThickness/2]) {
                
                            topHolderSpacer(dimensions);
                        }
                    }
                }
            }
        }
    }
}

module circularRack3D(dimensions) {
    bottomPlate(dimensions);
    translate([0,0,bottomHolderZPosition]) {
        holderCircle(dimensions);
    }
    translate([0,0,holderHeight]) {
        holderCircle(dimensions);
    }
    bottomHolderSpacerRing(dimensions);
    translate([0,0,holderHeight/2+bottomHolderZPosition-materialThickness*2]) {
        topHolderSpacerRing(dimensions);
    }
}

module circularRackFlat(dimensions) {
    // bottomplate
    bottomPlate(dimensions);
    translate([rackOuterDiameter+laserCutPieceSpacing,0,0]) {
        holderCircle(dimensions);
        translate([rackOuterDiameter+laserCutPieceSpacing,0,0]) {
            holderCircle(dimensions);
            translate([rackOuterDiameter/2+laserCutPieceSpacing,0,0]) {
                // lower spacers = number of segments
                lowerSpacerCount = numberOfSegments;
                // upper spacers 
                // = total number of tubes - number of lower spacers/number of segments
                upperSpacerCount = totalNumberOfTubes - lowerSpacerCount;
                for(i = [1:lowerSpacerCount]) {
                    translate([i*(tubeRadius*2+totalPadding*2+5),0,0]) {
                        bottomHolderSpacer(dimensions);
                    }
                }
                for(i = [1:upperSpacerCount]) {
                    translate([i*(holderHeight+5),-(tubeRadius*2+totalPadding*2+5),0]) {
                        topHolderSpacer(dimensions);
                    }
                }
            }
        }
    }
}


circularRack3D("3D");
//circularRackFlat("2D");

