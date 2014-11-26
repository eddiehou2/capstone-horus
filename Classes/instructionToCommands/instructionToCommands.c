/*
 * instructionToCommands.c
 *
 *  Created on: Nov 16, 2014
 *      Author: H. Zhang
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <string.h>

#define INSTRUCTION_SIZE 	4
#define SPEED 				32		//Half speed
#define INTERVAL_15			200		//It is assumed that it takes 200 milliseconds to turn 15 degrees
#define XMAX				1000 	
#define YMAX				1000

//At SPEED = 32, it takes approx. 100 milliseconds to travel 10 units
//An instruction can hold a maximum of 9999 milliseconds
//Therefore, a single instruction can move the car 9990 units.
//Thus, we calculate the maximum distance that can be travelled on the grid
//We add 3 to MAX_COMMANDS because:
//	1) To account for the fact that the conversion to int may floor the value (and ceil() is unreliable)
//	2) To account for spillover: If the distance travelled is 1000, 990 is stored in one instruction and 10 is stored in another
//	3) To add a blank set of instructions to write END0 to, for instruction parsing
#define MAX_COMMANDS		(int)((round(sqrt(pow(XMAX, 2.0) + pow(YMAX, 2.0))) / 1000.0) + 3.0)			

/* Given starting coordinates and orientation, along with destination coordinates, find required turning angle
 * @startX	The starting position X coordinate. Increases as position moves towards the right.
 * @startY	The starting position Y coordinate. Increases as position moves downwards.
 * @endX	The destination X coordinate.
 * @endY	The destination Y coordinate.
 * @degree	The orientation of the vehicle at starting position. Range 0-359, with 0 as straight up and incrementing clockwise.
 *
 * Returns:	Integer value of angle between a vector denoting current facing and a vector that passes through destination point.
 */
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

/* Calculate distance given starting and end coordinates
 * @startX	The starting position X coordinate. Increases as position moves towards the right.
 * @startY	The starting position Y coordinate. Increases as position moves downwards.
 * @endX	The destination X coordinate.
 * @endY	The destination Y coordinate.
 *
 * Returns:	Integer value of distance between two points.
 */
int calculateDist(int startX, int startY, int endX, int endY)
{
	double dX = abs(endX - startX); //Displacement
	double dY = abs(endY - startY);
	
	return round(sqrt(pow(dX, 2.0) + pow(dY, 2.0)));
}

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
bool instructionToCommands(int startX, int startY, int degree, int endX, int endY, char**** commands)
{
	printf("Entered instuctionToCommands! Parameters are:\n");
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
	
	int time = round((turningAngle/15) * INTERVAL_15);
	//Add instruction: Turn sensitivity MAX, speed 32, time milliseconds
	if (1 == direction) strcpy((*commands)[0][0], "813f");		//Right turn
	else strcpy((*commands)[0][0], "8140");						//Left turn
	strcpy((*commands)[0][1], "821f");
	sprintf((*commands)[0][2], "%d", time);
	
//Linear Phase
	int distance = calculateDist(startX, startY, endX, endY);
	printf("Distance = %d\n", distance);
	
	//Add instruction: Turn sensitivity 0, SPEED, distance*10 milliseconds
	int trueDist = distance*10;

	int i;
	for (i = 1; i <= trueDist/9999 + 1; i++)	//The +1 is for the spillover case
	{
        printf("%d\n", i);
        printf("%d\n", trueDist/9999);
        //This is for the last loop
        //In the case that trueDist > 9999, the remainder is held in this series of instructions
        //For this case, the distance will always be < 9999
		if (trueDist/9999 + 1 == i)
		{
			strcpy((*commands)[i][0], "8100");
			strcpy((*commands)[i][1], "821f");
			sprintf((*commands)[i][2], "%d", trueDist % 9999);
		}
        else
		{
		    strcpy((*commands)[i][0], "8100");
		    strcpy((*commands)[i][1], "821f");
		    strcpy((*commands)[i][2], "9999");
        }
	}
	
	if (NULL != (*commands)) result = true;
	
	printf("Exiting instructionToCommands!\n");
	return result;
} 

void main()
{
    char*** commands = NULL;

    while(true)
    {
	    int startX = 0;
	    int startY = 0;
	    int endX = 0;
	    int endY = 0;
	    int degree = 0;

	    bool error = false;

        printf("Current X coordinate: ");
        scanf("%d", &startX);
        printf("Current Y coordinate: ");
        scanf("%d", &startY);
        printf("Destination X coordinate: ");
        scanf("%d", &endX);
        printf("Destination Y coordinate: ");
        scanf("%d", &endY);
        printf("Facing direction: ");
        scanf("%d", &degree);
	
	    error = instructionToCommands(startX, startY, degree, endX, endY, &commands);
	
	    if (!error)
	    {
		    printf("Error occurred when converting instructions to commands!\n");
	    }
	
        int a = 0;
	    int b = 0;
		
	    while (strcmp("END0", commands[a][b]) != 0)
	    {
		    for (b = 0; b < 3; b++)
		    {
			    if (NULL == commands) printf("WTF\n");	
			    else printf("%s\n", commands[a][b]);
		    }
    
            b = 0;

            a++;
	    }
    }
}
