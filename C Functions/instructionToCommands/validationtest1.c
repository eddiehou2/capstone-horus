/*
 * validationTest1.c
 *
 *	This a main() source file that is the standard validation test by inspection. The input parameters (start and destination coordinates, facing) are set my the user.
 *
 *  Created on: Dec. 1, 2014
 *      Author: H. Zhang
 */

#include "instructionToCommands.h"

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
}