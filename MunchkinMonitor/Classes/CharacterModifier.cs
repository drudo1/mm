using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace MunchkinMonitor.Classes
{
    public class CharacterModifier
    {
        public int ModifierID { get; set; }
        public bool isRace { get; set; }
        public bool isClass { get; set; }
        public int GameTypeID { get; set; }
        public string Description { get; set; }
        public bool WinsTies { get; set; }
        public bool LevelsForHelp { get; set; }
        public bool ExtraLevelForTenOrHigherWhenAlone { get; set; }
        public int combatBonusForHelp { get; set; }
        public List<string> turnReminders { get; set; }
        public List<string> victoryReminders { get; set; }
        public List<string> failureReminders { get; set; }

        public static List<CharacterModifier> GetModList()
        {
            List<CharacterModifier> result =  null;
            if (HttpContext.Current.Application["modList"] == null)
            {
                string path = HttpContext.Current.Server.MapPath("~/") + "modifiers.xml";
                if (!File.Exists(path))
                {
                    result = new List<CharacterModifier>();
                    result.Add(new CharacterModifier
                    {
                        ModifierID = 1,
                        isRace = true,
                        isClass = false,
                        Description = "Human",
                        WinsTies = false,
                        LevelsForHelp = false,
                        ExtraLevelForTenOrHigherWhenAlone = false,
                        combatBonusForHelp = 0,
                        turnReminders = new List<string>
                        {
                            "{EPIC}You can make a pet of any monster Level 5 or below. (See rules regarding pets.)"
                        },
                        victoryReminders = null,
                        failureReminders = null,
                    });
                    result.Add(new CharacterModifier
                    {
                        ModifierID = 2,
                        isRace = true,
                        isClass = false,
                        Description = "Dwarf",
                        WinsTies = false,
                        LevelsForHelp = false,
                        ExtraLevelForTenOrHigherWhenAlone = false,
                        combatBonusForHelp = 0,
                        turnReminders = new List<string>
                        {
                            "Carry any number of big items",
                            "{NOTEPIC}You can hold 6 cards.",
                            "{EPIC}You can hold any number of cards."
                        },
                        victoryReminders = null,
                        failureReminders = null,
                    });
                    result.Add(new CharacterModifier
                    {
                        ModifierID = 3,
                        isRace = true,
                        isClass = false,
                        Description = "Elf",
                        WinsTies = false,
                        LevelsForHelp = true,
                        ExtraLevelForTenOrHigherWhenAlone = false,
                        combatBonusForHelp = 0,
                        turnReminders = new List<string>
                        {
                            "{EPIC}You may discard up to 2 cards.  Each is worth -2 to a player or monster in combat."
                        },
                        victoryReminders = null,
                        failureReminders = new List<string>
                        {
                            "+1 to RunAway"
                        }
                    });
                    result.Add(new CharacterModifier
                    {
                        ModifierID = 4,
                        isRace = true,
                        isClass = false,
                        Description = "Gnome",
                        WinsTies = false,
                        LevelsForHelp = false,
                        ExtraLevelForTenOrHigherWhenAlone = false,
                        combatBonusForHelp = 0,
                        turnReminders = new List<string>
                        {
                            "In combat ALONE, you may play one monster as an illusion adding it's level to yours.",
                            "+1 for any non-one-shot item beginning with 'G' or 'N'.",
                            "Monsters treat you as a Halfiling",
                            "Monsters with 'Nose' in their name will never pursue you."
                        },
                        victoryReminders = null,
                        failureReminders = new List<string>
                        {
                            "{EPIC}If you successfully run away, take two face-down treasure cards."
                        }
                    });
                    result.Add(new CharacterModifier
                    {
                        ModifierID = 5,
                        isRace = true,
                        isClass = false,
                        Description = "Halfling",
                        WinsTies = false,
                        LevelsForHelp = false,
                        ExtraLevelForTenOrHigherWhenAlone = false,
                        combatBonusForHelp = 0,
                        turnReminders = new List<string>
                        {
                            "{NOTEPIC}You may sell one item each turn for double.",
                            "{EPIC}You may sell TWO items for twice their value or ONE item for 3x it's value."
                        },
                        victoryReminders = null,
                        failureReminders = new List<string>
                        {
                            "If you fail your first attempt to run away, you may discard a card and try again."
                        }
                    });
                    result.Add(new CharacterModifier
                    {
                        ModifierID = 6,
                        isRace = true,
                        isClass = false,
                        Description = "Orc",
                        WinsTies = false,
                        LevelsForHelp = false,
                        ExtraLevelForTenOrHigherWhenAlone = true,
                        combatBonusForHelp = 0,
                        turnReminders = new List<string>
                        {
                            "You may choose to lose a level to deflect a curse unless you are level 1.",
                            "Gain extral level if you defeat a monster alone by more than 10.",
                            "{EPIC}When you encounter a monster of level 1, you may simply eat it, take the level and treasures.  Foes cannot stop this.  You CAN win this way!"
                        },
                        victoryReminders = null,
                        failureReminders = null
                    });
                    result.Add(new CharacterModifier
                    {
                        ModifierID = 7,
                        isRace = false,
                        isClass = true,
                        Description = "Bard",
                        WinsTies = false,
                        LevelsForHelp = false,
                        ExtraLevelForTenOrHigherWhenAlone = false,
                        combatBonusForHelp = 0,
                        turnReminders = new List<string>
                        {
                            "Discard a card, choose an opponent and roll.  If your roll beats theirs, they must help you for nothing."
                        },
                        victoryReminders = new List<string>
                        {
                            "{NOTEPIC}Draw an extra treasure and discard one of your choice.",
                            "{EPIC}Draw TWO extra treasures and discard two of your choice."
                        },
                        failureReminders = null
                    });
                    result.Add(new CharacterModifier
                    {
                        ModifierID = 8,
                        isRace = false,
                        isClass = true,
                        Description = "Cleric",
                        WinsTies = false,
                        LevelsForHelp = false,
                        ExtraLevelForTenOrHigherWhenAlone = false,
                        combatBonusForHelp = 0,
                        turnReminders = new List<string>
                        {
                            "When drawing FACE-UP cards, you may instead draw from discard, but you must discard one from your hand for each drawn this way.",
                            "You may discard up to 3 cards against an udead monster, each card gives you +3.",
                            "{EPIC}At any time (including combat), you may discard 2 cards from your hand or the table and draw a face down treasure card.  It may be used immediately."
                        },
                        victoryReminders = null,
                        failureReminders = null
                    });
                    result.Add(new CharacterModifier
                    {
                        ModifierID = 9,
                        isRace = false,
                        isClass = true,
                        Description = "Rangeer",
                        WinsTies = false,
                        LevelsForHelp = false,
                        ExtraLevelForTenOrHigherWhenAlone = false,
                        combatBonusForHelp = 2,
                        turnReminders = new List<string>
                        {
                            "You may tame a monster (Discard current steed, and cards equal to the monster's treasures).  It's combat bonus is the same as it's treasure count.",
                            "Your help in combat is worth an extra +2.",
                            "{EPIC}You may discard your whole hand (atleast 3 cards) to immediately claim and tame a discarded monster. YOUR TURN OR NOT!"
                        },
                        victoryReminders = null,
                        failureReminders = null
                    });
                    result.Add(new CharacterModifier
                    {
                        ModifierID = 10,
                        isRace = false,
                        isClass = true,
                        Description = "Thief",
                        WinsTies = false,
                        LevelsForHelp = false,
                        ExtraLevelForTenOrHigherWhenAlone = false,
                        combatBonusForHelp = 0,
                        turnReminders = new List<string>
                        {
                            "You may discard a card to give a -2 to any player in combat. (Once per player per combat)",
                            "You may discard a card to try to steal another player's small item.  You must roll 4 or more to succeed.  If you don't succeed, lose a level.",
                            "{EPIC}On your turn, you may discard one card to steal a random card from another player's hand.  No die roll is required. (NOT DURING COMBAT)"
                        },
                        victoryReminders = null,
                        failureReminders = null
                    });
                    result.Add(new CharacterModifier
                    {
                        ModifierID = 11,
                        isRace = false,
                        isClass = true,
                        Description = "Warrior",
                        WinsTies = false,
                        LevelsForHelp = false,
                        ExtraLevelForTenOrHigherWhenAlone = false,
                        combatBonusForHelp = 0,
                        turnReminders = new List<string>
                        {
                            "You may discard up to 3 cards in combat.  Each is worth +1",
                            "You win ties.",
                            "{EPIC}2 hand items require only 1 hand for you.",
                            "{EPIC}You may carry and use 2 big items."
                        },
                        victoryReminders = null,
                        failureReminders = null
                    });
                    result.Add(new CharacterModifier
                    {
                        ModifierID = 12,
                        isRace = false,
                        isClass = true,
                        Description = "Wizard",
                        WinsTies = false,
                        LevelsForHelp = false,
                        ExtraLevelForTenOrHigherWhenAlone = false,
                        combatBonusForHelp = 0,
                        turnReminders = new List<string>
                        {
                            "You may discard up your whole hand (at least 3 cards) to charm a single monster.  Take it's treasure, but not it's levels.",
                            "{EPIC}When on the receiving end of a curse, discard a card to attempt to run from it.  (Regular run-away rules apply.)  You may do this until you succeed, give up, or run out of cards."
                        },
                        victoryReminders = null,
                        failureReminders = new List<string>
                        {
                            "You may discard up to 3 cards after rolling the die to run away.  Each adds +1 to your roll."
                        }
                    });

                    XmlSerializer serializer = new XmlSerializer(typeof(List<CharacterModifier>));
                    using (FileStream stream = File.OpenWrite(path))
                    {
                        serializer.Serialize(stream, result);
                    }
                    HttpContext.Current.Application["modList"] = result;
                    return result;
                }
                else
                {
                    XmlSerializer serializer = new XmlSerializer(typeof(List<CharacterModifier>));
                    using (FileStream stream = File.OpenRead(path))
                    {
                        result = (List<CharacterModifier>)serializer.Deserialize(stream);
                    }
                    HttpContext.Current.Application["modList"] = result;
                    return result;
                }
            }
            else return (List<CharacterModifier>)HttpContext.Current.Application["modList"];
        }
        public static List<CharacterModifier> GetRaceList()
        {
            List<CharacterModifier> modList = GetModList();
            return modList.Where(m => m.isRace).ToList();
        }
        public static List<CharacterModifier> GetClassList()
        {
            List<CharacterModifier> modList = GetModList();
            return modList.Where(m => m.isClass).ToList();
        }
        public static bool Exists(int test)
        {
            List<CharacterModifier> modList = GetModList();
            return modList.Where(m => m.ModifierID == test).Count() > 0;
        }
        public static CharacterModifier GetMod(int id)
        {
            List<CharacterModifier> modList = GetModList();
            return modList.Where(m => m.ModifierID == id).FirstOrDefault();
        }
    }
}