/*
 * straightLineTest1.c
 *
 *	This is a main() source file that inserts input into instructionToCommands.h. This test centres the vehicle on the top edge of the screen facing downwards.
 *	The destination is always on a straight line in front of the vehicle, but the distance is random.
 *
 *  Created on: Dec. 1, 2014
 *      Author: H. Zhang
 */
 
 #include "instructionToCommands.h"
 
 void main()
{
	char*** commands = NULL;

	int startX = 500;
	int startY = 0;
	int endX = 500;
	
	int endY = rand() % 1000;
	printf("The distance the car must travel is: %d\n", endY);
	
	int degree = 179;
	
	bool error = false;
	
	error = instructionToCommands(startX, startY, degree, endX, endY, &commands);
	
	if (!error)
	{
		printf("Error occurred when converting instructions to commands!\n");
	}
	
    int a = 0;
	int b = 0;
	
	printf("\n");
	
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