import java.util.*;

// how big the screen will be
int screenLength;

// how big the board will be 
int gridLength;

// used to identify coordinates via the grid of the board
int x;
int y;

// used to identify the spatial position
int xPos;
int yPos;

// used to set bounds
int xMin;
int xMax;
int yMin;
int yMax;

// the stone's position in the stone array
int stoneNum;

// setting up the turn structure
int turn;
int blackTurn = 1;
int whiteTurn = 2;

// this is the type of stone that will be
// searched for later in the program
int lookFor;

// how large the grid is
int gridNum = 9;

// this array will hold all of the stones
// they are ordered from left to right,
// then top to bottom
Stone[] stones = new Stone[81];

// this array  and counter are used when checking for liberties
int[] checkArray = new int[81];
int counter = 0;  

// prevents suicidal placements
boolean safePlace;

// sets the game state
int state;

// part of the timer for changing game states
long lastPressProcessed;

public void setup() {
  // set the frame rate
  frameRate(60);
  
  // set up the canvas
  screenLength = 450;
  background(255);
  size(450, 500);
  
  // draw the grid
  gridLength = 360;
  
  stroke(0);
  
  // setting all values in the array to -1
  for (int c = 0; c < 81; c++) {
    checkArray[c] = -1;
  }
  
  // vertical lines
  for (int c = 0; c < 9; c++) {
    rect((c+1) * 45, 45, 1, gridLength);
  }
  
  // horizontal lines
  for (int c = 0; c < 9; c++) {
    rect(45, (c+1) * 45, gridLength, 1);
  }
  
  // initialize the stone array
  for (int c = 0; c < 81; c++) {
    stones[c] = new Stone(((c % 9) + 1) * 45, ((c / 9) + 1) * 45, 0);
  }
  
  // black will go first
  turn = blackTurn;
  
  // aligns all text to be displayed in the center
  textAlign(CENTER);
  
  // sets the initial game state
  state = 1;
  
  // important for slowing down the "Enter" presses
  lastPressProcessed = System.currentTimeMillis();

}

public void draw() {
  
  // leaves the board untoachable, but displays the proper text
  if (state == 1 || state == 3) {
    displayText();
    if (key == ENTER) {
      keyPressed();
    }
  }
  
  // this is the gameplay state
  else if (state == 2) {
    
    // constantly redraws the field, allowing any updates
    // to the stone's type to be seen
    // vertical lines
    populate();
    
    // if the user clicks...
    if (mousePressed == true) {
      // and a the click is in bounds...
      x = (mouseX - 20) / 45;
      y = (mouseY - 20) / 45;
      if (x < 9 && y < 9) {
        stoneNum = (y * 9) + x;
        // place a stone
        placeStone();
      }
    }
    // display the current turn
    displayText();
    if (key == ENTER) {
      keyPressed();
    }  
  }  
}

public void populate() {
  // this constantly cycles through the entire stones array
  // 60 times per second
  
  for (int c = 0; c < 81; c++) {
    // getting the position of each stone
    xPos = stones[c].xPos;
    yPos = stones[c].yPos;
    
    // this will be "empty"
    if (stones[c].type == 0) {
      fill(255);
      noStroke();
      // covering up any stones
      rect(xPos-15, yPos-15, 32, 32);
      fill(0);
      stroke(0);
      // special case: top left corner
      if (c == 0) {
        // horizontal
        rect(xPos, yPos, 16, 1);
        // vertical
        rect(xPos, yPos, 1, 16);
      }
      // special case: top right corner
      else if (c == 8) {
        // horizontal
        rect(xPos-16, yPos, 16, 1);
        // vertical
        rect(xPos, yPos, 1, 16);
      }
      // special case: bottom left corner
      else if (c == 72) {
        // horizontal
        rect(xPos, yPos, 16, 1);
        // vertical
        rect(xPos, yPos-16, 1, 16);
      }
      // special case: bottom right corner
      else if (c == 80) {
        // horizontal
        rect(xPos-16, yPos, 16, 1);
        // vertical
        rect(xPos, yPos-16, 1, 16);
      }
      // top row
      else if (c < 9) {
        // horizontal
        rect(xPos-16, yPos, 32, 1);
        // vertical
        rect(xPos, yPos, 1, 16);
      }
      // bottom row
      else if (c > 71) {
        // horizontal
        rect(xPos-16, yPos, 32, 1);
        // vertical
        rect(xPos, yPos-16, 1, 16);          
      }
      // leftmost column
      else if (c % 9 == 0) {
        // horizontal
        rect(xPos, yPos, 16, 1);
        // vertical
        rect(xPos, yPos-16, 1, 32);
      }
      // rightmost column
      else if (c % 9 == 8) {
        // horizontal
        rect(xPos-16, yPos, 16, 1);
        // vertical
        rect(xPos, yPos-16, 1, 32);
      }
      // and the rest of the board
      else {
        // horizontal
        rect(xPos-16, yPos, 32, 1);
        // vertical
        rect(xPos, yPos-16, 1, 32);
      }
    }
    // this will be "black"
    else if (stones[c].type == 1) {
      stroke(1);
      fill(0);
      // redrawing that stone
      ellipse(xPos, yPos, 30, 30);
    }
    // this will be "white"
    else if (stones[c].type == 2) {
      stroke(1);
      fill(255);
      // redrawing that stone
      ellipse(xPos, yPos, 29, 29);
    }
  }
}

public void placeStone() {
  // establish a click range
  xMin = ((x + 1) * 45) - 20;
  xMax = ((x + 1) * 45) + 20;
  yMin = ((y + 1) * 45) - 20;
  yMax = ((y + 1) * 45) + 20;
  
  // if click close enough to a node AND the space is open,
  // a stone is placed by changing its type
  // the difference will be seen once populate() runs
  // the turn is then switched
  if (mouseX > xMin && mouseX < xMax && mouseY > yMin && mouseY < yMax && stones[stoneNum].type == 0) {
    stones[stoneNum].type = turn;
    turnSwitch();
    // these next few lines of code cover up the "no suicides" text
    fill(255);
    noStroke();
    rect(0, 0, 450, 30);
  }
  // the stones that now must be looked for
  // will be the cover of the just switched turn
  lookFor = turn;
  checkSurrounding();
}

public void turnSwitch() {
  // this changes the turn back and forth
  // from black to white
  if (turn == blackTurn) {
    turn = whiteTurn;
  }
  else if (turn == whiteTurn) {
    turn = blackTurn;
  }
}

// this method checks all groups of stones immediately surrounding
// the placed stone to see if the groups they belong to are captured
public void checkSurrounding() {
  // safePlace checks if the placement was safe
  // if opposing stones are taken, the placement is safe
  safePlace = false;
  if (stoneAbove(stoneNum)) {
    if (checkLiberties(stoneNum - 9) == false) {
      takeOffStones();
      safePlace = true;
    }
    clearCheckArray();
  }
  if (stoneToLeft(stoneNum)) {
    if (checkLiberties(stoneNum - 1) == false) {
      takeOffStones();
      safePlace = true;
    }
    clearCheckArray();
  }
  if (stoneBelow(stoneNum)) {
    if (checkLiberties(stoneNum + 9) == false) {
      takeOffStones();
      safePlace = true;
    }
    clearCheckArray();
  }
  if (stoneToRight(stoneNum)) {
    if (checkLiberties(stoneNum + 1) == false) {
      takeOffStones();
      safePlace = true;
    }
    clearCheckArray();
  }
  // if the stone / it's team neighbors are safe, it's a safe place
  if (checkLiberties(stoneNum)) {
    safePlace = true;
  }
  clearCheckArray();
  
  // if it's not a safe place, the place is reverted to an empty space
  // also, that player gets to try and place again
  if (!safePlace) {
    stones[stoneNum].type = 0;
    turnSwitch();
    // this message warns the player not to suicide
    textSize(25);
    fill(0);
    text("Suicides are not alowed", 225, 28);
  }
}

// if there are any liberties surrounding a stone,
// this method returns true
public boolean checkLiberties(int checkedStone) {
  checkArray[counter] = checkedStone;
  counter++;
  if (libertyAbove(checkedStone)    == true ||
    libertyToLeft(checkedStone)   == true ||
    libertyBelow(checkedStone)    == true ||
    libertyToRight(checkedStone)  == true) {
    return true;
  }
  else
    return false;
  
}

public boolean libertyAbove(int checkedStone) {
  // any stone in row 0 will be skipped
  if (checkedStone > 8) {
    // the location immediately above will be checked for a liberty
    if (stones[checkedStone - 9].type == 0) {
      // if a liberty is found, the liberty check program will cease
      return true;
    }
    // if the stone above is of the same type, it must be checked for liberties
    else if (stones[checkedStone - 9].type == stones[checkedStone].type &&
        stoneInArray(checkedStone - 9) == false) {
      if (checkLiberties(checkedStone - 9) == true) {
        return true;
      }
      else {
        return false;
      }
    }
    else
      return false;
  }
  else
    return false;
}

public boolean libertyToLeft(int checkedStone) {
  // any stone in column 0 will be skipped
  if (checkedStone % 9 != 0) {
    // the location immediately to the left will be checked for a liberty
    if (stones[checkedStone - 1].type == 0) {
      // if a liberty is found, the liberty check program will cease
      return true;
    }
    // if the stone to the left is of the same type, it must be checked for liberties
    else if (stones[checkedStone - 1].type == stones[checkedStone].type &&
        stoneInArray(checkedStone - 1) == false) {
      if (checkLiberties(checkedStone - 1) == true) {
        return true;
      }
      else {
        return false;
      }
    }
    else
      return false;
  }
  else
    return false;
}

public boolean libertyBelow(int checkedStone) {
  // any stone in row 8 will be skipped
  if (checkedStone < 72) {
    // the location immediately below will be checked for a liberty
    if (stones[checkedStone + 9].type == 0) {
      // if a liberty is found, the liberty check program will cease
      return true;
    }
    // if the stone below is of the same type, it must be checked for liberties
    else if (stones[checkedStone + 9].type == stones[checkedStone].type &&
        stoneInArray(checkedStone + 9) == false) {
      if (checkLiberties(checkedStone + 9) == true) {
        return true;
      }
      else {
        return false;
      }
    }
    else
      return false;
  }
  else
    return false;
}


public boolean libertyToRight(int checkedStone) {
  // any stone in column 8 will be skipped
  if (checkedStone % 9 != 8) {
    // the location immediately to the right will be checked for a liberty
    if (stones[checkedStone + 1].type == 0) {
      // if a liberty is found, the liberty check program will cease
      return true;
    }
    // if the stone to the right is of the same type, it must be checked for liberties
    else if (stones[checkedStone + 1].type == stones[checkedStone].type &&
        stoneInArray(checkedStone + 1) == false) {
      if (checkLiberties(checkedStone + 1) == true) {
        return true;
      }
      else {
        return false;
      }
    }
    else
      return false;
  }
  else
    return false;
}
  

public boolean stoneAbove(int centerStone) {
  // any stone in row 0 will be skipped
  if (centerStone > 8) {
    // the stone immediately above will be checked for a match
    if (stones[centerStone - 9].type == lookFor)
      return true;
    else
      return false;
  }
  else
    return false;
}


public boolean stoneToLeft(int centerStone) {
  // any stone in column 0 will be skipped
  if (centerStone % 9 != 0 ) {
    // the stone immediately to the left will be checked for a match
    if (stones[centerStone - 1].type == lookFor)
      return true;
    else
      return false;
  }
  else
    return false;
}

public boolean stoneBelow(int centerStone) {
  // any stone in row 8 will be skipped
  if (centerStone < 72) {
    // the stone immediately below will be checked for a match
    if (stones[centerStone + 9].type == lookFor)
      return true;
    else
      return false;
  }
  else
    return false;
}

public boolean stoneToRight(int centerStone) {
  // any stone in column 8 will be skipped
  if (centerStone % 9 != 8) {
    // the stone immediately to the right will be checked for a match
    if (stones[centerStone + 1].type == lookFor)
      return true;
    else
      return false;
  }
  else
    return false;
}

// this prevents the recursive methods from repeating infintely
public boolean stoneInArray(int checkedStone) {
  for (int c = 0; c < 81; c++) {
    if (checkedStone == checkArray[c]) 
      return true;
  }
  return false;
}

// this takes off all the stones in the array of checked stones
public void takeOffStones() {
  for (int c = 0; c < counter; c++) {
    stones[checkArray[c]].type = 0;
  }
}

// this empties the array of checked stones
public void clearCheckArray() {
  for (int c = 0; c < counter; c++) {
    checkArray[c] = -1;
  }
  counter = 0;
}

// this displays messages on the bottom of the screen
public void displayText() {
  noStroke();
  // intro screen
  if (state == 1) {
    fill(255);
    rect(0, 410, 450, 100);
    fill(0);
    textSize(25);
    fill(0);
    text("Go, an Applet by James Kelleher", 225, 435);
    text("Press Enter to Begin", 225, 460);
    text("Press Enter Again to End", 225, 485);
  }
  // gameplay screen
  else if (state == 2) {
    fill(255);
    rect(0, 425, 450, 60);
    fill(0);
    textSize(50);
    if (turn == blackTurn) {
      text("Turn: Black", 225, 465);
    }
    else if (turn == whiteTurn) {
      text("Turn: White", 225, 465);
    }
  }
  // results screen
  else {
    fill(255);
    rect(0, 410, 450, 100);
    fill(0);
    int blackNum = 0;
    int whiteNum = 0;
    for (int i = 0; i < stones.length; i++) {
      if (stones[i].type == 1) {
        blackNum++;
      }
      else if (stones[i].type == 2) {
        whiteNum++;
      }
    }
    textSize(25);
    text("Black = " + blackNum + ", White = " + whiteNum, 225, 435);
    if (blackNum > whiteNum) {
      text("Black wins!!", 225, 460);
    }
    else if (whiteNum > blackNum){
      text("White wins!!", 225, 460);
    }
    else {
      text("It's a tie", 225, 460);
    }
    text("Press enter to play again", 225, 485);
  }
}

// this allows the states to be changed
public void keyPressed() {
  if (key == ENTER) {
        if(System.currentTimeMillis() - lastPressProcessed > 500) {
            if (state == 1) {
              fill(255);
          rect(0, 410, 450, 100);
              state = 2;
            }
            else if (state == 2) {
              state = 3;
            }
            else {
              fill(255);
          rect(0, 0, 450, 40);
          rect(0, 410, 450, 100);
          for (int i = 0; i < stones.length; i++) {
            stones[i].type = 0;
          }
              state = 2;
            }
            lastPressProcessed = System.currentTimeMillis();
        }
  }
  key = 'a';
  }

public class Stone {

  // instance variables
  int xPos;
  int yPos;
  int type;
  
  // constructor
  public Stone(int xPos, int yPos, int type) {
    this.xPos = xPos;
    this.yPos = yPos;
    this.type = type;
  }

}

