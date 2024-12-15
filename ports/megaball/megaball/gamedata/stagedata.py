
'''
Each difficulty has a dictionary:
easy : {
    ...
}

With that dictionary is another dictionary of quantity of each object type:

"spinners" : [personalityA, personalityB, ... etc]
'''

SPINNER_KEY = "spinners"
DIFF_NONE_KEY = "none"
DIFF_VERY_EASY_KEY = "very easy"
DIFF_EASY_KEY = "easy"
DIFF_MEDIUM_KEY = "medium"
DIFF_HARD_KEY = "hard"
DIFF_VERY_HARD_KEY = "very hard"

#[aggressive, mildly aggressive, slow random, fast random]

ENEMIES = {

    DIFF_NONE_KEY : {
        SPINNER_KEY : [0,0,0,0]
    },
    
    DIFF_VERY_EASY_KEY : {
        SPINNER_KEY : [2,1,1,0]#[1,1,1,0]
    },

    DIFF_EASY_KEY : {
        SPINNER_KEY : [2,1,2,0]#[1,1,2,0]
    },
    
    DIFF_MEDIUM_KEY : {
        SPINNER_KEY : [3,1,1,1]#[2,1,1,1]
    },
    
    DIFF_HARD_KEY : {
        SPINNER_KEY : [3,1,1,2]#[2,1,1,2]
    },
    
    DIFF_VERY_HARD_KEY : {
        SPINNER_KEY : [3,2,1,1]#[2,2,1,1]
    }
    
}

STAGE_DIFFICULTY = [
    DIFF_NONE_KEY, # 0
    DIFF_VERY_EASY_KEY, # 1
    DIFF_EASY_KEY, # 2
    DIFF_EASY_KEY, # 3
    DIFF_EASY_KEY, # 4
    DIFF_EASY_KEY, # 5
    DIFF_MEDIUM_KEY, # 6
    DIFF_EASY_KEY, # 7
    DIFF_MEDIUM_KEY, # 8
    DIFF_VERY_EASY_KEY, # 9
    DIFF_VERY_HARD_KEY, # 10
    DIFF_HARD_KEY, # 11
    DIFF_VERY_HARD_KEY, # 12
    DIFF_EASY_KEY, # 13
    DIFF_VERY_HARD_KEY, # 14
    DIFF_VERY_HARD_KEY # 15
]

