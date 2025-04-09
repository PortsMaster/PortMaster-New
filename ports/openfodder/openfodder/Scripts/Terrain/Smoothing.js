/*
 *  Terrain Smooth Engine for Open Fodder (JavaScript version)
 *    Written by starwindz
 *    Special thanks to segra and drnovice
 *  ------------------------------------------------------------------
 *
 *  Copyright (C) 2019 Open Fodder
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 */

const version = '0.70.beta8';

//const programMode = 'debug';
const programMode = 'release';

//const isShowMapChar = true;
const isShowMapChar = false;

// bitmask data for smoothChar
var bm_smooth_char = [
  // center 0 is always char1 (usually water)
  
  // 000
  // 101
  // 111
  '00011111',
  
  // 101
  // 101
  // 111
  '10111111',

  // 100
  // 100
  // 111
  '10010111',
  
  // 110
  // 100
  // 111
  '11010111',
  
  // 001
  // 001
  // 010 
  '00101010',
  
  // 001
  // 001
  // 110
  '00101110',
  
  // 011
  // 000
  // 110
  '01100110',

  // 111
  // 101
  // 111
  '11111111',

  // 111
  // 000
  // 111
  '11100111',

  // * NEW
  // 111
  // 101
  // 011
  '11111011',

  // 110
  // 101
  // 011
  '11011011',

  // 011
  // 101
  // 011
  '01111011',

  // 111
  // 000
  // 011
  '01111011',

  // 111
  // 001
  // 010
  '11101010',

  // 111
  // 100
  // 110
  '11110110',

  // 111
  // 000
  // 011
  '11100011',

  // 000
  // 101
  // 011
  '00011011',

  // 110
  // 101
  // 001
  '11011001',
];
var bm_smooth_char_all_false;
var bm_smooth_char_all_true;

// bitmask data for water-darkgrass (jungle tileset)
var bm_cf1_jungle_water_darkgrass = {
  "bitmask": [
    {"bm":"00000011", "tiles": [ {"tile":"380"} ] },
    {"bm":"00000111", "tiles": [ {"tile":"304"}, {"tile":"305"} ] }, 
    {"bm":"00000110", "tiles": [ {"tile":"363"} ] },
    {"bm":"00001001", "tiles": [ {"tile":"242"} ] },
    {"bm":"00010100", "tiles": [ {"tile":"243"} ] },
    {"bm":"00101001", "tiles": [ {"tile":"364"}, {"tile":"384"} ] },
    {"bm":"10010100", "tiles": [ {"tile":"266"}, {"tile":"286"}, {"tile":"306"} ] },
    {"bm":"00101000", "tiles": [ {"tile":"264"} ] },
    {"bm":"10010000", "tiles": [ {"tile":"261"} ] },
    {"bm":"01100000", "tiles": [ {"tile":"382"} ] },
    {"bm":"11100000", "tiles": [ {"tile":"365"}, {"tile":"366"}, {"tile":"386"} ] },
    {"bm":"11000000", "tiles": [ {"tile":"361"} ] },
         
    {"bm":"11110000", "tiles": [ {"tile":"360"} ] },
    {"bm":"11100000", "tiles": [ {"tile":"365"}, {"tile":"366"}, {"tile":"386"} ] }, 
    {"bm":"11101000", "tiles": [ {"tile":"383"} ] },
    {"bm":"11010100", "tiles": [ {"tile":"241"} ] },
    {"bm":"01101001", "tiles": [ {"tile":"244"} ] },
    {"bm":"10010100", "tiles": [ {"tile":"266"}, {"tile":"286"}, {"tile":"306"} ] },
    {"bm":"00101001", "tiles": [ {"tile":"364"}, {"tile":"384"} ] },
    {"bm":"10010110", "tiles": [ {"tile":"263"} ] },
    {"bm":"00101011", "tiles": [ {"tile":"262"} ] },
    {"bm":"00010111", "tiles": [ {"tile":"362"} ] },
    {"bm":"00000111", "tiles": [ {"tile":"304"}, {"tile":"305"} ] },
    {"bm":"00001111", "tiles": [ {"tile":"381"} ] },
         
    {"bm":"00001011", "tiles": [ {"tile":"284"}, {"tile":"285"} ] },
    {"bm":"00010110", "tiles": [ {"tile":"280"}, {"tile":"281"} ] },
    {"bm":"01101000", "tiles": [ {"tile":"282"}, {"tile":"283"} ] },
    {"bm":"11010000", "tiles": [ {"tile":"245"}, {"tile":"265"} ] }
  ]
};
   
// bitmask data for lightgrass-darkgrass (jungle tileset)
var bm_cf1_jungle_lightgrass_darkgrass = {
  "bitmask": [
    {"bm":"00000011", "tiles": [ {"tile":"228"} ] },
    {"bm":"00000111", "tiles": [ {"tile":"127"}, {"tile":"128"} ] }, 
    {"bm":"00000110", "tiles": [ {"tile":"229"} ] },
    {"bm":"00001001", "tiles": [ {"tile":"228"} ] },
    {"bm":"00010100", "tiles": [ {"tile":"229"} ] },
    {"bm":"00101001", "tiles": [ {"tile":"165"}, {"tile":"185"} ] },
    {"bm":"10010100", "tiles": [ {"tile":"49"},  {"tile":"69"} ] },
    {"bm":"00101000", "tiles": [ {"tile":"209"} ] },
    {"bm":"10010000", "tiles": [ {"tile":"210"} ] },
    {"bm":"01100000", "tiles": [ {"tile":"209"} ] },
    {"bm":"11100000", "tiles": [ {"tile":"47"},  {"tile":"48"} ] },
    {"bm":"11000000", "tiles": [ {"tile":"210"} ] },
       
    {"bm":"11110000", "tiles": [ {"tile":"68"} ] },
    {"bm":"11100000", "tiles": [ {"tile":"47"},  {"tile":"48"} ] }, 
    {"bm":"11101000", "tiles": [ {"tile":"67"} ] },
    {"bm":"11010100", "tiles": [ {"tile":"68"} ] },
    {"bm":"01101001", "tiles": [ {"tile":"67"} ] },
    {"bm":"10010100", "tiles": [ {"tile":"49"},  {"tile":"69"} ] },
    {"bm":"00101001", "tiles": [ {"tile":"165"}, {"tile":"185"} ] },
    {"bm":"10010110", "tiles": [ {"tile":"205"} ] },
    {"bm":"00101011", "tiles": [ {"tile":"225"} ] },
    {"bm":"00010111", "tiles": [ {"tile":"205"} ] },
    {"bm":"00000111", "tiles": [ {"tile":"127"}, {"tile":"128"} ] },
    {"bm":"00001111", "tiles": [ {"tile":"225"} ] },
         
    {"bm":"00001011", "tiles": [ {"tile":"225"} ] },
    {"bm":"00010110", "tiles": [ {"tile":"205"} ] },
    {"bm":"01101000", "tiles": [ {"tile":"67"}  ] },
    {"bm":"11010000", "tiles": [ {"tile":"68"}  ] }
  ]
};

// bitmask data for lightgrass-darkgrass (jungle tileset)
// swamp:107,167, darkgrass:123,124
var bm_cf1_jungle_swamp_darkgrass = {
  "bitmask": [
    {"bm":"00000011", "tiles": [ {"tile":"227"} ] },
    {"bm":"00000111", "tiles": [ {"tile":"227"} ] }, 
    {"bm":"00000110", "tiles": [ {"tile":"227"} ] },

    {"bm":"00001001", "tiles": [ {"tile":"207"} ] },
    {"bm":"00010100", "tiles": [ {"tile":"206"} ] },

    {"bm":"00101001", "tiles": [ {"tile":"168"} ] },
    {"bm":"10010100", "tiles": [ {"tile":"186"} ] },

    {"bm":"00101000", "tiles": [ {"tile":"148"} ] },
    {"bm":"10010000", "tiles": [ {"tile":"226"} ] },

    {"bm":"01100000", "tiles": [ {"tile":"147"} ] },
    {"bm":"11100000", "tiles": [ {"tile":"147"} ] },
    {"bm":"11000000", "tiles": [ {"tile":"147"} ] },
    //      

    {"bm":"11110000", "tiles": [ {"tile":"226"} ] },
    {"bm":"11100000", "tiles": [ {"tile":"147"} ] }, 
    {"bm":"11101000", "tiles": [ {"tile":"148"} ] },
    
    {"bm":"11010100", "tiles": [ {"tile":"146"} ] },
    {"bm":"01101001", "tiles": [ {"tile":"148"} ] },
    
    {"bm":"10010100", "tiles": [ {"tile":"166"} ] },
    {"bm":"00101001", "tiles": [ {"tile":"168"} ] },
    
    {"bm":"10010110", "tiles": [ {"tile":"206"} ] },
    {"bm":"00101011", "tiles": [ {"tile":"188"} ] },
    
    {"bm":"00010111", "tiles": [ {"tile":"206"} ] },
    {"bm":"00000111", "tiles": [ {"tile":"227"} ] },
    {"bm":"00001111", "tiles": [ {"tile":"207"} ] },
    //
    
    {"bm":"00001011", "tiles": [ {"tile":"207"} ] },
    {"bm":"00010110", "tiles": [ {"tile":"206"} ] },
    {"bm":"01101000", "tiles": [ {"tile":"148"} ] },
    {"bm":"11010000", "tiles": [ {"tile":"226"} ] }
  ]
};

// bitmask data for deepwater-shallowwater (ice tileset)
var bm_cf1_ice_deepwater_shallowwater = {
  "bitmask": [
    {"bm":"00000011", "tiles": [ {"tile":"132"} ] },
    {"bm":"00000111", "tiles": [ {"tile":"103"}, {"tile":"104"} ] }, 
    {"bm":"00000110", "tiles": [ {"tile":"135"} ] },
    {"bm":"00001001", "tiles": [ {"tile":"159"} ] },
    {"bm":"00010100", "tiles": [ {"tile":"158"} ] },
    {"bm":"00101001", "tiles": [ {"tile":"109"}, {"tile":"110"} ] },
    {"bm":"10010100", "tiles": [ {"tile":"107"}, {"tile":"108"} ] },
    {"bm":"00101000", "tiles": [ {"tile":"177"} ] },
    {"bm":"10010000", "tiles": [ {"tile":"176"} ] },
    {"bm":"01100000", "tiles": [ {"tile":"138"} ] },
    {"bm":"11100000", "tiles": [ {"tile":"105"}, {"tile":"106"} ] },
    {"bm":"11000000", "tiles": [ {"tile":"137"} ] },
          
    {"bm":"11110000", "tiles": [ {"tile":"136"} ] },
    {"bm":"11100000", "tiles": [ {"tile":"105"}, {"tile":"106"} ] }, 
    {"bm":"11101000", "tiles": [ {"tile":"139"} ] },
    {"bm":"11010100", "tiles": [ {"tile":"156"} ] },
    {"bm":"01101001", "tiles": [ {"tile":"157"} ] },
    {"bm":"10010100", "tiles": [ {"tile":"107"}, {"tile":"108"} ] },
    {"bm":"00101001", "tiles": [ {"tile":"109"}, {"tile":"110"} ] },
    {"bm":"10010110", "tiles": [ {"tile":"178"} ] },
    {"bm":"00101011", "tiles": [ {"tile":"179"} ] },
    {"bm":"00010111", "tiles": [ {"tile":"134"} ] },
    {"bm":"00000111", "tiles": [ {"tile":"103"}, {"tile":"104"} ] },
    {"bm":"00001111", "tiles": [ {"tile":"133"} ] },
          
    {"bm":"00001011", "tiles": [ {"tile":"119"} ] },
    {"bm":"00010110", "tiles": [ {"tile":"118"} ] },
    {"bm":"01101000", "tiles": [ {"tile":"117"} ] },
    {"bm":"11010000", "tiles": [ {"tile":"116"} ] }
  ]
};

// bitmask data for wetice-shallowwater (ice tileset)
var bm_cf1_ice_wetice_shallowwater = {
  "bitmask": [
    {"bm":"00000011", "tiles": [ {"tile":"82"} ] },
    {"bm":"00000111", "tiles": [ {"tile":"85"} ] }, 
    {"bm":"00000110", "tiles": [ {"tile":"87"} ] },
    {"bm":"00001001", "tiles": [ {"tile":"131"} ] },
    {"bm":"00010100", "tiles": [ {"tile":"129"} ] },
    {"bm":"00101001", "tiles": [ {"tile":"112"} ] },
    {"bm":"10010100", "tiles": [ {"tile":"113"} ] },
    {"bm":"00101000", "tiles": [ {"tile":"150"} ] },
    {"bm":"10010000", "tiles": [ {"tile":"148"} ] },
    {"bm":"01100000", "tiles": [ {"tile":"94"} ] },
    {"bm":"11100000", "tiles": [ {"tile":"96"} ] },
    {"bm":"11000000", "tiles": [ {"tile":"99"} ] },
          
    {"bm":"11110000", "tiles": [ {"tile":"98"} ] },
    {"bm":"11100000", "tiles": [ {"tile":"96"} ] }, 
    {"bm":"11101000", "tiles": [ {"tile":"95"} ] },
    {"bm":"11010100", "tiles": [ {"tile":"128"} ] },
    {"bm":"01101001", "tiles": [ {"tile":"130"} ] },
    {"bm":"10010100", "tiles": [ {"tile":"113"} ] },
    {"bm":"00101001", "tiles": [ {"tile":"112"} ] },
    {"bm":"10010110", "tiles": [ {"tile":"149"} ] },
    {"bm":"00101011", "tiles": [ {"tile":"151"} ] },
    {"bm":"00010111", "tiles": [ {"tile":"86"} ] },
    {"bm":"00000111", "tiles": [ {"tile":"85"} ] },
    {"bm":"00001111", "tiles": [ {"tile":"83"} ] },
          
    {"bm":"00001011", "tiles": [ {"tile":"80"}, {"tile":"81"} ] },
    {"bm":"00010110", "tiles": [ {"tile":"88"}, {"tile":"89"} ] },
    {"bm":"01101000", "tiles": [ {"tile":"92"}, {"tile":"93"} ] },
    {"bm":"11010000", "tiles": [ {"tile":"90"}, {"tile":"91"} ] }
  ]
};

// bitmask data for dryice-wetice (ice tileset)
var bm_cf1_ice_dryice_wetice = {
  "bitmask": [
    {"bm":"00000011", "tiles": [ {"tile":"5"} ] },
    {"bm":"00000111", "tiles": [ {"tile":"7"} ] }, 
    {"bm":"00000110", "tiles": [ {"tile":"9"} ] },
    {"bm":"00001001", "tiles": [ {"tile":"22"} ] },
    {"bm":"00010100", "tiles": [ {"tile":"24"} ] },
    {"bm":"00101001", "tiles": [ {"tile":"62"} ] },
    {"bm":"10010100", "tiles": [ {"tile":"63"} ] },
    {"bm":"00101000", "tiles": [ {"tile":"43"} ] },
    {"bm":"10010000", "tiles": [ {"tile":"45"} ] },
    {"bm":"01100000", "tiles": [ {"tile":"15"} ] },
    {"bm":"11100000", "tiles": [ {"tile":"17"} ] },
    {"bm":"11000000", "tiles": [ {"tile":"19"} ] },
         
    {"bm":"11110000", "tiles": [ {"tile":"18"} ] },
    {"bm":"11100000", "tiles": [ {"tile":"17"} ] }, 
    {"bm":"11101000", "tiles": [ {"tile":"16"} ] },
    {"bm":"11010100", "tiles": [ {"tile":"25"} ] },
    {"bm":"11010100", "tiles": [ {"tile":"23"} ] },
    {"bm":"11010100", "tiles": [ {"tile":"63"} ] },
    {"bm":"01101001", "tiles": [ {"tile":"62"} ] },
    {"bm":"10010100", "tiles": [ {"tile":"44"} ] },
    {"bm":"10010100", "tiles": [ {"tile":"42"} ] },
    {"bm":"10010110", "tiles": [ {"tile":"8"} ] },
    {"bm":"00101011", "tiles": [ {"tile":"7"} ] },
    {"bm":"00010111", "tiles": [ {"tile":"6"} ] },
         
    {"bm":"00001011", "tiles": [ {"tile":"3"}, {"tile":"4"} ] },
    {"bm":"00010110", "tiles": [ {"tile":"10"}, {"tile":"11"} ] },
    {"bm":"01101000", "tiles": [ {"tile":"14"} ] },
    {"bm":"11010000", "tiles": [ {"tile":"12"}, {"tile":"13"} ] }
  ]
};

var bm_cf1_jungle_tree = {
  "bitmask": 
  [
    {
      "group":"BOTTOM", 
      "detect":    [ {"vector": "11111000"} ],
      "change_to": [ 
                     {"matrix": [ [1, 21, 41], [2, 22, 42], [3, 23, 43], [4, 24, 44] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },

    {
      "group":"BOTTOM", 
      "detect":    [ {"vector": "11101000"} ],
      "change_to": [ 
                     {"matrix": [ [202, 222, 86] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },

    {
      "group":"BOTTOM", 
      "detect":    [ {"vector": "11110000"} ],
      "change_to": [ 
                     {"matrix": [ [3, 23, 43] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },

    {
      "group":"BOTTOM", 
      "detect":    [ {"vector": "11101001"}, {"vector": "11111001"}, {"vector": "11001001"}, {"vector": "11011001"} ],
      "change_to": [ 
                     {"matrix": [ [144, 184, 204, 224] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },    

    {
      "group":"BOTTOM", 
      "detect":    [ {"vector": "11110100"}, {"vector": "11111100"}, {"vector": "01110100"}, {"vector": "01111100"} ],
      "change_to": [ 
                     {"matrix": [ [163, 183, 203, 223] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },  
    
    {
      "group":"BOTTOM", 
      "detect":    [ {"vector": "01101000"}, {"vector": "01101001"} ],
      "change_to": [ 
                     {"matrix": [ [46, 66, 86] ]},
                     {"matrix": [ [35, 35] ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },   
    
    {
      "group":"BOTTOM", 
      "detect":    [ {"vector": "11010000"}, {"vector": "11010100"} ],
      "change_to": [ 
                     {"matrix": [ [45, 65, 85] ]},
                     {"matrix": [  ]},
                     {"matrix": [ [104, 104] ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },  
    
    {
      "group":"MIDDLE", 
      "detect":    [ {"vector": "11111111"}, {"vector": "11111011"}, {"vector": "11111110"}, {"vector": "01111111"}, {"vector": "11011111"}, {"vector": "11011011"}, {"vector": "01111110"}, {"vector": "11110110"}, {"vector": "11010111"}, {"vector": "11101011"}, {"vector": "01101111"} ],
      "change_to": [ 
                     {"matrix": [ [1], [2], [83], [102], [121], [122], [141], [142], [163] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },    

    {
      "group":"MIDDLE", 
      "detect":    [ {"vector": "01001011"}, {"vector": "01101010"}, {"vector": "01101011"} ],
      "change_to": [ 
                     {"matrix": [ [46], [83] ]},
                     {"matrix": [ [35] ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },
    
    {
      "group":"MIDDLE", 
      "detect":    [ {"vector": "01010110"}, {"vector": "11010010"}, {"vector": "11010110"} ],
      "change_to": [ 
                     {"matrix": [ [45], [25] ]},
                     {"matrix": [  ]},
                     {"matrix": [ [104] ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },

    {
      "group":"TOP", 
      "detect":    [ {"vector": "00011111"} ],
      "change_to": [ 
                     {"matrix": [ [62], [102], [144], [145] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },  
    
    {
      "group":"TOP", 
      "detect":    [ {"vector": "00001111"} ],
      "change_to": [ 
                     {"matrix": [ [61], [100] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },
    
    {
      "group":"TOP", 
      "detect":    [ {"vector": "00010111"} ],
      "change_to": [ 
                     {"matrix": [ [63], [120] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },   
    
    {
      "group":"TOP", 
      "detect":    [ {"vector": "00101111"} ],
      "change_to": [ 
                     {"matrix": [ [100] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },  
    
    {
      "group":"TOP", 
      "detect":    [ {"vector": "00111111"} ],
      "change_to": [ 
                     {"matrix": [ [144] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    }, 
    
    {
      "group":"TOP", 
      "detect":    [ {"vector": "10010111"} ],
      "change_to": [ 
                     {"matrix": [ [63] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    }, 
    
    {
      "group":"TOP", 
      "detect":    [ {"vector": "10011111"} ],
      "change_to": [ 
                     {"matrix": [ [102] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },  
    
    {
      "group":"TOP", 
      "detect":    [ {"vector": "00001011"}, {"vector": "00101011"} ],
      "change_to": [ 
                     {"matrix": [ [61], [100] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    },  
    
    {
      "group":"TOP", 
      "detect":    [ {"vector": "00010110"}, {"vector": "10010110"} ],
      "change_to": [ 
                     {"matrix": [ [63], [120] ]},
                     {"matrix": [  ]},
                     {"matrix": [  ]}
                   ],
      "change_to_cur": [ {"row":"0"}, {"row":"0"}, {"row":"0"} ]
    } 
    
  ]
}

if (programMode == 'debug') {
  /*
  var tree_bitmask = bm_cf1_jungle_tree;
  var a;
  
  a = tree_bitmask.bitmask[0].group;
  printDebug(a);
  a = tree_bitmask.bitmask[0].detect[0].vector;
  printDebug(a);
  a = tree_bitmask.bitmask[0].change_to[0].matrix;
  printDebug(a);
  a = tree_bitmask.bitmask[0].change_to[0].matrix[1][2];
  printDebug(a);
  a = tree_bitmask.bitmask[0].change_to[1].matrix.length;
  printDebug(a);  
  
  printDebug(tree_bitmask.bitmask[0].change_to[0].matrix[1][2]);
  */

  /*
  var s = BitmaskRot('10000000', false);
  console.log(s);
 
  var f = BitmaskMatchRot('00100000', ['10000000', '00100000'], false);
  console.log(f);
 
  var f = BitmaskMatchRot('00000100', ['10000000'], false);
  console.log(f);
 
  var f = BitmaskMatchRot('11010110', ['00011111'], false);
  console.log(f);
  
  var f = BitmaskMatchRot('01101001', bm_smooth_char, true);
  console.log(f);

  console.log(bm_smooth_char);
  */
}
     
// Delphi compatible AnsiMatchStr function
function AnsiMatchStr(s, s_list) {
  var flag;

  flag = false;
  for (var i = 0; i <= s_list.length - 1; i++) {
    if (s.includes(s_list[i])) {
	    flag = true;
	    break;
    }
  }
  return flag;
}

function BitmaskRot(bm, flip) {
  var src = new Array(8);
  var tar = new Array(12);
  var i;
  var _bm;
  
  // Bit Flip
  if (flip == true) {
    _bm = '';
    for (i = 0; i <= 7; i++) {
      if ( bm.charAt(i, 1) == '0' ) {
        _bm = _bm + '1';
      }
      else {
        _bm = _bm + '0';
      }
    }
    bm = _bm;  
  }

  // Original
  for (i = 0; i <= 7; i++) {
    src[i] = bm.charAt(i, 1);
  }  

  tar[ 0] = src[0] + src[1] +  src[2] + src[3] + src[4] + src[5] + src[6] + src[7];
  tar[ 1] = src[5] + src[3] +  src[0] + src[6] + src[1] + src[7] + src[4] + src[2];
  tar[ 2] = src[5] + src[6] +  src[7] + src[3] + src[4] + src[0] + src[1] + src[2];
  tar[ 3] = src[0] + src[3] +  src[5] + src[1] + src[6] + src[2] + src[4] + src[7];
  tar[ 4] = src[2] + src[4] +  src[7] + src[1] + src[6] + src[0] + src[3] + src[5];
  tar[ 5] = src[7] + src[6] +  src[5] + src[4] + src[3] + src[2] + src[1] + src[0];
  
  // Left-Right Mirrored
  src[0] = bm.charAt(2, 1);
  src[1] = bm.charAt(1, 1);
  src[2] = bm.charAt(0, 1);
  src[3] = bm.charAt(4, 1);
  src[4] = bm.charAt(3, 1);
  src[5] = bm.charAt(7, 1);
  src[6] = bm.charAt(6, 1);
  src[7] = bm.charAt(5, 1);
  
  tar[ 6] = src[0] + src[1] +  src[2] + src[3] + src[4] + src[5] + src[6] + src[7];
  tar[ 7] = src[5] + src[3] +  src[0] + src[6] + src[1] + src[7] + src[4] + src[2];
  tar[ 8] = src[5] + src[6] +  src[7] + src[3] + src[4] + src[0] + src[1] + src[2];
  tar[ 9] = src[0] + src[3] +  src[5] + src[1] + src[6] + src[2] + src[4] + src[7];
  tar[10] = src[2] + src[4] +  src[7] + src[1] + src[6] + src[0] + src[3] + src[5];
  tar[11] = src[7] + src[6] +  src[5] + src[4] + src[3] + src[2] + src[1] + src[0];

  return tar;
}

function BitmaskMatchRot(s, s_list, flip) {
  var flag;

  flag = false;
  for (var i = 0; i <= s_list.length - 1; i++) {
    if ( AnsiMatchStr(s, BitmaskRot( s_list[i], flip ) )) {
	    flag = true;
	    break;
    }
  }
  return flag;
}

// Make 2D Array (x, y : sequence)
function makeArray(_w, _h, val) {
  var w = _h;
  var h = _w;

  var arr = [];
  for (var i = 0; i < h; i++) {
    arr[i] = [];
    for (var j = 0; j < w; j++) {
	    arr[i][j] = val;
    }
  }
  return arr;
}

// Set Array Test
function setArray(arr, x, y, v) {
  arr[x][y] = v;
  return 0;
}

// Define TColor Stucture
function TColor() {
  var r, g, b;
}

// Print Debug info
function printDebug(args) {
  if (programMode == 'debug') {
    console.log(args);
  }
  else {
    print(args);
  }
}

// Define multi levels
function TLevel() {
  var name = ''; // string
  var char = ''; // string
  var limit = 0.0; // double
}

// Define smooth setting
function TSmooth() {
  var char1 = '';
  var char2 = '';
}

function pad(n, width) {
  n = n + '';
  return n.length >= width ? n: new Array(width - n.length + 1).join('0') + n;
}

function pads(n, width) {
  n = n + '';
  return n.length >= width ? n: new Array(width - n.length + 1).join(' ') + n;
}

function getRandomInt(min, max) {
  if (programMode == 'debug') {
    return Math.floor(Math.random() * (max - min + 1) + min);
  }
  else {
    var _rnd = Math.floor(Map.getRandomInt(min, max));
    //printDebug('min = ' + String(min) + ', ' + 'max = ' + String(max) + ', _rnd = ' + String(_rnd));
    return _rnd;
  }
}

// Delphi to JavaScript Syntax Conversion Test
function CTest() {
  this.testDummy = function() {
    printDebug('dummy');
  }

  this.testJavaScriptSyntax = function() {
    // AnsiMatchStr Test
    var s = '*';
    var b = new Array(2);
    b[0] = '+';
    b[1] = '*';
    var flag = s.includes('+');
    printDebug('AnsiMatchStr(*, [+, *]) = ' + AnsiMatchStr(s, b));
  
    // 2D Array Test
    var x = makeArray(10, 100, 0);
    var xx = x[9][99] = 234;
    x[2][3] = 789;
    setArray(x, 2, 3, 789)
    printDebug('x[9][99] = ' + String(xx));
    printDebug('x[2][3] = ' + String(x[2][3]));
  
    // Structure Test
    var c1 = new TColor();
    c1.r = 10;
    c1.g = 20;
    c1.b = 30;
    printDebug('c1.r = ' + String(c1.r));
  
    // Structure Test (2)
    var lev = new TLevel();
    lev.name = 'name1';
    printDebug(lev.name);
  
    // Structure Array Test
    var lev_arr = new Array(1);
    lev_arr[0] = new TLevel();
    lev_arr[0].name = 'name1arr';
    printDebug(lev_arr[0].name);
  
    // Delphi String Copy Function (Warning! Starting index is 0)
    var ss = 'abcde';
    var ss2 = ss.charAt(2);
    printDebug('.charAt(2) = ' + ss2);
  }

}

// CSmoothTerrain
function CSmoothTerrain() {
  var game_type;
  var tile_type;
  var map_col_num, map_row_num;
  var level_num, smooth_num;
  var level, smooth;
  var map_level, map_char, map_tile;
  var s_step;
  var b_list, w_list;
  var _limit_recursion_depth;
  var _max_recursion_depth;
  var _recursion_depth;
  var _chk_tile;
  var _smooth_map_char_cnt;
  var _map_char;
  var _big_flood;

  // Show Map Char for Debugging
  function showMapChar(tit) {
    if (isShowMapChar == true) {
      var s;

      printDebug('');
      printDebug(tit);
      for (var j = 0; j <= map_row_num - 1; j++) {
        s = '';
        for (var i = 0; i <= map_col_num - 1; i++) {
          s = s + map_char[i][j];
        }
        printDebug(s);
      }
    }
  }

  function showMapTile() {
    var s;

    printDebug('');
    for (var j = 0; j <= map_row_num - 1; j++) {
      s = '';
      for (var i = 0; i <= map_col_num - 1; i++) {
        s = s + pad(map_tile[i][j], 3) + ' ';
      }
      printDebug(s);
    }

  }

  // Create Map Char according to the level[].limit
  function createMapChar() {
    var i, j, k;
    var _range = new Array(level_num + 1);

    _range[0] = 0;
    for (k = 0; k <= level_num - 1; k++) {
      _range[k + 1] = level[k].limit;
    }

    //printDebug(map_col_num);
    for (i = 0; i <= map_col_num - 1; i++) {
      for (j = 0; j <= map_row_num - 1; j++) {
        for (k = 0; k <= level_num - 1; k++) {

          if ( (map_level[i][j] >= _range[k]) &&
               (map_level[i][j] <  _range[k + 1]) ) {
            map_char[i][j] = level[k].char;
            break;
          }

        }
      }
    }
  }

  function get_bitmask_data(i, j) {
    var b;

    if ( (smooth_num == 1) || (s_step == smooth_num - 1) ) {
      b_list = new Array(2);
      w_list = new Array(1);
    } else {
      b_list = new Array(3);
      w_list = new Array(1);
    }
    b_list[0] = smooth[s_step].char1;
    b_list[1] = smooth[s_step].char2;
    w_list[0] = smooth[s_step].char1;

    if ( (smooth_num == 1) || (s_step == smooth_num - 1) ) {
    }
    else {
      b_list[2] = smooth[s_step + 1].char1;
    }

    //printDebug(i, j, w_list);

    // check boundary chars
    // -1 row
    _chk_tile = 0;
    if ((i - 1) < 0 || (j - 1) < 0) {} else {
      if (AnsiMatchStr(map_char[i - 1][j - 1], b_list) == false) {
        _chk_tile++;
      }
    }

    if ((j - 1) < 0) {} else {
      if (AnsiMatchStr(map_char[i][j - 1], b_list) == false) {
        _chk_tile++;
      }
    }

    if ((i + 1) > (map_col_num - 1) || (j - 1) < 0) {} else {
      if (AnsiMatchStr(map_char[i + 1][j - 1], b_list) == false) {
        _chk_tile++;
      }
    }


    // +0 row
    if ((i - 1) < 0) {} else {
      if (AnsiMatchStr(map_char[i - 1][j], b_list) == false) {
        _chk_tile++;
      }
    }

    if ((i + 1) > (map_col_num - 1)) {} else {
      if (AnsiMatchStr(map_char[i + 1][j], b_list) == false) {
        _chk_tile++;
      }
    }

    // +1 row
    if ((i - 1) < 0 || (j + 1) > (map_row_num - 1)) {} else {
      if (AnsiMatchStr(map_char[i - 1][j + 1], b_list) == false) {
        _chk_tile++;
      }
    }

    if ((j + 1) > (map_row_num - 1)) {} else {
      if (AnsiMatchStr(map_char[i][j + 1], b_list) == false) {
        _chk_tile++;
      }
    }

    if ((i + 1) > (map_col_num - 1) || (j + 1) > (map_row_num - 1)) {} else {
      if (AnsiMatchStr(map_char[i + 1][j + 1], b_list) == false) {
        _chk_tile++;
      }
    }

    if (_chk_tile != 0) {
      //printDebug('*** bitmask return ***');
      return '-1'
    }

    // get actual bitmask data
    //  (-1, -1) ( 0, -1) (+1, -1)
    //  (-1,  0)          (+1,  0)
    //  (+1, -1) (+1, -1) (+1, +1)
    b = '';
    // -1 row
    if ((i - 1) < 0 || (j - 1) < 0) {
      b = b + '0';
    } else {
      if (AnsiMatchStr(map_char[i - 1][j - 1], w_list)) {
        b = b + '0';
      } else {
        b = b + '1';
      }
    }

    if ((j - 1) < 0) {
      b = b + '0';
    } else {
      if (AnsiMatchStr(map_char[i][j - 1], w_list)) {
        b = b + '0';
      } else {
        b = b + '1';
      }
    }

    if ((i + 1) > (map_col_num - 1) || (j - 1) < 0) {
      b = b + '0';
    } else {
      if (AnsiMatchStr(map_char[i + 1][j - 1], w_list)) {
        b = b + '0';
      } else {
        b = b + '1';
      }
    }

    // +0 row
    if ((i - 1) < 0) {
      b = b + '0';
    } else {
      if (AnsiMatchStr(map_char[i - 1][j], w_list)) {
        b = b + '0';
      } else {
        b = b + '1';
      }
    }

    if ((i + 1) > (map_col_num - 1)) {
      b = b + '0';
    } else {
      if (AnsiMatchStr(map_char[i + 1][j], w_list)) {
        b = b + '0';
      } else {
        b = b + '1';
      }
    }

    // +1 row
    if ((i - 1) < 0 || (j + 1) > (map_row_num - 1)) {
      b = b + '0';
    } else {
      if (AnsiMatchStr(map_char[i - 1][j + 1], w_list)) {
        b = b + '0';
      } else {
        b = b + '1';
      }
    }

    if ((j + 1) > (map_row_num - 1)) {
      b = b + '0';
    } else {
      if (AnsiMatchStr(map_char[i][j + 1], w_list)) {
        b = b + '0';
      } else {
        b = b + '1';
      }
    }

    if ((i + 1) > (map_col_num - 1) || (j + 1) > (map_row_num - 1)) {
      b = b + '0';
    } else {
      if (AnsiMatchStr(map_char[i + 1][j + 1], w_list)) {
        b = b + '0';
      } else {
        b = b + '1';
      }
    }
    return b;
  }

  function removeDups(names) {
    var unique = {};
    names.forEach(function(i) {
      if(!unique[i]) {
        unique[i] = true;
      }
    });
    return Object.keys(unique);
  }

  function build_bm_smooth_char_all() {
    var b;

    bm_smooth_char_all_false = [];
    for (var i = 0; i <= bm_smooth_char.length - 1; i++) {
      b = BitmaskRot(bm_smooth_char[i], false);
      for (var j = 0; j <= b.length - 1; j++) {
        bm_smooth_char_all_false.push( b[j] );  
      }
    }
    bm_smooth_char_all_false = removeDups(bm_smooth_char_all_false);

    bm_smooth_char_all_true = [];
    for (var i = 0; i <= bm_smooth_char.length - 1; i++) {
      b = BitmaskRot(bm_smooth_char[i], true);
      for (var j = 0; j <= b.length - 1; j++) {
        bm_smooth_char_all_true.push( b[j] );  
      }
    }
    bm_smooth_char_all_true = removeDups(bm_smooth_char_all_true);

    //console.log(bm_smooth_char_all_false);
    //console.log(bm_smooth_char_all_true);
    printDebug(
      '>> Smoothing char patterns generated: ' + 
      String(bm_smooth_char_all_false.length + bm_smooth_char_all_true.length) + ' ' + 'from ' +
      String(bm_smooth_char.length) + ' base patterns'
    );
  }

  function smooth_map_char_step_sub(i, j) {
    var bm;
    var _bm = new Array(4);
    var _bm_ud = '', _bm_lr = '';
    var found_cnt = 0;
    var _comp_char = '';
    var _comp_false = false;
    var _comp_true = true;
    var _WC, _LC;
    var tree_bitmask;

    _WC = smooth[s_step].char1;
    _LC = smooth[s_step].char2;

    bm = get_bitmask_data(i, j);
    //printDebug(i, j, bm);

    if (_chk_tile != 0) {
      return false;
    }

    // New optimized smooth_char routine
    found_cnt = 0;

    if (AnsiMatchStr(map_char[i][j], w_list) == true) {
      if ( AnsiMatchStr(bm, bm_smooth_char_all_false) == true ) {
        map_char[i][j] = _LC;  
        found_cnt++;
        _smooth_map_char_cnt++;
      }
    }
  
    else if (AnsiMatchStr(map_char[i][j], w_list) == false) {
      if ( AnsiMatchStr(bm, bm_smooth_char_all_true) == true ) {
        map_char[i][j] = _WC;  
        found_cnt++;
        _smooth_map_char_cnt++;
      }
    }

    // check for exiting
    if (found_cnt == 0) {
      return false;
    }

    //return true;

    // recursion started
    if ((i - 1 >= 0) && (j - 1 >= 0)) {
      _recursion_depth++;
      if (_recursion_depth > _limit_recursion_depth) {
        return false;
      }
      smooth_map_char_step_sub(i - 1, j - 1);
    }

    if (j - 1 >= 0) {
      _recursion_depth++;
      if (_recursion_depth > _limit_recursion_depth) {
        return false;
      }
      smooth_map_char_step_sub(i, j - 1);
    }

    if ((i + 1) <= (map_col_num - 1) && (j - 1) >= 0) {
      _recursion_depth++;
      if (_recursion_depth > _limit_recursion_depth) {
        return false;
      }
      smooth_map_char_step_sub(i + 1, j - 1);
    }

    if (i - 1 >= 0) {
      _recursion_depth++;
      if (_recursion_depth > _limit_recursion_depth) {
        return false;
      }
      smooth_map_char_step_sub(i - 1, j);
    }

    if ((i + 1) <= (map_col_num - 1)) {
      _recursion_depth++;
      if (_recursion_depth > _limit_recursion_depth) {
        return false;
      }
      smooth_map_char_step_sub(i + 1, j);
    }

    if ((i - 1 >= 0) && (j + 1) <= (map_row_num - 1)) {
      _recursion_depth++;
      if (_recursion_depth > _limit_recursion_depth) {
        return false;
      }
      smooth_map_char_step_sub(i - 1, j + 1);
    }

    if ((j + 1) <= (map_row_num - 1)) {
      _recursion_depth++;
      if (_recursion_depth > _limit_recursion_depth) {
        return false;
      }
      smooth_map_char_step_sub(i, j + 1);
    }

    if ((i + 1) <= (map_col_num - 1) && (j + 1) <= (map_row_num - 1)) {
      _recursion_depth++;
      if (_recursion_depth > _limit_recursion_depth) {
        return false;
      }
      smooth_map_char_step_sub(i + 1, j + 1);
    }

  }

  function smooth_map_char_step() {
    var i, j;

    _limit_recursion_depth = 256;
    _max_recursion_depth = -1;

    for (j = 0; j <= map_row_num - 1; j++) {
      for (i = 0; i <= map_col_num - 1; i++) {
        //if ( (map_char[i][j] == smooth[s_step].char1) ) {
        _recursion_depth = 0;
        smooth_map_char_step_sub(i, j);
        if (_recursion_depth > _max_recursion_depth) {
          _max_recursion_depth = _recursion_depth;
        }
        //}
      }
    }

  }

  function smoothMapChar() {
    var i, m, st, ed;

    st = 0;
    ed = smooth_num - 1;
    //ed = 1;

    build_bm_smooth_char_all();
    
    _smooth_map_char_cnt = 0;
    for (m = st; m <= ed; m++) {
      s_step = m;
      smooth_map_char_step();
	    printDebug('>> Smoothing map char... Step ' + m);
    }
    //showMapChar();
    printDebug('>> Smoothing map char... change count ' + _smooth_map_char_cnt);
  }

  function smoothWaterAndLandEach(_bms) {
    var i, j, k, _kk;
    var bm;
    var found = false;
    var cnt;
    var _bma;
    var _WC, _LC;
    var _tmp_tile;

    _WC = smooth[s_step].char1;
    _LC = smooth[s_step].char2;
    //printDebug('WC = ', s_step, _WC);

    /// all adjacent cells should be _WC or _LC. if not returns '-1' (skip processing)
    //printDebug('start bitmasking...');
    cnt = 0;
    for (j = 0; j <= map_row_num - 1; j++) {
      for (i = 0; i <= map_col_num - 1; i++) {
        //printDebug(map_char[i][j]);
        if (map_char[i][j] == _WC) {
          bm = get_bitmask_data(i, j);
          //printDebug(i, j, bm);

          if (_chk_tile != 0) {
            //printDebug('.....continue');
            continue;
          }

          found = false;
          for (k = 0; k <= 27; k++) {
            if (_bms.bitmask[k].bm == bm) {
              cnt++;

              _bma = new Array(_bms.bitmask[k].tiles.length);
              for (_kk = 0; _kk <= _bms.bitmask[k].tiles.length - 1; _kk++) {
                _bma[_kk] = _bms.bitmask[k].tiles[_kk].tile;
              }

              _tmp_tile = map_tile[i][j];
              map_tile[i][j] = Number(_bma[getRandomInt(0, _bms.bitmask[k].tiles.length - 1)]);
              //printDebug('>> m = ' + pads(s_step, 2) + ' ' + pads(i, 3) + ',' + pads(j, 3) + ' : ' + pads(_tmp_tile, 3) + ' is bitmasked to ' + map_tile[i][j]);
              break;
            }
          }

        }
      }
    }

  }

  function smoothWaterAndLand() {
    var i, j, m;

    if ( (game_type == 'cf1') && (tile_type == 'jungle') ) {
      // for cf1-jungle
      var _water =      [326, 346];
      var _darkgrass =  [123, 124];
      var _lightgrass = [0, 20, 40];
      var _darkgrass2 = [123, 124];
      var _tree =       [1, 2];
      var _swamp =      [107, 167];
      var _bms;

      //printDebug('>> smoothWaterAndLand: started');

      // init
      for (j = 0; j <= map_row_num - 1; j++) {
        for (i = 0; i <= map_col_num - 1; i++) {
          //map_tile[i][j] = 0;
          if (map_char[i][j] == level[0].char) {
            map_tile[i][j] = _water[getRandomInt(0, _water.length - 1)];
          } else if (map_char[i][j] == level[1].char) {
            map_tile[i][j] = _darkgrass[getRandomInt(0, _darkgrass.length - 1)];
          } else if (map_char[i][j] == level[2].char) {
            map_tile[i][j] = _lightgrass[getRandomInt(0, _lightgrass.length - 1)];
          } else if (map_char[i][j] == level[3].char) {
            map_tile[i][j] = _darkgrass2[getRandomInt(0, _darkgrass2.length - 1)];
          } else if (map_char[i][j] == level[4].char) {
            map_tile[i][j] = _tree[getRandomInt(0, _tree.length - 1)];
          }
          else {
            map_tile[i][j] = _swamp[getRandomInt(0, _swamp.length - 1)];
          }

        }
      }

      //printDebug('---');
      //showMapTile();

      //for (m = 0; m <= 1; m++) {
      for (m = 0; m <= 2; m++) {
        /*
        if (m == 0) {
          _bms = bm_cf1_jungle_water_darkgrass;
        } else if (m == 1) {
          _bms = bm_cf1_jungle_lightgrass_darkgrass;
        }
        */
        /*
        if (m == 0) {
          _bms = bm_cf1_jungle_swamp_darkgrass;
        } else if (m == 1) {
          _bms = bm_cf1_jungle_lightgrass_darkgrass;
        }
        */
        
        if (m == 0) {
          _bms = bm_cf1_jungle_water_darkgrass;
        } else if (m == 1) {
          _bms = bm_cf1_jungle_lightgrass_darkgrass;
        } else if (m == 2) {
          _bms = bm_cf1_jungle_swamp_darkgrass;
        }
        
        s_step = m;
        smoothWaterAndLandEach(_bms);
	      printDebug('>> Smoothing water and land... Step ' + m);
      }

      //printDebug('---');
      //showMapTile();
    }

  }

  function normaizeMapLevel() {
    var min, max, divisor;
    var i, j;
  
    min = 0;
    max = 0;
  
    for (i = 0; i <= map_col_num - 1; i++) {
      for (j = 0; j <= map_row_num - 1; j++) {
        if (map_level[i][j] < min) {
          min = map_level[i][j];
        }
        else if (map_level[i][j] > max) {
          max = map_level[i][j];
        }
      }
    }
  
    divisor = max - min;
    printDebug('min = ' + min);
    printDebug('max = ' + max);
    printDebug('divisor = ' + divisor);
  
    for (i = 0; i <= map_col_num - 1; i++) {
      for (j = 0; j <= map_row_num - 1; j++) {
        map_level[i][j] = ( map_level[i, j] - min ) / divisor;
      }
    }
  }

  function get_tree_bitmask_data(i, j) {
    var b;
    var _TC;

    _TC = 'T';
    b = '';

    // -1 row
    if ((i - 1) < 0 || (j - 1) < 0) {
      b = b + '1';
    }
    else {
      if (map_char[i - 1][j - 1] != _TC) { b = b + '0'; } else { b = b + '1'; }
    }

    if ((j - 1) < 0) {
      b = b + '0';
    }
    else {
      if (map_char[i][j - 1] != _TC) { b = b + '0'; } else { b = b + '1'; }
    }

    if ((i + 1) > (map_col_num - 1) || (j - 1) < 0) {
      b = b + '0';
    }
    else {
      if (map_char[i + 1][j - 1] != _TC) { b = b + '0'; } else { b = b + '1'; }
    }

    // +0 row
    if ((i - 1) < 0) {
      b = b + '0';
    }
    else {
      if (map_char[i - 1][j] != _TC) { b = b + '0'; } else { b = b + '1'; }
    }

    if ((i + 1) > map_col_num - 1) {
      b = b + '0';
    }
    else {
      if (map_char[i + 1][j] != _TC) { b = b + '0'; } else { b = b + '1'; }
    }

    // +1 row
    if ((i - 1) < 0 || (j + 1) > (map_row_num - 1)) {
      b = b + '0';
    }
    else {
      if (map_char[i - 1][j + 1] != _TC) { b = b + '0'; } else { b = b + '1'; }
    }

    if ((j + 1) > map_row_num - 1) {
      b = b + '0';
    }
    else {
      if (map_char[i][j + 1] != _TC) { b = b + '0'; } else { b = b + '1'; }
    }

    if ((i + 1) > (map_col_num - 1) || (j + 1) > (map_row_num - 1)) {
      b = b + '0';
    }
    else {
      if (map_char[i + 1][j + 1] != _TC) { b = b + '0'; } else { b = b + '1'; }
    }

    return b;
  }

  function update_current_change_to(i, m) {
    var r;

    r = Number(tree_bitmask.bitmask[i].change_to_cur[m].row);
    r++;

    if (r > tree_bitmask.bitmask[i].change_to[m].matrix.length - 1) {
      r = 0;
    }
    tree_bitmask.bitmask[i].change_to_cur[m].row = String(r);
  }

  function smoothLandAndTree() {
    var i, j;
    var bm;
    var bm_u, bm_d;
    var _i, _j, _k, _m, _r;
    var _TC;
    var found;

    if ( (game_type == 'cf1') && (tile_type == 'jungle') ) {
      tree_bitmask = bm_cf1_jungle_tree;
    }
    //printDebug(tree_bitmask);

    //return;

    _TC = 'T';

    for (j = map_row_num - 1; j >=0; j--) {
      //printDebug(String(j));
      for (i = 0; i <= map_col_num - 1; i++) {
  
        if (map_char[i][j] == _TC) {  // 'T'
  
          bm = get_tree_bitmask_data(i, j);
          //printDebug(String(i) + ', ' + String(j) + ' = ' + bm);
          bm_u = bm.charAt(1);
          bm_d = bm.charAt(6);
          //printDebug(String(i) + ', ' + String(j) + ' = ' + bm + ' - ' + bm_u + ', ' + bm_d);
  
          // BOTTOM - BEGIN
          if ((bm_u == '1') && (bm_d == '0')) { // BOTTOM
            //printDebug('tree_bitmask.bitmask.length = ' + String(tree_bitmask.bitmask.length));
            for (_i = 0; _i <= tree_bitmask.bitmask.length - 1; _i++) {
              if (tree_bitmask.bitmask[_i].group == 'BOTTOM') {
  
                found = false;
                for (_j = 0; _j <= tree_bitmask.bitmask[_i].detect.length - 1; _j++) {
                  //printDebug(String(_j) + ' - ' + tree_bitmask.bitmask[_i].detect[_j].vector);
                  if (bm == tree_bitmask.bitmask[_i].detect[_j].vector) { found = true; }
                }
                
                if (found == true) {
                  //printDebug('BOTTOM found!')
                  
                  // change_to[0]
                  update_current_change_to(_i, 0);
                  _r = Number(tree_bitmask.bitmask[_i].change_to_cur[0].row);
                  if (j - 1 >= 0) {
                    map_tile[i][j - 1] = tree_bitmask.bitmask[_i].change_to[0].matrix[_r][0];
                    //console.log('mat00', tree_bitmask.bitmask[_i].change_to[0].matrix[_r][0]);
                    //console.log('chk00', map_tile[i][j - 1]);
                  }
                  map_tile[i][j] = tree_bitmask.bitmask[_i].change_to[0].matrix[_r][1];
                  if ((j + 1) <= (map_row_num - 1)) {
                    map_tile[i][j + 1] = tree_bitmask.bitmask[_i].change_to[0].matrix[_r][2];
                  }
                  if (tree_bitmask.bitmask[_i].change_to[0].matrix[0].length == 4) {
                    if ((j + 2) <= (map_row_num - 1)) {
                      map_tile[i][j + 2] = tree_bitmask.bitmask[_i].change_to[0].matrix[_r][3];
                    }
                  }
  
                  // change_to[1]
                  if (tree_bitmask.bitmask[_i].change_to[1].matrix.length != 0) {
                    if ((i - 1 >= 0) && (j - 1 >= 0)) {
                      if (j - 2 >= 0) {
                        if (map_char[i][j - 2] == _TC) {
                          map_tile[i - 1][j - 1] = tree_bitmask.bitmask[_i].change_to[1].matrix[0][0];
                        }
                      }
                    }
                    if (i - 1 >= 0) {
                      map_tile[i - 1][j] = tree_bitmask.bitmask[_i].change_to[1].matrix[0][1];
                    }
                  }
  
                  // change_to[2]
                  if (tree_bitmask.bitmask[_i].change_to[2].matrix.length != 0) {
                    if ((i + 1 <= map_col_num - 1) && (j - 1 >= 0)) {
                      if (j - 2 >= 0) {
                        if (map_char[i][j - 2] == _TC) {
                          map_tile[i + 1][j - 1] = tree_bitmask.bitmask[_i].change_to[2].matrix[0][0];
                        }
                      }
                    }
                    if (i + 1 <= map_col_num - 1) {
                      map_tile[i + 1][j] = tree_bitmask.bitmask[_i].change_to[2].matrix[0][1];
                    }
                  }
                  break;

                }
              }
  
            } // for _i
  
          }
          // BOTTOM - END

          // MIDDLE - BEGIN
          if ((bm_u == '1') && (bm_d = '1')) { // MIDDLE
            for (_i = 0; _i <= tree_bitmask.bitmask.length - 1; _i++) {
  
              if (tree_bitmask.bitmask[_i].group == 'MIDDLE') {
                
                found = false;
                for (_j = 0; _j <= tree_bitmask.bitmask[_i].detect.length - 1; _j++) {
                  if (bm == tree_bitmask.bitmask[_i].detect[_j].vector) { found = true; }
                }
  
                if (found == true) {
                  update_current_change_to(_i, 0);
                  _r = getRandomInt(0, tree_bitmask.bitmask[_i].change_to[0].matrix.length - 1);
                  //_r = 0;
                  //console.log(_i, i, j, 'map_tile[i][j] = ', map_tile[i][j]);
                  //console.log(_i, i, j);
                  map_tile[i][j] = tree_bitmask.bitmask[_i].change_to[0].matrix[_r][0];
  
                  // change_to[1]
                  if (tree_bitmask.bitmask[_i].change_to[1].matrix.length != 0) {
                    if (i - 1 >= 0) {
                      map_tile[i - 1][j] = tree_bitmask.bitmask[_i].change_to[1].matrix[0][0];
                    }
                  }
  
                  // change_to[2]
                  if (tree_bitmask.bitmask[_i].change_to[2].matrix.length != 0) {
                    if ((i + 1) <= (map_col_num - 1)) {
                      map_tile[i + 1][j] = tree_bitmask.bitmask[_i].change_to[2].matrix[0][0];
                    }
                  }
  
                  break;
                }
              }
            }
          }
          // MIDDLE - END

          // TOP - BEGIN
          if ((bm_u == '0') && (bm_d == '1')) { // TOP
            for (_i = 0; _i <= tree_bitmask.bitmask.length - 1; _i++) {
  
              if (tree_bitmask.bitmask[_i].group == 'TOP') {
  
                found = false;
                for (_j = 0; _j <= tree_bitmask.bitmask[_i].detect.length - 1; _j++) {
                  if (bm == tree_bitmask.bitmask[_i].detect[_j].vector) { found = true; }
                }
  
                if (found == true) {
                  update_current_change_to(_i, 0);
                  _r = getRandomInt(0, tree_bitmask.bitmask[_i].change_to[0].matrix.length - 1);
                  //_r = 0;
                  map_tile[i][j] = tree_bitmask.bitmask[_i].change_to[0].matrix[_r][0];
                }
  
              }
            }
          }   
          // TOP - END

        }
      }
    }
  }

  function getSurroundCharList(x, y) {
    var sr_list = new Array(8);

    if ((x -1 < 0) || (y - 1 < 0)) 
      sr_list[0] = '.';
    else
      sr_list[0] = map_char[x - 1][y - 1];
    
    if (y - 1 <  0)
      sr_list[1] = '.';
    else
      sr_list[1] = map_char[x][y - 1];
    
    if ((x + 1 > map_col_num - 1) || (y - 1 < 0)) 
      sr_list[2] = '.';
    else
      sr_list[2] = map_char[x + 1][y - 1];
    
    if (x - 1 < 0) 
      sr_list[3] = '.';
    else
      sr_list[3] = map_char[x - 1][y];
    
    if (x + 1 > map_col_num - 1)
      sr_list[4] = '.';
    else 
      sr_list[4] = map_char[x + 1][y];
    
    if ((x - 1 < 0) || (y + 1 > map_row_num - 1)) 
      sr_list[5] = '.';
    else
      sr_list[5] = map_char[x - 1][y + 1];
    
    if (y + 1 > map_row_num - 1) 
      sr_list[6] = '.';
    else
      sr_list[6] = map_char[x][y + 1];
    
    if ((x + 1 > map_col_num - 1) || (y + 1 > map_row_num - 1)) 
      sr_list[7] = '.';
    else
      sr_list[7] = map_char[x + 1][y + 1];
    
    return sr_list;
  }

  function getBM(arr) {
    s = '';
    for (var i = 0; i <= arr.length - 1; i++) {
      s = s + arr[i];
    }
    return s;
  }

  function fixMapChar() {
    //return;
    var i, j;
    var sr, _sr1, _sr2;
    var b, _b1, _b2;

    if ( (game_type == 'cf1') && (tile_type == 'jungle') ) {
      
      for (j = 0; j <= map_row_num - 1; j++) {
        for (i = 0; i <= map_col_num - 1; i++) {
          sr = getSurroundCharList(i, j);  
          b  = getBM(sr);
        
          // for exception in case not continuing map char issue (sequence: upper to lower order)
          //  ( . # + # T )
          // -- if center == '+' and surround == '.' then replace to '#'
          if (map_char[i][j] == '+') {
            if ( AnsiMatchStr('.', sr ) == true ) {
              map_char[i][j] = '#';
            }
          }

          /*
          // -- if center == '+' and surround == 'T' then replace to '#'
          if (map_char[i][j] == '+') {
            if ( AnsiMatchStr('T', sr ) == true ) {
              map_char[i][j] = '#';
            }
          }
          */

          // -- if center == 'T' and surround == '.' then replace to '#'
          if (map_char[i][j] == 'T') {
            if ( AnsiMatchStr('.', sr ) == true ) {
              map_char[i][j] = '#';
            }
          }

          // -- if center == 'T' and surround == '+' then replace to '#'
          if (map_char[i][j] == 'T') {
            if ( AnsiMatchStr('+', sr ) == true ) {
              map_char[i][j] = '#';
            }
          }

          // for exception in case diagonal map char issue
          ///*
          // Change +(light grass) adjacement .(water) to #(dark grass)
          if (map_char[i][j] == '+') {
            // .#
            // #+ 

            // 0 1 2
            // 3   4
            // 5 6 7

            // #: 1, 3 - . : 0 
            if ( (sr[1] == '#') && (sr[3] == '#') && (sr[0] == '.') ) {
              map_char[i][j] = '#';
            }
          
            // #: 1, 4 - . : 2 
            if ( (sr[1] == '#') && (sr[4] == '#') && (sr[2] == '.') ) {
              map_char[i][j] = '#';
            }

            // #: 3, 6 - . : 5 
            if ( (sr[3] == '#') && (sr[6] == '#') && (sr[5] == '.') ) {
              map_char[i][j] = '#';
            }

            // #: 4, 6 - . : 7 
            if ( (sr[4] == '#') && (sr[6] == '#') && (sr[7] == '.') ) {
              map_char[i][j] = '#';
            }
          }

          // Change T(light grass) adjacement +(light grass) to #(dark grass)
          if (map_char[i][j] == 'T') {
            // +#
            // #T 

            // 0 1 2
            // 3   4
            // 5 6 7

            ///*
            // #: 1, 3 - . : 0 
            if ( (sr[1] == '#') && (sr[3] == '#') && (sr[0] == '+') ) {
              map_char[i][j] = '#';
            }
          
            // #: 1, 4 - . : 2 
            if ( (sr[1] == '#') && (sr[4] == '#') && (sr[2] == '+') ) {
              map_char[i][j] = '#';
            }

            // #: 3, 6 - . : 5 
            if ( (sr[3] == '#') && (sr[6] == '#') && (sr[5] == '+') ) {
              map_char[i][j] = '#';
            }

            // #: 4, 6 - . : 7 
            if ( (sr[4] == '#') && (sr[6] == '#') && (sr[7] == '+') ) {
              map_char[i][j] = '#';
            }

          }

          // for exception, 2 lines diagonal passage
          ///*
          // ..##     ..#     .##
          // #..#  -> #..  +  ..#
          // ##..     ##.     #..
          if ( (i < map_col_num - 2) && (map_char[i][j] == '.') ) {
            _sr1 = getSurroundCharList(i, j);  
            _b1  = getBM(_sr1);  

            _sr2 = getSurroundCharList(i + 1, j);  
            _b2  = getBM(_sr2);
            
            if ( (_b1 == '..##.##.') && (_b2 == '.##.##..') ) {
              map_char[i][j] = '#';  
              map_char[i + 1][j] = '#';  
            }
          }

          // ##..     ##.     #..
          // #..#  -> #..  +  ..#
          // ..##     ..#     .##
          if ( (i < map_col_num - 2) && (map_char[i][j] == '.') ) {
            _sr1 = getSurroundCharList(i, j);  
            _b1  = getBM(_sr1);  

            _sr2 = getSurroundCharList(i + 1, j);  
            _b2  = getBM(_sr2);
            
            if ( (_b1 == '##.#...#') && (_b2 == '#...#.##') ) {
              map_char[i][j] = '#';  
              map_char[i + 1][j] = '#';  
            }
          }

          // .##     .##     ..#
          // ..#  -> ..#  +  #..
          // #..     #..     ##.
          // ##.     
          if ( (j < map_row_num - 2) && (map_char[i][j] == '.') ) {
            _sr1 = getSurroundCharList(i, j);  
            _b1  = getBM(_sr1);  

            _sr2 = getSurroundCharList(i, j + 1);  
            _b2  = getBM(_sr2);
            
            if ( (_b1 == '.##.##..') && (_b2 == '..##.##.') ) {
              map_char[i][j] = '#';  
              map_char[i][j + 1] = '#';  
            }
          }

          // ##.     ##.     #..
          // #..  -> #..  +  ..#
          // ..#     ..#     .##
          // .##     
          if ( (j < map_row_num - 2) && (map_char[i][j] == '.') ) {
            _sr1 = getSurroundCharList(i, j);  
            _b1  = getBM(_sr1);  

            _sr2 = getSurroundCharList(i, j + 1);  
            _b2  = getBM(_sr2);
            
            if ( (_b1 == '##.#...#') && (_b2 == '#....#.##') ) {
              map_char[i][j] = '#';  
              map_char[i][j + 1] = '#';  
            }
          }

          // ??? (Not confirmed)
          // #..     #..     #..
          // #..  -> #..  +  ..#
          // ..#     ..#     ..#
          // ..#     
          if ( (j < map_row_num - 2) && (map_char[i][j] == '.') ) {
            _sr1 = getSurroundCharList(i, j);  
            _b1  = getBM(_sr1);  

            _sr2 = getSurroundCharList(i, j + 1);  
            _b2  = getBM(_sr2);
            
            if ( (_b1 == '#..#...#') && (_b2 == '#...#..#') ) {
              map_char[i][j] = '#';  
              map_char[i][j + 1] = '#';  
            }
          }

          // ??? (Not confirmed)
          // ..#     ..#     ..#
          // ..#  -> ..#  +  #..
          // #..     #..     #..
          // #..     
          if ( (j < map_row_num - 2) && (map_char[i][j] == '.') ) {
            _sr1 = getSurroundCharList(i, j);  
            _b1  = getBM(_sr1);  

            _sr2 = getSurroundCharList(i, j + 1);  
            _b2  = getBM(_sr2);
            
            if ( (_b1 == '..#.##..') && (_b2 == '..##.#..') ) {
              map_char[i][j] = '#';  
              map_char[i][j + 1] = '#';  
            }
          }

          //*/
          
          // ****** NEW ******
          ///*
          // ++##     ++#     +##
          // #++#  -> #++  +  ++#
          // ##++     ##+     #++
          if ( (i < map_col_num - 2) && (map_char[i][j] == '+') ) {
            _sr1 = getSurroundCharList(i, j);  
            _b1  = getBM(_sr1);  

            _sr2 = getSurroundCharList(i + 1, j);  
            _b2  = getBM(_sr2);
            
            if ( (_b1 == '++##+##+') && (_b2 == '+##+##++') ) {
              map_char[i][j] = '#';  
              map_char[i + 1][j] = '#';  
            }
          }

          // ##++     ##+     #++
          // #++#  -> #++  +  ++#
          // ++##     ++#     +##
          if ( (i < map_col_num - 2) && (map_char[i][j] == '+') ) {
            _sr1 = getSurroundCharList(i, j);  
            _b1  = getBM(_sr1);  

            _sr2 = getSurroundCharList(i + 1, j);  
            _b2  = getBM(_sr2);
            
            if ( (_b1 == '##+#+++#') && (_b2 == '#+++#+##') ) {
              map_char[i][j] = '#';  
              map_char[i + 1][j] = '#';  
            }
          }

          // +##     +##     ++#
          // ++#  -> ++#  +  #++
          // #++     #++     ##+
          // ##+     
          if ( (j < map_row_num - 2) && (map_char[i][j] == '+') ) {
            _sr1 = getSurroundCharList(i, j);  
            _b1  = getBM(_sr1);  

            _sr2 = getSurroundCharList(i, j + 1);  
            _b2  = getBM(_sr2);
            
            if ( (_b1 == '+##+##++') && (_b2 == '++##+##+') ) {
              map_char[i][j] = '#';  
              map_char[i][j + 1] = '#';  
            }
          }

          // ##+     ##+     #++
          // #++  -> #++  +  ++#
          // ++#     ++#     +##
          // +##     
          if ( (j < map_row_num - 2) && (map_char[i][j] == '+') ) {
            _sr1 = getSurroundCharList(i, j);  
            _b1  = getBM(_sr1);  

            _sr2 = getSurroundCharList(i, j + 1);  
            _b2  = getBM(_sr2);
            
            if ( (_b1 == '##+#+++#') && (_b2 == '#++++#+##') ) {
              map_char[i][j] = '#';  
              map_char[i][j + 1] = '#';  
            }
          }

          // ??? (Not confirmed)
          // #++     #++     #++
          // #++  -> #++  +  ++#
          // ++#     ++#     ++#
          // ++#     
          if ( (j < map_row_num - 2) && (map_char[i][j] == '+') ) {
            _sr1 = getSurroundCharList(i, j);  
            _b1  = getBM(_sr1);  

            _sr2 = getSurroundCharList(i, j + 1);  
            _b2  = getBM(_sr2);
            
            if ( (_b1 == '#++#+++#') && (_b2 == '#+++#++#') ) {
              map_char[i][j] = '#';  
              map_char[i][j + 1] = '#';  
            }
          }

          // ??? (Not confirmed)
          // ++#     ++#     ++#
          // ++#  -> ++#  +  #++
          // #++     #++     #++
          // #++     
          if ( (j < map_row_num - 2) && (map_char[i][j] == '+') ) {
            _sr1 = getSurroundCharList(i, j);  
            _b1  = getBM(_sr1);  

            _sr2 = getSurroundCharList(i, j + 1);  
            _b2  = getBM(_sr2);
            
            if ( (_b1 == '++#+##++') && (_b2 == '++##+#++') ) {
              map_char[i][j] = '#';  
              map_char[i][j + 1] = '#';  
            }
          }
          //*/
        }        
      }

    }

    /*
    if ( (game_type == 'cf1') && (tile_type == 'jungle') ) {
      
      for (j = 0; j <= map_row_num - 1; j++) {
        for (i = 0; i <= map_col_num - 1; i++) {
          sr = getSurroundCharList(i, j);  
          b  = getBM(sr);
        
          if (map_char[i][j] == 'T') {
            //if (b == '########') map_char[i][j] = '#';
          }
        }
      }
    }
    */
  }

  function floodLoop(x, y, dst_c, src_c) {
    var fillL, fillR, i;  
    var in_line = 1;  
    //unsigned char c = src_c, fillC = dst_c;  
  
    /* find left side, filling along the way */  
    fillL = fillR = x;  
    while( in_line ) {  
      _map_char[fillL][y] = dst_c;
      
      if ( (fillL == 0) && (y == 0) ) {
        _big_flood = true;  
      }
      
      fillL--;  
      //in_line = (fillL < 0) ? 0 : (_map_char[fillL][y] == src_c);  

      if (fillL < 0) {
        in_line = 0;
        //_big_flood = true;
      }
      else {
        in_line = (_map_char[fillL][y] == src_c);
      }
    }  
    fillL++;  

    /* find right side, filling along the way */  
    in_line = 1;  
    while( in_line ) {  
      _map_char[fillR][y] = dst_c;  
      if ( (fillR == 0) && (y == 0) ) {
        _big_flood = true;  
      }

      fillR++;  
      //in_line = (fillR > map_col_num - 1 ) ? 0 : (_map_char[fillR][y] == src_c);  

      if (fillR > map_col_num - 1 ) {
        //_big_flood = true;
        in_line = 0;        
      }
      else {
        in_line = (_map_char[fillR][y] == src_c);
      }
    }  
    fillR--;  

    /* search top and bottom */  
    for(i = fillL; i <= fillR; i++) {  
      if ( (y > 0) && (_map_char[i][y - 1] == src_c) )  
         floodLoop(i, y - 1, dst_c, src_c);  
      if ( (y < map_row_num - 1) && (_map_char[i][y + 1] == src_c ) ) 
         floodLoop(i, y + 1, dst_c, src_c);  
    }   
  }

  function floodFill(x, y, c) {
    floodLoop(x, y, c, _map_char[x][y]);  
    _map_char[x][y] = c;  /* some buggy optimizers needed this line */   
  }

  function addSwamp() {
    //floodFill(2, 2, '~');
    //floodFill(25, 11, '~');
    //floodFill(38, 19, '~');
    //floodFill(40, 14, '~');
    //showMapChar('>> Fill Flooded map char');

    if ( (game_type == 'cf1') && (tile_type == 'jungle') ) {

      /*
      _map_char = map_char;
      for (var j = 0; j <= map_row_num - 1; j++) {
        for (var i = 0; i <= map_col_num - 1; i++) {
          if ( _map_char[i][j] == '.' ) {
            floodFill(i, j, '~');
          }
        }
      }
      map_char = _map_char;
      */

      ///*
      //print('aaa');
      for (var i = 0; i <= 31; i++) {
        var x = getRandomInt(0, map_col_num - 1);
        var y = getRandomInt(0, map_row_num - 1);

        _big_flood = false;
        //_map_char = map_char;

        for (var _j = 0; _j <= map_row_num - 1; _j++) {
          for (var _i = 0; _i <= map_col_num - 1; _i++) {
            _map_char[_i][_j] = map_char[_i][_j];
          }
        }
  
        if (_map_char[x][y] == '.') {
          floodFill(x, y, '~');
          
          if (_map_char[0][0] != '~') {
            //map_char = _map_char;

            for (var _j = 0; _j <= map_row_num - 1; _j++) {
              for (var _i = 0; _i <= map_col_num - 1; _i++) {
                map_char[_i][_j] = _map_char[_i][_j];
              }
            }    

            //print(String(x) + ', ' + String(y));
            break;  
          }
        }

      }
      //*/


      showMapChar('>> Fill Flooded map char');

      smooth_num = 4;      
      smooth[0].char1 = '.'; smooth[0].char2 = '#';
      smooth[1].char1 = '+'; smooth[1].char2 = '#';
      smooth[2].char1 = '~'; smooth[2].char2 = '#';
      smooth[3].char1 = 'T'; smooth[3].char2 = '#';
      
      /*
      smooth[0].char1 = '~'; smooth[0].char2 = '#';
      smooth[1].char1 = '+'; smooth[1].char2 = '#';
      smooth[2].char1 = 'T'; smooth[2].char2 = '#';
      */
   }

  }

  this.convertMapChar = function(_map_char) {
    var w, h;
  
    w = _map_char[0].length;
    h = _map_char.length;
    var map_char = makeArray(w, h, '#');
    for (j = 0; j <= h - 1; j++) {
      for (i = 0; i <= w - 1; i++) {
        map_char[i][j] = _map_char[j].charAt(i);
      }
    }
    return map_char;
  }
  
  this.getMapTile = function(i, j) {
	  return map_tile[i][j];
  }
  
  // Set up and run
  this.run = function(_game_type, _tile_type, _mode, _w, _h, _map, _limits) {
    var i, j;
    var time_a, time_b;

    if (programMode == 'release') {
      OpenFodder.printSmall('SMOOTHING TERRAIN FOR ' + String(_w) + ' x ' + String(_h) + ' MAP', 0, 100, true);
    }
    time_a = new Date();

    printDebug('>> SmoothEngine ' + version + ' started');
    printDebug('>> Game type : ' + _game_type);
    printDebug('>> Tile type : ' + _tile_type);
    printDebug('>> Map size : ' + String(_w) + ' x ' + String(_h));

    // Set Map Cols and Rows
    map_col_num = _w;
    map_row_num = _h;

    // Transfer raw map_levels data
    game_type = _game_type;
    tile_type = _tile_type;

    map_char = makeArray(_w, _h, '');
    _map_char = makeArray(_w, _h, '');

    if (_mode == 'level') {
      map_level = makeArray(_w, _h, 0);
      for (i = 0; i <= _w - 1; i++) {
        for (j = 0; j <= _h - 1; j++) {
          map_level[i][j] = _map[i][j];
        }
      }
    }
    else if (_mode == 'char') {
      for (i = 0; i <= _w - 1; i++) {
        for (j = 0; j <= _h - 1; j++) {
          map_char[i][j] = _map[i][j];
        }
      }
    }
    map_tile = makeArray(_w, _h, 0);

    if ( (game_type == 'cf1') && (tile_type == 'jungle') ) {
      level_num = _limits.length;
      smooth_num = 3;

      level = new Array(level_num);
      smooth = new Array(smooth_num + 1);
      for (i = 0; i <= level_num - 1; i++) {
        level[i] = new TLevel();
      }
      for (i = 0; i <= smooth_num - 1 + 1; i++) {
        smooth[i] = new TSmooth();
      }

      level[0].name = 'water';      level[0].char = '.';
      level[1].name = 'darkgrass';  level[1].char = '#';
      level[2].name = 'lightgrass'; level[2].char = '+';
      level[3].name = 'darkgrass';  level[3].char = '#';
      level[4].name = 'tree';       level[4].char = 'T';
      for (i = 0; i <= level_num - 1; i++) {
        level[i].limit = _limits[i];
      }

      smooth[0].char1 = '.'; smooth[0].char2 = '#';
      smooth[1].char1 = '+'; smooth[1].char2 = '#';
      smooth[2].char1 = 'T'; smooth[2].char2 = '#';

      //printDebug('jungle init ok');
    }
    //printDebug('init ok');

    if (_mode == 'level') {    
      createMapChar();
    }

    showMapChar('>> Original map char');

    for (i = 0; i <= 1; i++) {
      if (programMode == 'release') {
        OpenFodder.printSmall('PROCESSING STEP ' + String(i + 1), 0, 130 + i * 15, true);
      }

      printDebug('>>');
      printDebug('>> SMOOTHING PROCESS: ' + String(i));

      printDebug('>> Fixing map char... Started');
      fixMapChar();
      fixMapChar();
      printDebug('>> Fixing map char... Done');
      showMapChar('>> Fixed map char');

	    printDebug('>> Smoothing map char... Started');
      smoothMapChar();
      printDebug('>> Smoothing map char... Done');
      showMapChar('>> Smoothed map char');
    }

    addSwamp();

    printDebug('>> Smoothing water and land... Started');
    smoothWaterAndLand();
    printDebug('>> Smoothing water and land... Done');

    printDebug('>> Smoothing land and tree... Started');
    smoothLandAndTree();
    printDebug('>> Smoothing land and tree... Done');


    if (programMode == 'release') {
      OpenFodder.printSmall('DONE', 0, 160, true);
    }

    time_b = new Date();
    printDebug('>>');
    printDebug(">> Elapsed " + (time_b - time_a) / 1000 + " seconds");
    printDebug('>>');

    return map_tile;
  }

}

/*
var t = new CTest();
t.testDummy();
t.testJavaScriptSyntax();
printDebug('-dummy test done-');
printDebug('');
*/

// CSmoothTerrain Test
// -- 'level' mode test
// -- Set Test Vars
/*
var w = 16;
var h = 16;
var i, j;

// -- Set array generated from simplex map
var map_lev = makeArray(w, h, 0.0);
// -- Make test levels
for (i = 0; i <= w - 1; i++) {
  for (j = 0; j <= h - 1; j++) {
    map_lev[i][j] = 0.2;
  }
}
for (i = 0; i <= w - 1; i++) {
  map_lev[i][0] = 0.0;
  map_lev[i][1] = 0.0;
  map_lev[i][h - 2] = 0.0;
  map_lev[i][h - 1] = 0.0;
}
for (j = 0; j <= h - 1; j++) {
  map_lev[0][j] = 0.0;
  map_lev[1][j] = 0.0;
  map_lev[w - 2][j] = 0.0;
  map_lev[w - 1][j] = 0.0;
}
map_lev[8][1] = 0.4;
map_lev[5][2] = 0.0;
map_lev[1][5] = 0.4;
map_lev[5][h-2] = 0.4;
map_lev[w - 3][10] = 0.1;

// -- Set level limits
var lev_limits = [0.17, 0.25, 0.35, 0.45, 1.00];
var st = new CSmoothTerrain();
var map = st.run('cf1', 'jungle', 'level', w, h, map_lev, lev_limits);
*/

// -- 'char' mode test
if (programMode == 'debug') {

/*
var _map_char = [
  '....................',
  '....................',
  '.........#..........',
  '..##.#############..',
  '..################..',
  '..##++++++++++++##..',
  '..##+++++#++++++##..',
  '..##++######+#++##..',
  '..##++########++##..',
  '..##++##TTTT##++##..',
  '..##+###TTTT##++##..',
  '..##++##TTTT##++##..',
  '..##++##TTTT##++##..',
  '..##++########++##..',
  '..##++########++##..',
  '..##++++++++++++##..',
  '..##++++++++++++##..',
  '..#######+########..',
  '..################..',
  '....................',
  '....................'
];
*/

/*
var _map_char = [
  '....................',
  '....................',
  '.........#..........',
  '..##########.#####..',
  '..################..',
  '..###++++++++++###..',
  '..##++++++++++++##..',
  '..##++########++##..',
  '..##++########++##..',
  '..##++###TT###++##..',
  '..##++##TTTT##++##..',
  '..##++##TTTT##++##..',
  '..##++###TT###++##..',
  '..##++########++##..',
  '..##++########++##..',
  '..##++++++++++++##..',
  '..###++++++++++###..',
  '..################..',
  '..################..',
  '....................',
  '....................'
];
*/

/*
var _map_char = [
  '....................',
  '....................',
  '.........#..........',
  '..##########.#####..',
  '..################..',
  '..################..',
  '..###+++++++++####..',
  '..###++++++++++###..',
  '..###++++++++++###..',
  '..###++++++++++###..',
  '..###++++++++++###..',
  '..###++++++++++###..',
  '..###++++++++++###..',
  '..###++++++++++###..',
  '..####++++++++####..',
  '..################..',
  '..################..',
  '..################..',
  '....................',
  '....................'
];
*/

/*
var _map_char = [
  '....................',
  '....................',
  '.........#..........',
  '..##########.#####..',
  '..################..',
  '..################..',
  '..###++++++++++###..',
  '.####++++++++++###..',
  '..###++++++++++##...',
  '..###++++++++++###..',
  '..###++++++++++###..',
  '...##++++++++++###..',
  '..###++++++++++###..',
  '..###++++++++++####.',
  '..###++++++++++###..',
  '..################..',
  '..################..',
  '..##########.#####..',
  '......#.............',
  '....................'
];
*/

/*
var _map_char = [
  '....................',
  '....................',
  '.........#..........',
  '..##########.#####..',
  '..################..',
  '..###++++++++++###..',
  '..###++++++++++###..',
  '..###++######++###..',
  '..###++######++###..',
  '..###++######++###..',
  '..###++######++###..',
  '..###++######++###..',
  '..###++######++###..',
  '..###++######++###..',
  '..###++######++###..',
  '..###++######++###..',
  '..###++######++###..',
  '..###++++++++++###..',
  '..###++++++++++###..',
  '..################..',
  '..################..',
  '..##########.#####..',
  '......#.............',
  '....................'
];
*/

/*
var _map_char = [
  '..........................',
  '..........................',
  '..######################..',
  '..######################..',
  '..######################..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..######################..',
  '..######################..',
  '..........................',
  '..........................',
];
*/

/*
var _map_char = [
  '..........................',
  '..........................',
  '..######################..',
  '..######################..',
  '..######################..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++############++###..',
  '..###++############++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++############++###..',
  '..###++############++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..######################..',
  '..######################..',
  '..........................',
  '..........................',
];
*/

/*
var _map_char = [
  '..........................',
  '..........................',
  '..######################..',
  '..######################..',
  '..###++++####++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++############++###..',
  '..###++#####TTT####++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++##TTTTTTTT##++###..',
  '..###++############++###..',
  '..###++############++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..######################..',
  '..######################..',
  '..........................',
  '..........................',
];
*/

/*
var _map_char = [
  '..........................',
  '..........................',
  '.................#........',
  '...........#.....#........',
  '.....#.....#.....#........',
  '..######################..',
  '..######################..',
  '..######################..',
  '..######################..',
  '..######+###############..',
  '..######+###############..',
  '..######+###############..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++##...',
  '.####++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..####++++++++++++++++##..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++####.',
  '..###+++#++++++++++++###..',
  '..###+++#++++++++++++###..',
  '..############+#########..',
  '..######################..',
  '......#...................',
  '..........................',
];
*/

/*
var _map_char = [
  '..........................',
  '..........................',
  '....#.....##.....###......',
  '..........................',
  '....####..................',
  '..........................',
  '...............#.#........',
  '.......#..................',
  '.......##.................',
  '..........................',
  '.......#######............',
  '.......#######............',
  '.......#######............',
  '..........................',
  '..######################..',
  '..######################..',
  '..######+###############..',
  '..######+###############..',
  '..######+###############..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++##...',
  '.####++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..####++++++++++++++++##..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++###..',
  '..###++++++++++++++++####.',
  '..###+++#++++++++++++###..',
  '..###+++#++++++++++++###..',
  '..############+#########..',
  '..######################..',
  '......#...................',
  '..........................',
];
*/

/*
var _map_char = [
  '..........................',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
  '.......##############.....',
  '.......##############.....',
  '.......##############.....',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
];
*/

/*
var _map_char = [
  '..........................',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
  '........####.#######......',
  '.......#####.########.....',
  '.......#####.########.....',
  '.......#####.########.....',
  '.......#####.########.....',
  '.......#####.########.....',
  '.......#####.########.....',
  '........####.#######......',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
];
*/

/*
var _map_char = [
  '..........................',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
  '........####..######......',
  '.......#####..#######.....',
  '.......#####..#######.....',
  '.......#####..#######.....',
  '.......#####..#######.....',
  '.......#####..#######.....',
  '.......#####..#######.....',
  '........####..######......',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
];
*/

/*
var _map_char = [
  '..........................',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
  '........############......',
  '.......##############.....',
  '.......##############.....',
  '..........................',
  '.......##############.....',
  '.......##############.....',
  '.......##############.....',
  '........############......',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
];
*/

/*
var _map_char = [
  '..........................',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
  '........############......',
  '.......##############.....',
  '.......##############.....',
  '..........................',
  '.......##############.....',
  '.......##############.....',
  '.......##############.....',
  '........############......',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
];
*/

/*
var _map_char = [
  '..........................',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
  '........######..####......',
  '.......#######..#####.....',
  '.......#######..#####.....',
  '..........................',
  '..........................',
  '.......#######..#####.....',
  '.......#######..#####.....',
  '.......#######..#####.....',
  '........######..####......',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
];
*/

/*
var _map_char = [
  '..........................',
  '..........................',
  '.........T.....+++........',
  '..........................',
  '..........................',
  '.......#######+++####.....',
  '.......########++####.....',
  '.......+########+####.....',
  '.......+#############.....',
  '.......###+++##TTT###.....',
  '..........................',
  '..........................',
  '.......#####TTT######.....',
  '.......##TTTTTT######.....',
  '.......#+TTTT#######T.....',
  '.......#+##########TT.....',
  '.......###...TT..####.....',
  '.......###.......####.....',
  '.......###.......####.....',
  '.......###.......####.....',
  '.......###..+++..####.....',
  '.......##############.....',
  '.......##############.....',
  '.......##############.....',
  '.......#####+++######.....',
  '.......##############.....',
  '.......##############.....',
  '.......##TTTTT#######.....',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
];
*/

/*
var _map_char = [
  '..........................',
  '..........................',
  '..........................',
  '..........................',
  '.......####+###T#####.....',
  '.......##############.....',
  '.......########+#####.....',
  '.......#####TTTTTTT##.....',
  '.......#####TTTTTTT##.....',
  '.......#####TTTTTTT##.....',
  '.......####+TTTTTTT##.....',
  '.......#####TTTTTTT##.....',
  '.......#####TTTTTTT##.....',
  '.......#####TTTTTTT##.....',
  '.......#####TTTTTTT##.....',
  '.......########++####.....',
  '.......#######TTTT###.....',
  '.......##############.....',
  '.......##############.....',
  '.......##############.....',
  '.......##############.....',
  '.......##############.....',
  '.......##############.....',
  '.......##############.....',
  '..........................',
  '..........................',
  '..........................',
  '..........................',
];
*/

/*
var _map_char = [
'................................................................',
'................................................................',
'................................................................',
'................................................................',
'................................................................',
'................................................................',
'................................................................',
'................................................................',
'................................................................',
'................................................................',
'................################################................',
'................################################................',
'................################################................',
'................################################................',
'................################################................',
'................########++++++++++++++++########................',
'................########++++++++++++++++########................',
'........################++++++++++++++++################........',
'........################++++++++++++++++################........',
'........################++++TTTTTTTT++++################........',
'........################++++TTTTTTTT++++################........',
'........################++++TTTTTTTT++++################........',
'........################++++TTTTTTTT++++################........',
'........################++++TTTTTTTT++++################........',
'........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
'........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
'........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
'........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
'........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
'........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
'........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
'........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
'........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
'........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
'........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
'........####++++TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT++++#####........',
'........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
'........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
'........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
'........####++++++++++++++++TTTTTTTT+++++++++++++++#####........',
'........################++++TTTTTTTT++++################........',
'........################++++TTTTTTTT++++################........',
'........################++++TTTTTTTT++++################........',
'........################++++TTTTTTTT++++################........',
'........################++++TTTTTTTT++++################........',
'........################++++++++++++++++################........',
'........################++++++++++++++++################........',
'........################++++++++++++++++################........',
'........################++++++++++++++++################........',
'................################################................',
'................################################................',
'................################################................',
'................################################................',
'................################################................',
'................################################................',
'................................................................',
'................................................................',
'................................................................',
'................................................................',
'................................................................',
'................................................................',
'................................................................',
'................................................................',
'................................................................',
];
*/

var _map_char = [
  '................................................................',
  '................................................................',
  '................................................................',
  '................................................................',
  '................................................................',
  '................................................................',
  '................................................................',
  '................################################................',
  '................################################................',
  '................####...........#################................',
  '................####...........#################................',
  '................####...........#################................',
  '................####...........#################................',
  '................####...........#################................',
  '................################################................',
  '................################################................',
  '................################################................',
  '................################...........#####................',
  '................################...........#####................',
  '................################...........#####................',
  '................################...........#####................',
  '................################...........#####................',
  '................################################................',
  '................################################................',
  '................################################................',
  '................################################................',
  '................................................................',
  '................................................................',
  '................................................................',
  '................................................................',
  '................................................................',
  '................................................................',
  ];
  
var st = new CSmoothTerrain();
var map_char = st.convertMapChar(_map_char);
var w = _map_char[0].length;
var h = _map_char.length;
var lev_limits = [0, 0, 0, 0, 0];
var map = st.run('cf1', 'jungle', 'char', w, h, map_char, lev_limits);

}