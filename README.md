**SIMON GAME ON ZYBO DEVELOPMENT BOARD** 

This project implements the classic Simon game using the Zybo Development Board. The game generates patterns using the four LEDs and waits for the user to press the corresponding push buttons. The difficulty increases with each successful attempt, and the game provides visual feedback through the RGB LEDs.

Features
Pattern Generation: Starts with a single LED pattern and adds a new step with each success.

User Interaction: Users repeat the pattern using push buttons.

Feedback:
Correct pattern: Green RGB LED flashes.
Incorrect pattern: Red RGB LED flashes and the game ends.
Final score: Blue RGB LED flashes to indicate points earned.

Game Reset: Press push buttons 0 and 3 together to reset the game, clearing points and resetting the pattern.

A demo video has been attached to showcase the game.

Hardware used: Zybo Z7-10

Software used: Xilinx Vivado
