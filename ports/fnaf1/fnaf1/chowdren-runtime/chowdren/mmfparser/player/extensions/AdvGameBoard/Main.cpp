/*

Source from Andos, ALSO licensed under zlib!

*/

#include	"Main.h"

#define RFUNCTION_GENERATEEVENT 123

void callRunTimeFunction(LPRDATA rdPtr, int type, int id, int what)
{
    rdPtr->generate(rdPtr, id);
}

void changePosition(LPRDATA rdPtr, int fixed, int x, int y)
{
    rdPtr->changePosition(rdPtr, fixed, x, y);
}

void detach(LPRDATA rdPtr)
{
	delete [] rdPtr->Board;
	delete [] rdPtr->StateBoard;
	delete [] rdPtr->FixedBoard;
	delete [] rdPtr->CellValues;

	rdPtr->Bricks.clear();
	rdPtr->Looped.clear();
}

LPRDATA create()
{
    return new RUNDATA;
}

void initialize(LPRDATA rdPtr)
{
	rdPtr->SwapBrick1 = 0;
	rdPtr->SwapBrick2 = 0;
	rdPtr->LoopIndex = 0;
	rdPtr->LoopedIndex = 0;

	int size = rdPtr->BSizeX*rdPtr->BSizeY;
	rdPtr->Board = new int[size];
	rdPtr->StateBoard = new int[size];
	rdPtr->FixedBoard = new int[size];
	rdPtr->CellValues = new int[size];
	rdPtr->DeletedFixed = -1;
	rdPtr->DeletedX = -1;
	rdPtr->DeletedY = -1;

	rdPtr->MovedFixed = -1;
	rdPtr->MovedNewX = -1;
	rdPtr->MovedNewY = -1;

	rdPtr->MovedOldX = -1;
	rdPtr->MovedOldY = -1;


	for(int i= 0;i<size;i++)
	{
		rdPtr->Board[i]=0;
		rdPtr->StateBoard[i]=0;
		rdPtr->FixedBoard[i]=0;
		rdPtr->CellValues[i]=0;
	}
}

bool CHECKPOS(LPRDATA rdPtr, int nPos)
{
	if (nPos>=0 && nPos<rdPtr->BSizeX*rdPtr->BSizeY)
		return true;
	return false;
}

int getPos(LPRDATA rdPtr, int x,int y)
{
	if( (x < rdPtr->BSizeX) && (x>=0) && (y < rdPtr->BSizeY) && (y>=0) )
		return rdPtr->BSizeX*y+x;
	else return -1;
}

int check(LPRDATA rdPtr, int pos)
{
	int size = rdPtr->BSizeX * rdPtr->BSizeY;
	if( pos < 0 || pos >= size)
		return -1;
	else return pos;	
}

int getXbrick(LPRDATA rdPtr, int pos)
{
	return pos % rdPtr->BSizeX;
}

int getYbrick(LPRDATA rdPtr, int pos)
{
	return pos / rdPtr->BSizeX;
}

int getBrick(LPRDATA rdPtr, int x,int y)
{
	if( (x < rdPtr->BSizeX) && (x>=0) && (y < rdPtr->BSizeY) && (y>=0) )
		return rdPtr->Board[ rdPtr->BSizeX*y+x ];
	else return -1;
}

int getBrickAtPos(LPRDATA rdPtr, int pos)
{
	if ( CHECKPOS(rdPtr,pos) )
		return rdPtr->Board[ pos ];
	return 0;
}

int getFixed(LPRDATA rdPtr, int x,int y)
{
	if( (x < rdPtr->BSizeX) && (x>=0) && (y < rdPtr->BSizeY) && (y>=0) )
		return rdPtr->FixedBoard[ rdPtr->BSizeX*y+x ];
	else return -1;
}

void setBrick(LPRDATA rdPtr, int x, int y, int value)
{
	if ( CHECKPOS(rdPtr,getPos(rdPtr,x,y)) )
		rdPtr->Board[ getPos(rdPtr,x,y) ] = value;
}

void setFixed(LPRDATA rdPtr, int x, int y, int value)
{
	if ( CHECKPOS(rdPtr,getPos(rdPtr,x,y)) )
		rdPtr->FixedBoard[ getPos(rdPtr,x,y) ] = value;
}

void MoveBrick(LPRDATA rdPtr, int sourceX, int sourceY, int destX, int destY )
{

	if((getPos(rdPtr,destX,destY) != -1) && (getPos(rdPtr,sourceX,sourceY) != -1))
	{
		bool triggerdeletedflag = false;
		bool triggermovedflag = false;
	
		if(rdPtr->TriggerMoved)
		{
			rdPtr->MovedFixed = getFixed(rdPtr,sourceX,sourceY);
			rdPtr->MovedNewX = destX;
			rdPtr->MovedNewY = destY;
			rdPtr->MovedOldX = sourceX;
			rdPtr->MovedOldY = sourceY;
			triggermovedflag = true;
		}
		
		if(rdPtr->TriggerDeleted && getBrick(rdPtr,destX,destY)!=0)
		{
			rdPtr->DeletedFixed = getFixed(rdPtr,destX,destY);
			rdPtr->DeletedX = destX;
			rdPtr->DeletedY = destY;
			triggerdeletedflag = true;
		}

		// Move the brick
		if ( CHECKPOS(rdPtr,getPos(rdPtr,destX,destY)) && CHECKPOS(rdPtr,getPos(rdPtr,sourceX,sourceY)) )
		{
			rdPtr->Board[ getPos(rdPtr,destX,destY) ] = rdPtr->Board[ getPos(rdPtr,sourceX,sourceY) ];
			rdPtr->Board[ getPos(rdPtr,sourceX,sourceY) ] = 0;

			if(rdPtr->MoveFixed)
			{
				rdPtr->FixedBoard[ getPos(rdPtr,destX,destY) ] = rdPtr->FixedBoard[ getPos(rdPtr,sourceX,sourceY) ];
				rdPtr->FixedBoard[ getPos(rdPtr,sourceX,sourceY) ] = 0;
			}
		}

		if(triggermovedflag)
			callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,8,0);	

		if(triggerdeletedflag)
			callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,9,0);	

	}
}

//////////////////////////////////////////////////////

void fall(LPRDATA rdPtr)
{
	for(int x=0;x<rdPtr->BSizeX;x++)
	{
		for(int y=rdPtr->BSizeY-2;y>=0;y--)
		{
			if(getBrick(rdPtr,x,y+1) == 0)
				MoveBrick(rdPtr,x,y,x,y+1);
		}
	}
}

void fallUP(LPRDATA rdPtr)
{
	for(int x=0;x<rdPtr->BSizeX;x++)
	{
		for(int y=1;y<=rdPtr->BSizeY-1;y++)
		{
			if(getBrick(rdPtr,x,y-1) == 0)
				MoveBrick(rdPtr,x,y,x,y-1);
		}
	}
}

void fallLEFT(LPRDATA rdPtr)
{
	for(int y=0;y<=rdPtr->BSizeY;y++)
	{
		for(int x=1;x<rdPtr->BSizeX;x++)
		{
			if(getBrick(rdPtr,x-1,y) == 0)
				MoveBrick(rdPtr,x,y,x-1,y);


		}
	}
}


void fallRIGHT(LPRDATA rdPtr)
{
	for(int y=0;y<=rdPtr->BSizeY;y++)
	{
		for(int x=rdPtr->BSizeX-2;x>=0;x--)
		{
			if(getBrick(rdPtr,x+1,y) == 0)
				MoveBrick(rdPtr,x,y,x+1,y);
		}
	}
}

//============================================================================
//
// CONDITION ROUTINES
// 
// ============================================================================


long conOnFoundConnected(LPRDATA rdPtr, long param1, long param2)
{
	return true;
}


long conOnFoundBrick(LPRDATA rdPtr, long param1, long param2)
{
	return true;
}

long conOnFoundLooped(LPRDATA rdPtr, long param1, long param2)
{
	return true;
}

long conOnNoFoundConnected(LPRDATA rdPtr, long param1, long param2)
{
	return true;
}
	

long conBrickCanFallUp(LPRDATA rdPtr, long param1, long param2)
{
	int tempbrick = 0;
	int currentbrick = getBrick(rdPtr,param1,param2);
	int belowbrick = getBrick(rdPtr,param1,param2+1);

	if( belowbrick == -1 || currentbrick == 0 || currentbrick == -1)
		return false;

	for(int i = param2; i>=0 ; i--)
	{
		tempbrick = getBrick(rdPtr,param1,i);

		if(tempbrick == 0)
			return true;
	}
	return false;
}


long conBrickCanFallDown(LPRDATA rdPtr, long param1, long param2)
{
	int tempbrick = 0;
	int currentbrick = getBrick(rdPtr,param1,param2);
	int belowbrick = getBrick(rdPtr,param1,param2+1);

	if( belowbrick == -1 || currentbrick == 0 || currentbrick == -1)
		return false;

	for(int i = param2; i<=rdPtr->BSizeY-1 ; i++)
	{
		tempbrick = getBrick(rdPtr,param1,i);

		if(tempbrick == 0)
			return true;
	}
	return false;
}


long conBrickCanFallLeft(LPRDATA rdPtr, long param1, long param2)
{
	int tempbrick = 0;
	int currentbrick = getBrick(rdPtr,param1,param2);
	int belowbrick = getBrick(rdPtr,param1-1,param2);

	if( belowbrick == -1 || currentbrick == 0 || currentbrick == -1)
		return false;

	for(int i = param1; i>=0 ; i--)
	{
		tempbrick = getBrick(rdPtr,i,param2);

		if(tempbrick == 0)
			return true;
	}
	return false;
}


long conBrickCanFallRight(LPRDATA rdPtr, long param1, long param2)
{
	int tempbrick = 0;
	int currentbrick = getBrick(rdPtr,param1,param2);
	int belowbrick = getBrick(rdPtr,param1+1,param2);

	if( belowbrick == -1 || currentbrick == 0 || currentbrick == -1)
		return false;

	for(int i = param1; i<=rdPtr->BSizeX-1 ; i++)
	{
		tempbrick = getBrick(rdPtr,i,param2);

		if(tempbrick == 0)
			return true;
	}
	return false;
}


long conOnBrickMoved(LPRDATA rdPtr, long param1, long param2)
{
	return true;
}

long conOnBrickDeleted(LPRDATA rdPtr, long param1, long param2)
{
	return true;
}


long conIsEmpty(LPRDATA rdPtr, long param1, long param2)
{
	if(getBrick(rdPtr,param1,param2) == 0)
		return true;
	else
		return false;

	return false;
}



//============================================================================
//
// ACTIONS ROUTINES
// 
// ============================================================================



//////////////////////////////////////////////

short actSetBrick(LPRDATA rdPtr, long p1, long p2, long p3)
{
	setBrick(rdPtr,p1,p2,p3);
	return 0;
}

short actClear(LPRDATA rdPtr, long param1, long param2)
{
	int size = rdPtr->BSizeX*rdPtr->BSizeY;
	for(int i= 0;i<size;i++)
		rdPtr->Board[i]=0;
	return 0;
}

short actSetBoadSize(LPRDATA rdPtr, long param1, long param2)
{
	delete [] rdPtr->Board; //Deletes the old array first
	delete [] rdPtr->StateBoard;
	delete [] rdPtr->FixedBoard;
	delete [] rdPtr->CellValues;
	rdPtr->BSizeX = param1; //Update size
	rdPtr->BSizeY = param2;
	int size = rdPtr->BSizeX*rdPtr->BSizeY;
	rdPtr->Board = new int[size];  //Create new array
	rdPtr->StateBoard = new int[size];
	rdPtr->FixedBoard = new int[size];
	rdPtr->CellValues = new int[size];
	for(int i= 0;i<size;i++)
	{//Clear array
		rdPtr->Board[i]=0;
		rdPtr->StateBoard[i]=0;
		rdPtr->FixedBoard[i]=0;
		rdPtr->CellValues[i]=0;
	}
	return 0;
}

short actSetMinConnected(LPRDATA rdPtr, long param1, long param2)
{
	rdPtr->MinConnected = param1;
	return 0;
}



/////////////////////////////////////////////////////////////////////////////////////

short actSearchHorizontal(LPRDATA rdPtr, long param1, long param2)
{
	int SearchBrick = param1;
	int MinConnected = rdPtr->MinConnected;
	rdPtr->SearchBrickType = SearchBrick;
	int SizeX = rdPtr->BSizeX;
	int SizeY = rdPtr->BSizeY;
	int Found = 0;
	rdPtr->Bricks.clear();
	int FoundTotal = 0;

	for(int y = 0; y<SizeY ; y++)
	{
		Found = 0;
		rdPtr->Bricks.clear();

		for(int x = 0; x<SizeX ; x++)
		{
			if( getBrick(rdPtr, x,y) == SearchBrick )
			{
				Found++;
				if(CHECKPOS(rdPtr,getPos(rdPtr,x,y)) && rdPtr->StateBoard[getPos(rdPtr, x,y)] == 0)
					rdPtr->Bricks.push_back(getPos(rdPtr, x,y));
			}
			else
			{
				if(Found >= MinConnected)
				{
					callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,0,0);
					FoundTotal++;
				} 
				Found = 0;
				rdPtr->Bricks.clear();
			}
		}
		if(Found >= MinConnected)
		{
			callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,0,0);
			FoundTotal++;
		}
		Found = 0;
		rdPtr->Bricks.clear();
	}

	if(FoundTotal==0)
		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,3,0);

	return 0;
}



short actSearchVertical(LPRDATA rdPtr, long param1, long param2)
{
	int SearchBrick = param1;
	int MinConnected = rdPtr->MinConnected;
	rdPtr->SearchBrickType = SearchBrick;
	int SizeX = rdPtr->BSizeX;
	int SizeY = rdPtr->BSizeY;
	int Found = 0;
	rdPtr->Bricks.clear();
	int FoundTotal = 0;

	for(int x = 0; x<SizeX ; x++)
	{
		Found = 0;
		rdPtr->Bricks.clear();

		for(int y = 0; y<SizeY ; y++)
		{
			if( getBrick(rdPtr, x,y) == SearchBrick )
			{
				Found++;
				if ( CHECKPOS(rdPtr,getPos(rdPtr,x,y)) )
				{
					if(rdPtr->StateBoard[getPos(rdPtr, x,y)] == 0)
					{
						rdPtr->Bricks.push_back(getPos(rdPtr, x,y));
					}
				}
			}
			else
			{	//Trigger condition
				if(Found >= MinConnected){		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,0,0);	FoundTotal++;	} 
				Found = 0;
				rdPtr->Bricks.clear();
			}

		} // Trigger condition
		if(Found >= MinConnected){		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,0,0); FoundTotal++;	}
		Found = 0;
		rdPtr->Bricks.clear();
	}
	if(FoundTotal==0)
		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,3,0);

	return 0;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////




short actSearchDiagonalsLR(LPRDATA rdPtr, long param1, long param2)
{
	int searchbrick = param1;
	int around = rdPtr->BSizeY + rdPtr->BSizeX+2;
	int startoffX = 0;
	int startoffY = rdPtr->BSizeY;
	int loopindex = 0;
	int foundtotal = 0;
	int foundbricks = 0;

	for(int i = 0; i<around ; i++ )
	{
		if( startoffY == 0 )
			startoffX++;
		
		if( startoffY > 0 )
			startoffY--;

		loopindex = 0;
		rdPtr->Bricks.clear();
		foundbricks = 0;

		while( (getPos(rdPtr,startoffX+loopindex,startoffY+loopindex) != -1))
		{
			if(getBrick(rdPtr,startoffX+loopindex,startoffY+loopindex) == searchbrick)
			{
				foundbricks++;

				if ( CHECKPOS(rdPtr,getPos(rdPtr,startoffX+loopindex,startoffY+loopindex)) )
				{
					if(rdPtr->StateBoard[getPos(rdPtr, startoffX+loopindex,startoffY+loopindex)] == 0 )
						rdPtr->Bricks.push_back( getPos(rdPtr,startoffX+loopindex,startoffY+loopindex) );
				}
			}
			else
			{

				if(foundbricks >= rdPtr->MinConnected)
				{
					callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,0,0);
					foundtotal++;
				}

				rdPtr->Bricks.clear();
				foundbricks = 0;
			}

			loopindex++;
		}

		if(foundbricks >= rdPtr->MinConnected)
		{
			callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,0,0);
			foundtotal++;
		}

	}

	if(foundtotal == 0)
		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,3,0);

	return 0;
}


short actSearchDiagonalsRL(LPRDATA rdPtr, long param1, long param2)
{
	int searchbrick = param1;
	int around = rdPtr->BSizeY + rdPtr->BSizeX+2;
	int startoffX = rdPtr->BSizeX-1;
	int startoffY = rdPtr->BSizeY;
	int loopindex = 0;
	int foundtotal = 0;
	int foundbricks = 0;

	for(int i = 0; i<around ; i++ )
	{
		if( startoffY == 0 )
			startoffX--;
		
		if( startoffY > 0 )
			startoffY--;

		loopindex = 0;
		foundbricks = 0;
		rdPtr->Bricks.clear();

		while( (getPos(rdPtr,startoffX-loopindex,startoffY+loopindex) != -1))
		{
			if(getBrick(rdPtr,startoffX-loopindex,startoffY+loopindex) == searchbrick )
			{
				foundbricks++;

				if ( CHECKPOS(rdPtr,getPos(rdPtr,startoffX-loopindex,startoffY+loopindex)) )
				{
					if(rdPtr->StateBoard[getPos(rdPtr, startoffX-loopindex,startoffY+loopindex)] == 0)
						rdPtr->Bricks.push_back( getPos(rdPtr,startoffX-loopindex,startoffY+loopindex) );
				}
			}
			else
			{

				if(foundbricks >= rdPtr->MinConnected)
				{
					callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,0,0);
					foundtotal++;
				}

				rdPtr->Bricks.clear();
				foundbricks = 0;
			}

			loopindex++;
		}

		if(foundbricks >= rdPtr->MinConnected)
		{
			callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,0,0);
			foundtotal++;
		}

	}
	if(foundtotal == 0)
		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,3,0);

	return 0;
}


short actSearchConnected(LPRDATA rdPtr, long param1, long param2)
{
	int FindBrick = getBrick(rdPtr,param1,param2);
	int size = rdPtr->BSizeX*rdPtr->BSizeY;
	int FoundTotal = 0;

	int * Used = new int[size];
	for( int clear=0; clear < size; clear++) Used[clear]=0;

	vector <int> BrickList;
	BrickList.push_back( getPos(rdPtr,param1,param2));

	if ( CHECKPOS(rdPtr,getPos(rdPtr,param1,param2)) )
		Used[ getPos(rdPtr,param1,param2) ] = 1;

	rdPtr->Bricks.clear();
	rdPtr->Bricks.push_back( getPos(rdPtr,param1,param2) );

	int currentbrick =0;
	int currentX = 0;
	int currentY = 0;

	int offsetX[] = {0,-1,1,0};
	int offsetY[] = {-1,0,0,1};

	//char * temp ="";

	while( BrickList.size() > 0)
	{
		currentX = getXbrick(rdPtr,BrickList[0]);
		currentY = getYbrick(rdPtr,BrickList[0]);
			for(int dir = 0;  dir<4; dir++) //Loop around brick
			{
				currentbrick = getPos( rdPtr, currentX + offsetX[dir], currentY + offsetY[dir]   );
				if ( CHECKPOS(rdPtr,currentbrick) )
				{
					if( (rdPtr->Board[currentbrick] == FindBrick) && (Used[currentbrick]==0) && (currentbrick != -1 ) )
					{
						BrickList.push_back(currentbrick);
						rdPtr->Bricks.push_back(currentbrick);
						Used[currentbrick] = 1;
					}
				}
			}
			BrickList.erase(BrickList.begin());
	}


	if(rdPtr->Bricks.size() >= rdPtr->MinConnected ){		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,0,0); FoundTotal++;		} 

	BrickList.clear();
	delete [] Used;

	if(FoundTotal==0)
		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,3,0);

	return 0;
}

short actDeleteHorizonal(LPRDATA rdPtr, long param1, long param2)
{
	int size = rdPtr->BSizeX*rdPtr->BSizeY;

	for(int del = 0; del<rdPtr->BSizeX; del++)
	{
		if ( CHECKPOS(rdPtr,getPos(rdPtr,del,param1)) )
		{
			bool triggerdeletedflag = false;
			if(rdPtr->TriggerDeleted)
			{
				rdPtr->DeletedFixed = rdPtr->FixedBoard[getPos(rdPtr,del,param1)];
				rdPtr->DeletedX = del;
				rdPtr->DeletedY = param1;
				triggerdeletedflag = true;
			}

			rdPtr->Board[getPos(rdPtr,del,param1)] = 0;
			if(rdPtr->MoveFixed)
				rdPtr->FixedBoard[getPos(rdPtr,del,param1)] = 0;

			if(triggerdeletedflag)
				callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,9,0);
		}
	}

	if(param2 == 1) //MOVE ABOVE DOWNWARDS
	{
		for(int udX = 0; udX<rdPtr->BSizeX; udX++)
		{
			for(int udY = param1-1; udY >= 0; udY--)
				MoveBrick(rdPtr,udX,udY,udX,udY+1);
		}
	}

	if(param2 == 2) //MOVE BELOW UPWARDS
	{
		for(int udX = 0; udX<rdPtr->BSizeX; udX++)
		{
			for(int udY = param1+1; udY < rdPtr->BSizeY; udY++)
				MoveBrick(rdPtr,udX,udY,udX,udY-1);
		}
	}

	return 0;
}

short actDeleteVertical(LPRDATA rdPtr, long param1, long param2)
{

	int size = rdPtr->BSizeX*rdPtr->BSizeY;

	for(int del = 0; del<rdPtr->BSizeY; del++)
	{
		if ( CHECKPOS(rdPtr,getPos(rdPtr,param1,del)) )
		{
			bool triggerdeletedflag = false;
			if(rdPtr->TriggerDeleted)
			{
				rdPtr->DeletedFixed = rdPtr->FixedBoard[getPos(rdPtr,param1,del)];
				rdPtr->DeletedX = param1;
				rdPtr->DeletedY = del;
				triggerdeletedflag = true;
			}

			rdPtr->Board[getPos(rdPtr,param1,del)] = 0;
			if(rdPtr->MoveFixed)
				rdPtr->FixedBoard[getPos(rdPtr,param1,del)] = 0;

			if(triggerdeletedflag)
				callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,9,0);
		}
	}	
		
	if(param2 == 1) //MOVE LEFT TO RIGHT ->-> ||
	{
		for(int lrY = 0; lrY<rdPtr->BSizeY; lrY++)
		{
			for(int lrX = param1-1; lrX >= 0; lrX--)
				MoveBrick(rdPtr,lrX,lrY,lrX+1,lrY);
		}
	}
	if(param2 == 2) //MOVE RIGHT TO LEFT   || <-<-
	{
		for(int lrY = 0; lrY<rdPtr->BSizeY; lrY++)
		{
			for(int lrX = param1+1; lrX<rdPtr->BSizeX; lrX++)
				MoveBrick(rdPtr,lrX,lrY,lrX-1,lrY);
		}
	}
	return 0;
}

short actSwap(LPRDATA rdPtr, long p1, long p2, long p3, long p4)
{
	rdPtr->SwapBrick1 = getPos(rdPtr,p1,p2);  //Brick 1
	rdPtr->SwapBrick2 = getPos(rdPtr,p3,p4);  //Brick 2

	if ( CHECKPOS(rdPtr,rdPtr->SwapBrick1) && CHECKPOS(rdPtr,rdPtr->SwapBrick2) )
	{
		int temp = rdPtr->Board[ rdPtr->SwapBrick1 ];
		int tempfixed = rdPtr->FixedBoard[rdPtr->SwapBrick1];

		rdPtr->Board[ rdPtr->SwapBrick1 ] = rdPtr->Board[ rdPtr->SwapBrick2 ];
		rdPtr->Board[ rdPtr->SwapBrick2 ] = temp;

		if(rdPtr->MoveFixed)
		{
			rdPtr->FixedBoard[ rdPtr->SwapBrick1 ] = rdPtr->FixedBoard[ rdPtr->SwapBrick2 ];
			rdPtr->FixedBoard[ rdPtr->SwapBrick2 ] = tempfixed;
		}
		
		if(rdPtr->TriggerMoved)
		{
			rdPtr->MovedFixed = rdPtr->FixedBoard[ rdPtr->SwapBrick1 ];
			rdPtr->MovedNewX = p1;
			rdPtr->MovedNewY = p2;
			rdPtr->MovedOldX = p3;
			rdPtr->MovedOldY = p4;
			callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,8,0);

			rdPtr->MovedFixed = rdPtr->FixedBoard[ rdPtr->SwapBrick2 ];
			rdPtr->MovedNewX = p3;
			rdPtr->MovedNewY = p4;
			rdPtr->MovedOldX = p1;
			rdPtr->MovedOldY = p2;
			callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,8,0);
		}
	}

	return 0;
}

short actUndoSwap(LPRDATA rdPtr, long param1, long param2)
{
	if ( CHECKPOS(rdPtr,rdPtr->SwapBrick1) && CHECKPOS(rdPtr,rdPtr->SwapBrick2) )
	{
		int temp = rdPtr->Board[ rdPtr->SwapBrick1 ];
		int tempfixed = rdPtr->FixedBoard[ rdPtr->SwapBrick1 ];

		rdPtr->Board[ rdPtr->SwapBrick1 ] = rdPtr->Board[ rdPtr->SwapBrick2 ];
		rdPtr->Board[ rdPtr->SwapBrick2 ] = temp;

		if(rdPtr->MoveFixed)
		{
			rdPtr->FixedBoard[ rdPtr->SwapBrick1 ] = rdPtr->FixedBoard[ rdPtr->SwapBrick2 ];
			rdPtr->FixedBoard[ rdPtr->SwapBrick2 ] = tempfixed;
		}

		if(rdPtr->TriggerMoved)
		{
			rdPtr->MovedFixed = rdPtr->FixedBoard[ rdPtr->SwapBrick1 ];
			rdPtr->MovedNewX = getXbrick(rdPtr,rdPtr->SwapBrick1);
			rdPtr->MovedNewY = getYbrick(rdPtr,rdPtr->SwapBrick1);
			rdPtr->MovedOldX = getXbrick(rdPtr,rdPtr->SwapBrick2);
			rdPtr->MovedOldY = getYbrick(rdPtr,rdPtr->SwapBrick2);
			callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,8,0);

			rdPtr->MovedFixed = rdPtr->FixedBoard[ rdPtr->SwapBrick2 ];
			rdPtr->MovedNewX = getXbrick(rdPtr,rdPtr->SwapBrick2);
			rdPtr->MovedNewY = getYbrick(rdPtr,rdPtr->SwapBrick2);
			rdPtr->MovedOldX = getXbrick(rdPtr,rdPtr->SwapBrick1);
			rdPtr->MovedOldY = getYbrick(rdPtr,rdPtr->SwapBrick1);
			callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,8,0);
		}
	}
	return 0;
}


short actDropX(LPRDATA rdPtr, long param1, long param2)
{
	for(int i=0;i<param1;i++)
		fall(rdPtr);
	return 0;
}

short actDropOne(LPRDATA rdPtr, long param1, long param2)
{
	fall(rdPtr);
	return 0;
}


short actMarkUsed(LPRDATA rdPtr, long param1, long param2)
{
	if ( CHECKPOS(rdPtr,getPos(rdPtr,param1,param2)) )
		rdPtr->StateBoard[ getPos(rdPtr,param1,param2) ] = 1;
	return 0;
}

short actDeleteMarked(LPRDATA rdPtr, long param1, long param2)
{
	int size = rdPtr->BSizeX*rdPtr->BSizeY;
	bool triggerdeleteflag = false;

	for(int i=0;i<size;i++)
	{
		triggerdeleteflag = false;
		if(rdPtr->StateBoard[i] == 1)
		{
			if(rdPtr->TriggerDeleted)
			{
				rdPtr->DeletedFixed = rdPtr->FixedBoard[i];
				rdPtr->DeletedX = getXbrick(rdPtr,i);
				rdPtr->DeletedY = getYbrick(rdPtr,i);
				triggerdeleteflag = true;
			}

			rdPtr->Board[i]=0;
			rdPtr->StateBoard[i]=0;

			if(rdPtr->MoveFixed)
				rdPtr->FixedBoard[i] = 0;

			if(triggerdeleteflag)
				callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,9,0);
		}
	}
	return 0;
}


short actLoopFoundBricks(LPRDATA rdPtr, long param1, long param2)
{
	for(int loop = 0; loop<rdPtr->Bricks.size();loop++)
	{
		rdPtr->LoopIndex = loop;
		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,1,0);
	}


	return 0;
}


short actSetFixedOfBrick(LPRDATA rdPtr, long p1, long p2, long p3)
{
	if ( CHECKPOS(rdPtr,getPos(rdPtr,p1,p2)) )
		rdPtr->FixedBoard[ getPos(rdPtr,p1,p2) ]  = p3; 
	return 0;
}


short actImportActives(LPRDATA rdPtr, long fixed, long bah)
{
	int size = rdPtr->BSizeX*rdPtr->BSizeY;
	if ( CHECKPOS(rdPtr,size-rdPtr->AddIncrement-1) )
		rdPtr->FixedBoard[size-rdPtr->AddIncrement-1] = fixed;
	rdPtr->AddIncrement++;
	return 0;
}


short actMarkCurrentSystem(LPRDATA rdPtr, long param1, long param2)
{
	for(int i=0;i<rdPtr->Bricks.size();i++)
	{
		if ( CHECKPOS(rdPtr,rdPtr->Bricks[i]) )
			rdPtr->StateBoard[rdPtr->Bricks[i]] = 1;
	}

	return 0;
}


short actMarkCurrentBrick(LPRDATA rdPtr, long param1, long param2)
{
	if ( CHECKPOS(rdPtr,rdPtr->Bricks[ rdPtr->LoopIndex ]) )
		rdPtr->StateBoard[ rdPtr->Bricks[ rdPtr->LoopIndex ] ] = 1;
	return 0;
}

/////////////////////////////////
/////////EXTRA LOOPING///////////
/////////////////////////////////


short actLoopEntireBoard(LPRDATA rdPtr, long param1, long param2)
{
	int size = rdPtr->BSizeX*rdPtr->BSizeY;
	rdPtr->Looped.clear();

	for(int i = 0; i<size; i++)
	{
		rdPtr->Looped.push_back(i);
	}
	
	for(int u = 0; u<rdPtr->Looped.size(); u++)
	{
		rdPtr->LoopedIndex = u;
		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,2,0);	
	}
	
	return 0;
}

short actLoopBoardOfType(LPRDATA rdPtr, long param1, long param2)
{
	int size = rdPtr->BSizeX*rdPtr->BSizeY;
	rdPtr->Looped.clear();

	for(int i = 0; i<size; i++)
	{
		if(rdPtr->Board[i] == param1)
			rdPtr->Looped.push_back(i);
	}
	for(int u = 0; u<rdPtr->Looped.size(); u++)
	{
		rdPtr->LoopedIndex = u;
		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,2,0);	
	}
	return 0;
}

short actLoopSorrounding(LPRDATA rdPtr, long param1, long param2)
{
	rdPtr->Looped.clear();

	int offsetX[] = {-1,0,1,-1,1,-1,0,1};
	int offsetY[] = {-1,-1,-1,0,0,1,1,1};

	for(int i = 0; i<8;i++)
	{
		if(getBrick(rdPtr , param1+offsetX[i] , param2+offsetY[i] ) != -1)
			rdPtr->Looped.push_back(  getPos(rdPtr , param1+offsetX[i] , param2+offsetY[i] )  );
	}

	for(int u = 0; u<rdPtr->Looped.size(); u++)
	{
		rdPtr->LoopedIndex = u;
		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,2,0);	
	}

	return 0;
}



short actLoopHozLine(LPRDATA rdPtr, long param1, long param2)
{
	rdPtr->Looped.clear();
	for(int i = 0; i<rdPtr->BSizeX; i++)
	{
			rdPtr->Looped.push_back( getPos(rdPtr,i,param1) );
	}

	for(int u = 0; u<rdPtr->Looped.size(); u++)
	{
		rdPtr->LoopedIndex = u;
		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,2,0);	
	}

	return 0;
}

short actLoopVerLine(LPRDATA rdPtr, long param1, long param2)
{
	rdPtr->Looped.clear();
	for(int i = 0; i<rdPtr->BSizeY; i++)
	{
			rdPtr->Looped.push_back( getPos(rdPtr,param1,i) );
	}

	for(int u = 0; u<rdPtr->Looped.size(); u++)
	{
		rdPtr->LoopedIndex = u;
		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,2,0);	
	}
	return 0;
}


/////

short actClearWithType(LPRDATA rdPtr, long param1, long param2)
{
	int size = rdPtr->BSizeX * rdPtr->BSizeY;

	for(int i = 0; i< size; i++)
		rdPtr->Board[i] = param1;

	return 0;
}

short actInsertBrick(LPRDATA rdPtr, long p1, long p2, long p3)
{
	int size = rdPtr->BSizeX * rdPtr->BSizeY;
	bool triggerdeletedflag = false;

	if(rdPtr->TriggerDeleted && rdPtr->Board[size-1]!=0)
	{
		rdPtr->DeletedFixed = rdPtr->FixedBoard[size-1];
		rdPtr->DeletedX = getXbrick(rdPtr,size-1);
		rdPtr->DeletedY = getYbrick(rdPtr,size-1);
		triggerdeletedflag = true;
	}

	for(int i = size-2 ; i> getPos(rdPtr,p1,p2) ; i--)
		MoveBrick(rdPtr,getXbrick(rdPtr,i),getYbrick(rdPtr,i),getXbrick(rdPtr,i)+1,getYbrick(rdPtr,i));

	if ( CHECKPOS(rdPtr,getPos(rdPtr,p1,p2)) )
	{
		rdPtr->Board[getPos(rdPtr,p1,p2)] = p3;
	
		if(rdPtr->MoveFixed)
			rdPtr->FixedBoard[getPos(rdPtr,p1,p2)]=0;
	}

	if(triggerdeletedflag && rdPtr->TriggerDeleted)
		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,9,0);	

	return 0;
}

short actSetOrigin(LPRDATA rdPtr, long param1, long param2)
{
	rdPtr->OriginX = param1;
	rdPtr->OriginY = param2;
	return 0;
}

short actSetCellDimensions(LPRDATA rdPtr, long param1, long param2)
{
	rdPtr->CellWidth = param1;
	rdPtr->CellHeight = param2;

	if(rdPtr->CellWidth==0)
		rdPtr->CellWidth = 1;

	if(rdPtr->CellHeight==0)
		rdPtr->CellHeight = 1;

	return 0;
}

short actMoveFixedON(LPRDATA rdPtr, long param1, long param2)
{
	rdPtr->MoveFixed = true;
	return 0;
}

short actMoveFixedOFF(LPRDATA rdPtr, long param1, long param2)
{
	rdPtr->MoveFixed = false;
	return 0;
}


short actMoveBrick(LPRDATA rdPtr, long p1, long p2, long p3, long p4)
{
	MoveBrick(rdPtr,p1,p2,p3,p4);
	
	return 0;
}

short actDropOneUp(LPRDATA rdPtr, long param1, long param2)
{
	fallUP(rdPtr);
	return 0;
}

short actDropOneLeft(LPRDATA rdPtr, long param1, long param2)
{
	fallLEFT(rdPtr);
	return 0;
}

short actDropOneRight(LPRDATA rdPtr, long param1, long param2)
{
	fallRIGHT(rdPtr);
	return 0;
}

short actDropXUp(LPRDATA rdPtr, long param1, long param2)
{
	for(int i = 0; i<param1 ; i++)
		fallUP(rdPtr);

	return 0;
}

short actDropXLeft(LPRDATA rdPtr, long param1, long param2)
{
	for(int i = 0; i<param1 ; i++)
		fallLEFT(rdPtr);

	return 0;
}

short actDropXRight(LPRDATA rdPtr, long param1, long param2)
{
	for(int i = 0; i<param1 ; i++)
		fallRIGHT(rdPtr);

	return 0;
}



short actSetCellValue(LPRDATA rdPtr, long p1, long p2, long p3)
{
	if(getPos(rdPtr,p1,p2) != -1)
		rdPtr->CellValues[getPos(rdPtr,p1,p2)] = p3;
	
	return 0;
}


short actDeleteBrick(LPRDATA rdPtr, long param1, long param2)
{
	if(rdPtr->TriggerDeleted)
	{
		rdPtr->DeletedFixed = getFixed(rdPtr,param1,param2);
		rdPtr->DeletedX = param1;
		rdPtr->DeletedY = param2;
	}

	setBrick(rdPtr,param1,param2,0);

	if(rdPtr->TriggerDeleted)
		callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,9,0);	

	return 0;
}

int wrapX( LPRDATA rdPtr, int shift )
{
	return (shift >= 0) ? (shift % rdPtr->BSizeX) : rdPtr->BSizeX + (shift % rdPtr->BSizeX);
}

int wrapY( LPRDATA rdPtr, int shift )
{
	return (shift >= 0) ? (shift % rdPtr->BSizeY) : rdPtr->BSizeY + (shift % rdPtr->BSizeY);
}


short actShiftHosLine(LPRDATA rdPtr, long param1, long param2)
{
	int * templine = new int[rdPtr->BSizeX];
	int * tempfixed = new int[rdPtr->BSizeX];
	int yline = param1;
	int shift = param2;


	//write to templine
	for(int i=0; i<rdPtr->BSizeX;i++)
	{
		templine[i] = getBrick(rdPtr,  wrapX(rdPtr,i-shift)  ,yline);
		tempfixed[i] = getFixed(rdPtr,  wrapX(rdPtr,i-shift)  ,yline);
	}

	for(int j = 0; j < rdPtr->BSizeX ; j++ )
	{
		if(rdPtr->TriggerMoved)
		{
			rdPtr->MovedOldX = j;
			rdPtr->MovedOldY = yline;
			rdPtr->MovedNewX = wrapX(rdPtr,j+shift);
			rdPtr->MovedNewY = yline;
			rdPtr->MovedFixed = getFixed(rdPtr,j,yline);
		}
			
		setBrick(rdPtr, j, yline, templine[j] );		
		
		if(rdPtr->MoveFixed)
			setFixed(rdPtr, j, yline, tempfixed[j] );

		if(rdPtr->TriggerMoved)
			callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,8,0);
	}

	delete [] templine;
	delete [] tempfixed;

	return 0;
}

short actShiftVerLine(LPRDATA rdPtr, long param1, long param2)
{
	int * templine = new int[rdPtr->BSizeY];
	int * tempfixed = new int[rdPtr->BSizeY];
	int xline = param1;
	int shift = param2;


	//write to templine
	for(int i=0; i<rdPtr->BSizeY;i++)
	{
		templine[i] = getBrick(rdPtr, xline, wrapY(rdPtr,i-shift));
		tempfixed[i] = getFixed(rdPtr, xline,  wrapY(rdPtr,i-shift));
	}

	for(int j = 0; j < rdPtr->BSizeY ; j++ )
	{
		if(rdPtr->TriggerMoved)
		{
			rdPtr->MovedOldX = xline;
			rdPtr->MovedOldY = j;
			rdPtr->MovedNewX = xline;
			rdPtr->MovedNewY = wrapY(rdPtr,j+shift);
			rdPtr->MovedFixed = getFixed(rdPtr,xline,j);
		}
			
		setBrick(rdPtr, xline, j, templine[j] );		
		
		if(rdPtr->MoveFixed)
			setFixed(rdPtr, xline, j, tempfixed[j] );

		if(rdPtr->TriggerMoved)
			callRunTimeFunction(rdPtr,RFUNCTION_GENERATEEVENT,8,0);
	}

	delete [] templine;
	delete [] tempfixed;

	return 0;
}

short actPositionBricks(LPRDATA rdPtr, long param1, long param2)
{
	int size = rdPtr->BSizeX*rdPtr->BSizeY;
	int fixed = 0;
	int posX = 0;
	int posY = 0;
	int checkfixed = 0;

	for(int i = 0 ; i < size ; i++)
	{
		fixed = rdPtr->FixedBoard[i];
		posX = getXbrick(rdPtr, i);
		posY = getYbrick(rdPtr, i);

		if(fixed > 0)
		{
            changePosition(rdPtr, fixed, 
                rdPtr->CellWidth * posX + rdPtr->OriginX,
                rdPtr->CellHeight * posY + rdPtr->OriginY);
		}
	}
	return 0;
}

//============================================================================
//
// EXPRESSIONS ROUTINES
// 
// ============================================================================


long expGetBrickAt(LPRDATA rdPtr, long p1, long p2)
{
	return getBrick(rdPtr,p1,p2);
}

long expGetXSize(LPRDATA rdPtr, long param1)
{
	return rdPtr->BSizeX;
}

long expGetYSize(LPRDATA rdPtr, long param1)
{
	return rdPtr->BSizeY;
}

long expGetNumBricksInSystem(LPRDATA rdPtr, long param1)
{
	return rdPtr->Bricks.size();
}

long expGetXofBrick(LPRDATA rdPtr, long p1)
{
	if(p1 < rdPtr->Bricks.size())
		return getXbrick(rdPtr, rdPtr->Bricks[p1] );
	else
		return -1;
}

long expGetYofBrick(LPRDATA rdPtr, long p1)
{

	if(p1 < rdPtr->Bricks.size())
		return getYbrick(rdPtr, rdPtr->Bricks[p1] );
	else
		return -1;
}

long expGetFoundBrickType(LPRDATA rdPtr, long param1)
{
	return rdPtr->SearchBrickType;
}

long expGetNumBricksInHozLine(LPRDATA rdPtr, long p1)
{
	int count = 0;

	for(int i=0;i<rdPtr->BSizeX;i++)
	{
		if( getBrick(rdPtr,i,p1) != 0 )
			count++;
	}
	return count;
}

long expGetNumBricksInVerLine(LPRDATA rdPtr, long p1)
{
	int count = 0;

	for(int i=0;i<rdPtr->BSizeY;i++)
	{
		if( getBrick(rdPtr,p1,i) != 0 )
			count++;
	}
	return count;
	return 0;
}

long expCountSorrounding(LPRDATA rdPtr, long p1, long p2, long p3)
{
	int offsetX[] = {-1,0,1,-1,1,-1,0,1};
	int offsetY[] = {-1,-1,-1,0,0,1,1,1};

	int count = 0;

	for(int i = 0; i<8;i++)
	{
		if(getBrick(rdPtr , p1+offsetX[i] , p2+offsetY[i] ) == p3)
			count++;
	}

	return count;
}


long expCountTotal(LPRDATA rdPtr, long param1)
{
	int count = 0;
	for(int i=0;i<rdPtr->BSizeX*rdPtr->BSizeY;i++)
	{
		if(rdPtr->Board[i] != 0)
			count++;
	}
	return count;
}



long expGetFoundBrickFixed(LPRDATA rdPtr, long p1)
{
	if(p1 < rdPtr->Looped.size())
	{
		if ( CHECKPOS(rdPtr,rdPtr->LoopIndex) )
			return rdPtr->FixedBoard[ rdPtr->LoopIndex ];
		else
			return -1;
	}
	else
		return -1;

}


//FOUND BRICKS IN NORMAL CONNECTION SEARCH


long expGetFoundXofBrick(LPRDATA rdPtr, long param1)
{
	return getXbrick(rdPtr, rdPtr->Bricks[rdPtr->LoopIndex] );
}
	

long expGetFoundYofBrick(LPRDATA rdPtr, long param1)
{
	return getYbrick(rdPtr, rdPtr->Bricks[rdPtr->LoopIndex] );
}	
	
long expGetTypeofBrick(LPRDATA rdPtr, long param1)
{
	return rdPtr->SearchBrickType;
}	

long expGetFixedOfBrick(LPRDATA rdPtr, long param1)
{
	if(rdPtr->LoopIndex < rdPtr->Bricks.size())
	{
		if ( CHECKPOS(rdPtr,rdPtr->Bricks[rdPtr->LoopIndex]) )
			return rdPtr->FixedBoard[ rdPtr->Bricks[rdPtr->LoopIndex] ];
		else
			return -1;
	}
	else
		return -1;
}


long expGetFixedAt(LPRDATA rdPtr, long p1, long p2)
{
	if(getPos(rdPtr,p1,p2) != -1)
		return rdPtr->FixedBoard[ getPos(rdPtr,p1,p2) ];
	else
		return -1;
}

long expLoopIndex(LPRDATA rdPtr, long param1)
{
	return rdPtr->LoopIndex;
}

long expFindXfromFixed(LPRDATA rdPtr, long p1)
{
	int size = rdPtr->BSizeX*rdPtr->BSizeY;

	for(int i=0; i < size ; i++ )
	{
		if( rdPtr->FixedBoard[i] == p1 )
		{
			return getXbrick(rdPtr,i);
		}
	}

	return -1;
}

long expFindYfromFixed(LPRDATA rdPtr, long p1)
{
	int size = rdPtr->BSizeX*rdPtr->BSizeY;

	for(int i=0; i < size ; i++ )
	{
		if( rdPtr->FixedBoard[i] == p1 )
		{
			return getYbrick(rdPtr,i);
		}
	}
	return -1;
}

long expFindBrickfromFixed(LPRDATA rdPtr, long p1)
{
	int size = rdPtr->BSizeX*rdPtr->BSizeY;

	for(int i=0; i < size ; i++ )
	{
		if( rdPtr->FixedBoard[i] == p1 )
		{
			return rdPtr->Board[i];
		}
	}
	return -1;
}

//GET DATA FROM LOOPED BRICKS (NON SEARCH)

long expGetLoopFoundXofBrick(LPRDATA rdPtr, long param1)
{
	return getXbrick(rdPtr, rdPtr->Looped[ rdPtr->LoopedIndex ] )  ;
}


long expGetLoopFoundYofBrick(LPRDATA rdPtr, long param1)
{
	return getYbrick(rdPtr, rdPtr->Looped[ rdPtr->LoopedIndex ] )  ;
}

long expGetLoopTypeofBrick(LPRDATA rdPtr, long param1)
{
	return getBrickAtPos(rdPtr, rdPtr->Looped[ rdPtr->LoopedIndex ] )  ;
}

long expGetLoopFoundBrickFixed(LPRDATA rdPtr, long param1)
{	
	if( rdPtr->LoopedIndex < rdPtr->Looped.size() )
	{
		if ( CHECKPOS(rdPtr,rdPtr->Looped[ rdPtr->LoopedIndex ]) )
			return rdPtr->FixedBoard[ rdPtr->Looped[ rdPtr->LoopedIndex ] ];
		else
			return -1;
	}
	else return -1;
}

long expLoopLoopIndex(LPRDATA rdPtr, long param1)
{
	return rdPtr->LoopedIndex;
}

long expGetXBrickFromX(LPRDATA rdPtr, long p1)
{
	return (p1 - rdPtr->OriginX)/rdPtr->CellWidth;
}

long expGetYBrickFromY(LPRDATA rdPtr, long p1)
{
	return (p1 - rdPtr->OriginY)/rdPtr->CellHeight;
}

long expSnapXtoGrid(LPRDATA rdPtr, long p1)
{
	return ((p1 - rdPtr->OriginX)/rdPtr->CellWidth)*rdPtr->CellWidth+rdPtr->OriginX;
}

long expSnapYtoGrid(LPRDATA rdPtr, long p1)
{
	return ((p1 - rdPtr->OriginY)/rdPtr->CellHeight)*rdPtr->CellHeight+rdPtr->OriginY;
}

long expGetOriginX(LPRDATA rdPtr, long param1)
{
	return rdPtr->OriginX;
}
long expGetOriginY(LPRDATA rdPtr, long param1)
{
	return rdPtr->OriginY;
}
long expGetCellWidth(LPRDATA rdPtr, long param1)
{
	return rdPtr->CellWidth;
}
long expGetCellHeight(LPRDATA rdPtr, long param1)
{
	return rdPtr->CellHeight;
}





long expGetCellValue(LPRDATA rdPtr, long p1, long p2)
{
	if ( CHECKPOS(rdPtr,getPos(rdPtr,p1,p2)) )
		return rdPtr->CellValues[ getPos(rdPtr,p1,p2) ];
	return -1;
}
long expGetXofCell(LPRDATA rdPtr, long p1)
{
	return rdPtr->CellWidth*p1+rdPtr->OriginX;
}
long expGetYofCell(LPRDATA rdPtr, long p1)
{
	return rdPtr->CellHeight*p1+rdPtr->OriginY;
}

long expMovedFixed(LPRDATA rdPtr, long param1)
{
	return rdPtr->MovedFixed;
}

long expMovedNewX(LPRDATA rdPtr, long param1)
{
	return rdPtr->MovedNewX;
}

long expMovedNewY(LPRDATA rdPtr, long param1)
{
	return rdPtr->MovedNewY;
}

long expMovedOldX(LPRDATA rdPtr, long param1)
{
	return rdPtr->MovedOldX;
}

long expMovedOldY(LPRDATA rdPtr, long param1)
{
	return rdPtr->MovedOldY;
}

long expDeletedFixed(LPRDATA rdPtr, long param1)
{
	return rdPtr->DeletedFixed;
}

long expDeletedX(LPRDATA rdPtr, long param1)
{
	return rdPtr->DeletedX;
}

long expDeletedY(LPRDATA rdPtr, long param1)
{
	return rdPtr->DeletedY;
}

void * conditions[] = {
	(void *)conOnFoundConnected,
	(void *)conOnFoundBrick,
	(void *)conOnFoundLooped,
	(void *)conOnNoFoundConnected,
	(void *)conBrickCanFallUp,
	(void *)conBrickCanFallDown,
	(void *)conBrickCanFallLeft,
	(void *)conBrickCanFallRight,
	(void *)conOnBrickMoved,
	(void *)conOnBrickDeleted,
	(void *)conIsEmpty
};

void * actions[] = {
	(void *)actSetBrick,
	(void *)actClear,
	(void *)actSetBoadSize,
	(void *)actSetMinConnected,
	(void *)actSearchHorizontal,
	(void *)actSearchVertical,
	(void *)actSearchDiagonalsLR,
	(void *)actSearchConnected,
	(void *)actDeleteHorizonal,
	(void *)actDeleteVertical,
	(void *)actSwap,
	(void *)actDropX,
	(void *)actDropOne,
	(void *)actMarkUsed,
	(void *)actDeleteMarked,
	(void *)actUndoSwap,
	(void *)actSearchDiagonalsRL,
	(void *)actLoopFoundBricks,
	(void *)actSetFixedOfBrick,
	(void *)actImportActives,
	(void *)actMarkCurrentSystem,
	(void *)actMarkCurrentBrick,
	(void *)actLoopEntireBoard,
	(void *)actLoopBoardOfType,
	(void *)actLoopSorrounding,
	(void *)actLoopHozLine,
	(void *)actLoopVerLine,
	(void *)actClearWithType,
	(void *)actInsertBrick,
	(void *)actSetOrigin,
	(void *)actSetCellDimensions,
	(void *)actMoveFixedON,
	(void *)actMoveFixedOFF,
	(void *)actMoveBrick,
	(void *)actDropOneUp,
	(void *)actDropOneLeft,
	(void *)actDropOneRight,
	(void *)actDropXUp,
	(void *)actDropXLeft,
	(void *)actDropXRight,
	(void *)actSetCellValue,
	(void *)actDeleteBrick,
	(void *)actShiftHosLine,
	(void *)actShiftVerLine,
	(void *)actPositionBricks
};

void * expressions[] = {
	(void *)expGetBrickAt,
	(void *)expGetXSize,
	(void *)expGetYSize,
	(void *)expGetNumBricksInSystem,
	(void *)expGetXofBrick,
	(void *)expGetYofBrick,
	(void *)expGetFoundBrickType,
	(void *)expGetNumBricksInHozLine,
	(void *)expGetNumBricksInVerLine,
	(void *)expCountSorrounding,
	(void *)expCountTotal,
	(void *)expGetFoundBrickFixed,
	(void *)expGetFoundXofBrick,
	(void *)expGetFoundYofBrick,
	(void *)expGetTypeofBrick,
	(void *)expGetFixedOfBrick,
	(void *)expGetFixedAt,
	(void *)expLoopIndex,
	(void *)expFindXfromFixed,
	(void *)expFindYfromFixed,
	(void *)expFindBrickfromFixed,
	(void *)expGetLoopFoundXofBrick,
	(void *)expGetLoopFoundYofBrick,
	(void *)expGetLoopTypeofBrick,
	(void *)expGetLoopFoundBrickFixed,
	(void *)expLoopLoopIndex,
	(void *)expGetXBrickFromX,
	(void *)expGetYBrickFromY,
	(void *)expSnapXtoGrid,
	(void *)expSnapYtoGrid,
	(void *)expGetOriginX,
	(void *)expGetOriginY,
	(void *)expGetCellWidth,
	(void *)expGetCellHeight,
	(void *)expGetCellValue,
	(void *)expGetXofCell,
	(void *)expGetYofCell,
	(void *)expMovedFixed,
	(void *)expMovedNewX,
	(void *)expMovedNewY,
	(void *)expMovedOldX,
	(void *)expMovedOldY,
	(void *)expDeletedFixed,
	(void *)expDeletedX,
	(void *)expDeletedY
};
