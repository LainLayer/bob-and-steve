/*
    This file defines the common structs and enums used throughout this program
    as well as procedures related to those types
*/

/*
     _____
    |_   _|   _ _ __   ___  ___
      | || | | | '_ \ / _ \/ __|
      | || |_| | |_) |  __/\__ \
      |_| \__, | .__/ \___||___/
          |___/|_|
    ============================
*/

BaseStat :: enum u8 {
    STRENGTH  :: 0;
    REFLEX    :: 1;
    INTELLECT :: 2;
}

Stat :: enum s8 {
    /* Relative to humans in the setting*/

    Bad          :: -1;
    Average      ::  0;
    AboveAverage ::  1;
    Professional ::  2;
    WorldClass   ::  3;
    Strongest    ::  4;

    /* Beyond possible human capabilities */
    // TODO: add more levels.
    AddMoreLevels :: 5;
}

Skill :: struct {
    name: string;
    base: BaseStat;
    stat: Stat;
}

Vocation :: struct {
    name: string;
    base: BaseStat;
    stat: Stat;
    skills: [..]Skill;
}

Injury :: enum u8 {
    Minor  :: 1;
    Small  :: 2;
    Medium :: 3;
    Large  :: 4;
    Fatal  :: 5;
}

Armor_Level :: enum u8 {
    NO_ARMOR      :: 0;
    MINIMAL_ARMOR :: 1;
    MEDIUM_ARMOR  :: 2;
    HEAVY_ARMOR   :: 4;
}

Entity_State :: enum u8 {
    STANDING;
    STAGGERED;
    PRONE;
    INCAPACITATED;
}

Entity :: struct {
    name:  string;
    color: Vector4;

    /* From the bottom left like in simp */
    x: u8;
    y: u8;

    union {
        struct {
            strength:  Stat;
            reflex:    Stat;
            intellect: Stat;
        };
        base_stats: [3]Stat;
    }

    union {
        struct {
            /* Strength based */
            endurance: Skill;
            athletics: Skill;
            grip:      Skill;
            swim:      Skill;
            throw:     Skill;

            /* Reflex based */
            perception:      Skill;
            acrobatics:      Skill;
            ride_pilot:      Skill;
            sleight_of_hand: Skill;
            stealth:         Skill;

            /* Intellect based */
            general_knowledge: Skill;
            deception:         Skill;
            infiltration:      Skill;
            persuasion:        Skill;
            survival:          Skill;
        }
        skills: [5 * 3]Skill;
    }

    vocations: [..]Vocation;
    injuries:  [..]Injury;

    armor: Armor_Level;

    state: Entity_State;
}

/*
     _____                 _   _
    |  ___|   _ _ __   ___| |_(_) ___  _ __  ___
    | |_ | | | | '_ \ / __| __| |/ _ \| '_ \/ __|
    |  _|| |_| | | | | (__| |_| | (_) | | | \__ \
    |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
    =============================================
*/

make_entity :: (target: *Entity, entity_name: string) {
    using target;

    name = entity_name;

    color = Vector4.{1,0,0,1};

    x = 1;
    y = 1;

    memset(*base_stats, xx Stat.Average, 3 * size_of(Stat));

    endurance         = Skill.{"Endurance"        , .STRENGTH, .Average};
    athletics         = Skill.{"Athletics"        , .STRENGTH, .Average};
    grip              = Skill.{"Grip"             , .STRENGTH, .Average};
    swim              = Skill.{"Swim"             , .STRENGTH, .Average};
    throw             = Skill.{"Throw"            , .STRENGTH, .Average};

    perception        = Skill.{"Perception"       , .REFLEX, .Average};
    acrobatics        = Skill.{"Acrobatics"       , .REFLEX, .Average};
    ride_pilot        = Skill.{"Ride/Pilot"       , .REFLEX, .Average};
    sleight_of_hand   = Skill.{"Sleight of Hand"  , .REFLEX, .Average};
    stealth           = Skill.{"Stealth"          , .REFLEX, .Average};

    general_knowledge = Skill.{"General Knowledge", .INTELLECT, .Average};
    deception         = Skill.{"Deception"        , .INTELLECT, .Average};
    infiltration      = Skill.{"Infiltration"     , .INTELLECT, .Average};
    persuasion        = Skill.{"Persuasion"       , .INTELLECT, .Average};
    survival          = Skill.{"Survival"         , .INTELLECT, .Average};

    armor = .MINIMAL_ARMOR;

    state = .STANDING;
}

