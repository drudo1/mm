using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MunchkinMonitor.Classes
{

    [Serializable]
    public class CurrentGamePlayer
    {
        public Player currentPlayer { get; set; }
        public CharacterModifier CurrentRace { get; set; }
        public CharacterModifier CurrentClass { get; set; }
        public Gender CurrentGender { get; set; }
        public int NextBattleModifier { get; set; }
        public int CurrentLevel { get; set; }
        public int GearBonus { get; set; }
        public int Treasures { get; set; }
        public List<CharacterHelper> Helpers { get; set; }

        public CurrentGamePlayer(Player player)
        {
            currentPlayer = player;
            CurrentGender = player.Gender;
            Helpers = new List<CharacterHelper>();
            CurrentLevel = 1;
        }

        public int FightingLevel
        {
            get
            {
                int fLevel = CurrentLevel;
                fLevel += GearBonus;
                fLevel += NextBattleModifier;
                foreach(CharacterHelper ch in Helpers)
                {
                    fLevel += ch.Bonus;
                    fLevel += ch.GearBonus;
                }

                return fLevel;
            }
        }

        public void ChangeGender(int penalty)
        {
            CurrentGender = CurrentGender == Gender.Male ? Gender.Female : Gender.Male;
            NextBattleModifier -= penalty;
        }

        public void AddHelper (CharacterHelper ch)
        {
            Helpers.Add(ch);
        }

        public void RemoveHelper (int id)
        {
            if (Helpers.Where(h => h.ID == id).Count() == 1)
                Helpers.Remove(Helpers.Where(h => h.ID == id).First());
        }
    }
}