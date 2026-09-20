/*

Source from Andos, ALSO licensed under zlib!

*/

#include <vector>
using namespace std;

struct tagRDATA;

typedef struct tagRDATA
{
	int				BSizeX;
	int				BSizeY;
	int				MinConnected;
	int				SearchBrickType;
	int				NumFound;
	int			*	Board;
	int			*	StateBoard;
	int			*	FixedBoard;
	vector	<int>	Bricks;
	vector	<int>	Looped;
	int				SwapBrick1;
	int				SwapBrick2;
	int				LoopIndex;
	int				LoopedIndex;
	int				AddIncrement;
	int				OriginX;
	int				OriginY;
	int				CellWidth;
	int				CellHeight;
	bool			MoveFixed;
	int			*	CellValues;
	bool			TriggerMoved;
	bool			TriggerDeleted;
	int				MovedNewX;
	int				MovedNewY;
	int				MovedOldX;
	int				MovedOldY;
	int				MovedFixed;
	int				DeletedX;
	int				DeletedY;
	int				DeletedFixed;
    void (*generate)(tagRDATA *, int);
    void (*changePosition)(tagRDATA *, int, int, int);
    void * objectPlayer;
    
} RUNDATA;

typedef	RUNDATA * LPRDATA;