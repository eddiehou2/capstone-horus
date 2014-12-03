/*
 * instructionToCommands.h
 *
 *	These are the function prototypes used to convert a user instruction into one or several hexadecimal commands.
 *
 *  Created on: Dec. 1, 2014
 *      Author: H. Zhang
 */

#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <math.h>

#define INSTRUCTION_SIZE 	4
#define SPEED 				32		//Half speed
#define INTERVAL_15			200		//It is assumed that it takes 200 milliseconds to turn 15 degrees
#define XMAX				1000 	
#define YMAX				1000

//Some things to keep in mind:
//An instruction can hold a maximum of 9999 milliseconds
//Therefore, a single instruction can move the car 9990 units.
//We set MAX_COMMANDS to 3 because:
//	1) To send a turning set of commands (turn x degress, forward y degrees, time z seconds)
//	2) To send a move forward set of commands (turn 0 degrees, forward x degrees, time z seconds)
//	3) To add a blank set of instructions to write END0 to, for instruction parsing
#define MAX_COMMANDS		3
 
 /* Given starting coordinates and orientation, along with destination coordinates, find required turning angle
 * @startX	The starting position X coordinate. Increases as position moves towards the right.
 * @startY	The starting position Y coordinate. Increases as position moves downwards.
 * @endX	The destination X coordinate.
 * @endY	The destination Y coordinate.
 * @degree	The orientation of the vehicle at starting position. Range 0-359, with 0 as straight up and incrementing clockwise.
 *
 * Returns:	Integer value of angle between a vector denoting current facing and a vector that passes through destination point.
 */
 int calculateTurn(int startX, int startY, int endX, int endY, int degree);
 
 /* Calculate distance given starting and end coordinates
 * @startX	The starting position X coordinate. Increases as position moves towards the right.
 * @startY	The starting position Y coordinate. Increases as position moves downwards.
 * @endX	The destination X coordinate.
 * @endY	The destination Y coordinate.
 *
 * Returns:	Integer value of distance between two points.
 */
int calculateDist(int startX, int startY, int endX, int endY);

/* Given starting coordinates and orientation, along with destination coordinates, find required turning angle
 * @startX		The starting position X coordinate. Increases as position moves towards the right.
 * @startY		The starting position Y coordinate. Increases as position moves downwards.
 * @endX		The destination X coordinate.
 * @endY		The destination Y coordinate.
 * @degree		The orientation of the vehicle at starting position. Range 0-359, with 0 as straight up and incrementing clockwise.
 * @commands	Pointer in which a 2-D array of strings is to be constructed and assigned. These are the commands meant for hardware.
 *
 * Returns:		True if conversion is successful, false otherwise.
 */
bool instructionToCommands(int startX, int startY, int degree, int endX, int endY, char**** commands);

