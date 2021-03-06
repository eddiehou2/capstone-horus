/*
 * instructionToCommands.c
 *
 *	These are the function definitions used to convert a user instruction into one or several hexadecimal commands.
 *
 *  Created on: Nov 16, 2014
 *      Author: H. Zhang
 */
 
#include "instructionToCommands.h"
		
#include <string.h>
		
int calculateTurn(int startX, int startY, int endX, int endY, int degree)
{
	double angle = 0; //Angle from origin to destination

	double dX = endX - startX;	//Displacement
	double dY = endY - startY;
	
	//Calculate the destination angle
	
	//No movement
	if (0 == dX && 0 == dY) angle = 0;
	//Straight up
	else if (0 == dX && 0 > dY) angle = 0;
	//First quadrant
	else if (0 < dX && 0 > dY) angle = atan(dX/dY) * 180.0 / M_PI;
	//To the right
	else if (0 < dX && 0 == dY) angle = 89;
	//Second quadrant
	else if (0 < dX && 0 < dY) angle = 89 + atan(dY/dX) * 180.0 / M_PI;
	//Straight down
	else if (0 == dX && 0 < dY) angle = 179;
	//Third quadrant
	else if (0 > dX && 0 < dY) angle = 179 + atan(dX/dY) * 180.0 / M_PI;
	//To the left
	else if (0 > dX && 0 == dY) angle = 269;
	//Fourth quadrant
	else if (0 > dX && 0 > dY) angle = 269 + atan(dY/dX) * 180.0 / M_PI;
	
	//Convert destination angle back to int
	int destAngle = round(angle);
	
	//Calculate the turning angle, from -180 (left 180 degrees) to 180 (right 180 degrees)
	int turnAngle = 0;
	if ((destAngle - degree) > 180) turnAngle = (destAngle - degree) - 360; 
	else if ((destAngle - degree) < -180) turnAngle =(destAngle - degree) + 360;
	else turnAngle = destAngle - degree;
	
	return turnAngle;
}

int calculateDist(int startX, int startY, int endX, int endY)
{
	double dX = abs(endX - startX); //Displacement
	double dY = abs(endY - startY);
	
	return round(sqrt(pow(dX, 2.0) + pow(dY, 2.0)));
}

bool instructionToCommands(int startX, int startY, int degree, int endX, int endY, char**** commands)
{
	printf("\nEntered instuctionToCommands! Parameters are:\n");
	printf("startX: %d, startY: %d, degree: %d, endX: %d, endY: %d\n", startX, startY, degree, endX, endY);

	bool result = false;
	
	//Allocate the 2-D array of strings
	*commands = malloc(MAX_COMMANDS * sizeof(char**));
	int m, n;
	for (m = 0; m < MAX_COMMANDS; m++) 
	{
		(*commands)[m] = malloc(3 * sizeof(char*));
		for (n = 0; n < 3; n++)
		{
			(*commands)[m][n] = malloc(INSTRUCTION_SIZE * sizeof(char));
            strcpy((*commands)[m][n], "END0");
		}
	}
	
	printf("MAX_COMMANDS: %d\n", MAX_COMMANDS);
	
//Turning Phase
	int turningAngle = calculateTurn(startX, startY, endX, endY, degree);
	printf("The turn angle is: %d\n", turningAngle);
	
	//Convert -180 to 180 scale turn value to an absolute value + a direction
	int direction = 0;
	if (turningAngle > 0) direction = 1;
	turningAngle = abs(turningAngle);
	
	//Calculate how long the turning phase lasts
	int time = round((turningAngle/15) * INTERVAL_15);
	if (10 > time) time = 10;
	
	//Add instruction: Turn sensitivity MAX, speed 32, time milliseconds
	if (1 == direction) strcpy((*commands)[0][0], "81 3f");		//Right turn
	else strcpy((*commands)[0][0], "81 40");						//Left turn
	strcpy((*commands)[0][1], "82 1f");
	sprintf((*commands)[0][2], "%d", time);
	
//Linear Phase
	int distance = calculateDist(startX, startY, endX, endY);
	printf("Distance = %d\n", distance);
	
	//Add instruction: Turn sensitivity 0, SPEED, distance*10 milliseconds
	//We're assuming here that it takes 10 milliseconds to travel 1 unit (it probably doesn't)
	int trueDist = distance*10;

	//This shouldn't happen (and thus we'd probably need to recalibrate the speed, as its taking >10 seconds for one movement command)
	if (9999 < trueDist) trueDist = 9000;
	
	strcpy((*commands)[1][0], "81 00");
	strcpy((*commands)[1][1], "82 1f");
	sprintf((*commands)[1][2], "%d", trueDist % 9999);
	
	if (NULL != (*commands)) result = true;
	
	printf("Exiting instructionToCommands!\n");
	return result;
} 


