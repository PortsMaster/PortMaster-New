
PhaseName.Desert = {
        
    // Thanks to
    // https://www.fantasynamegenerators.com/desert-names.php

    names1 : ["Haunted","Naked","Angry","Arctic","Arid","Bare","Barren","Black","Bleak","Boiling","BoneDry","Burned","Burning","Calm","Calmest","Charmed","Cunning","Cursed","Dangerous","Dark","Darkest","Dead","Decayed","Decaying","Dehydrated","Depraved","Deserted","Desolate","Desolated","Distant","Dread","Dreaded","Dreadful","Dreary","Dry","Eastern","Empty","Enchanted","Ethereal","Ever Reaching","Everlasting","Feared","Fearsome","Fiery","Flat","Forbidden","Forbidding","Frightening","Frozen","Grave","Grim","Hellish","Homeless","Hopeless","Hot","Hungry","Infernal","Infinite","Isolated","Killing","Laughing","Lifeless","Light","Lightest","Lonely","Malevolent","Malicious","Mighty","Mirrored","Misty","Moaning","Monotonous","Motionless","Mysterious","Narrow","Neverending","Northern","Open","Painful","Parched","Perfumed","Quiet","Raging","Red","Restless","Rocky","Sad","Sandy","Sanguine","Savage","Scorching","Scorched","Shadowed","Silent","Sly","Soundless","Southern","Sterile","Thundering","Treacherous","Twisting","Uncanny","Uninteresting","Uninviting","Unknown","Unresting","Unwelcoming","Vast","Violent","Voiceless","Waterless","Western","Whispering","White","Windy","Withered","Yelling","Yellow"],
    names2 : ["Badlands","Barrens","Borderlands","Desert","Expanse","Fields","Grasslands","Hinterland","Prairie","Savanna","Steppes","Tundra","Wasteland","Wastes","Wilderness","Wilds","Emptiness","Frontier","Flatlands"],

    nameGen: function() {

        i = Map.getRandomInt(0, 10);
        rnd = Map.getRandomFloat(0, 1) * this.names1.length | 0;
        rnd2 = Map.getRandomFloat(0, 1) * this.names2.length | 0;
        if(i < 5){
            name = "The " + this.names1[rnd] + " " + this.names2[rnd2];
        }else{
            name = this.names1[rnd] + " " + this.names2[rnd2];
        }

        return name;
    },

    Random: function() {
        return this.nameGen();
    }
};
