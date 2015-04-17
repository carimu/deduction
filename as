package {
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;

	public class Deduction extends MovieClip {
		
		// constants
		static const numPegs:uint = 5;
		static const numColors:uint = 5;
		static const maxTries:uint = 10;
		static const horizOffset:Number = 30;
		static const vertOffset:Number = 60;
		static const pegSpacing:Number = 30;
		static const rowSpacing:Number = 30;
		
		// game play variables
		private var solution:Array;
		private var turnNum:uint;
		
		// references to display objects
		private var currentRow:Array;
		private var currentText:TextField;
		private var currentButton:DoneButton;
		private var allDisplayObjects:Array;
		
		public function Deduction() {
		}
		
		// create solution and show the first row of pegs
		public function startGame() {
			allDisplayObjects = new Array();
			solution = new Array();
			for(var i:uint=0;i<numPegs;i++) {
				// random, from 1 to 5
				var r:uint = uint(Math.floor(Math.random()*numColors)+1);
				solution.push(r);
			}
			turnNum = 0;
			createPegRow();
		}
		
		// create a row of pegs, plus the DONE button and text field
		public function createPegRow() {
			
			// create pegs and make them buttons
			currentRow = new Array();
			for(var i:uint=0;i<numPegs;i++) {
				var newPeg:Peg = new Peg();
				newPeg.x = i*pegSpacing+horizOffset;
				newPeg.y = turnNum*rowSpacing+vertOffset;
				newPeg.gotoAndStop(1);
				newPeg.addEventListener(MouseEvent.CLICK,clickPeg);
				newPeg.buttonMode = true;
				newPeg.pegNum = i;
				addChild(newPeg);
				allDisplayObjects.push(newPeg);
				
				// record pegs as array of objects
				currentRow.push({peg: newPeg, color: 0});
			}
			
			// only create the DONE button if we haven't already
			if (currentButton == null) {
				currentButton = new DoneButton();
				currentButton.x = numPegs*pegSpacing+horizOffset+pegSpacing;
				currentButton.addEventListener(MouseEvent.CLICK,clickDone);
				addChild(currentButton);
				allDisplayObjects.push(currentButton);
			}
			// position DONE button with row
			currentButton.y = turnNum*rowSpacing+vertOffset;
			
			// create text message next to pegs and button
			currentText = new TextField();
			currentText.x = numPegs*pegSpacing+horizOffset+pegSpacing*2+currentButton.width;
			currentText.y = turnNum*rowSpacing+vertOffset;
			currentText.width = 300;
			currentText.text = "Click on the holes to place pegs and click DONE.";
			addChild(currentText);
			allDisplayObjects.push(currentText);
		}
		
		// player clicks a peg
		public function clickPeg(event:MouseEvent) {
			// figure out which peg and get color
			var thisPeg:Object = currentRow[event.currentTarget.pegNum];
			var currentColor:uint = thisPeg.color;
			
			// advance color of peg by one, loop back from 5 to 0
			if (currentColor < numColors) {
				thisPeg.color = currentColor+1
			} else {
				thisPeg.color = 0;
			}
			
			// show peg, or abscence of
			thisPeg.peg.gotoAndStop(thisPeg.color+1);
		}
		
		// player clicks DONE button
		public function clickDone(event:MouseEvent) {
			calculateProgress();
		}
		
		// calculate results
		public function calculateProgress() {
			var numCorrectSpot:uint = 0;
			var numCorrectColor:uint = 0;
			var solutionColorList:Array = new Array(0,0,0,0,0);
			var currentColorList:Array = new Array(0,0,0,0,0);
			
			// loop through pegs
			for(var i:uint=0;i<numPegs;i++) {
				// does this peg match?
				if (currentRow[i].color == solution[i]) {
					numCorrectSpot++;
				} else {
					// no match, but record colors for next test
					solutionColorList[solution[i]-1]++;
					currentColorList[currentRow[i].color-1]++;
				}
				// turn off peg as a button
				currentRow[i].peg.removeEventListener(MouseEvent.CLICK,clickPeg);
				currentRow[i].peg.buttonMode = false;
			}
			
			// get the number of correct colors in right place 
			for(i=0;i<numColors;i++) {
				numCorrectColor += Math.min(solutionColorList[i],currentColorList[i]);
			}
			
			// report results
			currentText.text = "Correct Spot: "+numCorrectSpot+", Correct Color: "+numCorrectColor;
			
			turnNum++;
			
			if (numCorrectSpot == numPegs) {
				gameOver();
			} else {
				if (turnNum == maxTries) {
					gameLost();
				} else {
					createPegRow();
				}
			}
		}
		
		// player found the solution
		public function gameOver() {
			// change the button
			currentButton.y = turnNum*rowSpacing+vertOffset;
			currentButton.removeEventListener(MouseEvent.CLICK,clickDone);
			currentButton.addEventListener(MouseEvent.CLICK,clearGame);
			
			// create text message next to pegs and button
			currentText = new TextField();
			currentText.x = numPegs*pegSpacing+horizOffset+pegSpacing*2+currentButton.width;
			currentText.y = turnNum*rowSpacing+vertOffset;
			currentText.width = 300;
			currentText.text = "You got it!";
			addChild(currentText);
			allDisplayObjects.push(currentText);
		}
		
		// player ran out of turns
		public function gameLost() {
			// change the button
			currentButton.y = turnNum*rowSpacing+vertOffset;
			currentButton.removeEventListener(MouseEvent.CLICK,clickDone);
			currentButton.addEventListener(MouseEvent.CLICK,clearGame);
			
			// create text message next to pegs and button
			currentText = new TextField();
			currentText.x = numPegs*pegSpacing+horizOffset+pegSpacing*2+currentButton.width;
			currentText.y = turnNum*rowSpacing+vertOffset;
			currentText.width = 300;
			currentText.text = "You ran out of guesses!";
			addChild(currentText);
			allDisplayObjects.push(currentText);

			// create final row of pegs to show answer
			currentRow = new Array();
			for(var i:uint=0;i<numPegs;i++) {
				var newPeg:Peg = new Peg();
				newPeg.x = i*pegSpacing+horizOffset;
				newPeg.y = turnNum*rowSpacing+vertOffset;
				newPeg.gotoAndStop(solution[i]+1);
				addChild(newPeg);
				allDisplayObjects.push(newPeg);
			}
			
		}
		
		// remove all to go to game over screen
		public function clearGame(event:MouseEvent) {
			// remove all display objects
			for(var i in allDisplayObjects) {
				removeChild(allDisplayObjects[i]);
			}
			
			// set all references of display objects to null
			allDisplayObjects = null;
			currentText = null;
			currentButton = null;
			currentRow = null;
			
			// tell main timeline to move on
			MovieClip(root).gotoAndStop("gameover");
		}
	}
}
