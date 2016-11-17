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
        public List<CharacterModifier> CurrentRaceList { get; set; }
        public List<CharacterModifier> CurrentClassList { get; set; }
        public Gender CurrentGender { get; set; }
        public int NextBattleModifier { get; set; }
        public int CurrentLevel { get; set; }
        public int GearBonus { get; set; }
        public int Treasures { get; set; }
        public List<CharacterHelper> Helpers { get; set; }

        public CurrentGamePlayer()
        {
            currentPlayer = new Player { PlayerID = -1 };
            CurrentGender = currentPlayer.Gender;
            Helpers = new List<CharacterHelper>();
            CurrentLevel = 1;
            CurrentRaceList = new List<CharacterModifier> { CharacterModifier.GetMod(1) };
            CurrentClassList = new List<CharacterModifier>();
        }
        public CurrentGamePlayer(Player player)
        {
            currentPlayer = player;
            CurrentGender = player.Gender;
            Helpers = new List<CharacterHelper>();
            CurrentLevel = 1;
            CurrentRaceList = new List<CharacterModifier> { CharacterModifier.GetMod(1) };
            CurrentClassList = new List<CharacterModifier>();
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
        public string currentRaces
        {
            get
            {
                return string.Join("//", CurrentRaceList.Select(r => r.Description));
            }
        }
        public string currentClasses
        {
            get
            {
                return CurrentClassList.Count > 0 ? string.Join("//", CurrentClassList.Select(r => r.Description)) : "None";
            }
        }
        public bool HasHelpers
        {
            get
            {
                return Helpers.Count > 0;
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

        public void AddRace(int id)
        {
            if (CharacterModifier.Exists(id))
            {
                CurrentRaceList.Add(CharacterModifier.GetMod(id));
                RemoveRace(1);
            }
        }
        public void RemoveRace(int id)
        {
            if (CurrentRaceList.Where(r => r.ModifierID == id).Count() > 0)
                CurrentRaceList.Remove(CurrentRaceList.Where(r => r.ModifierID == id).First());
            if (CurrentRaceList.Count == 0)
                CurrentRaceList.Add(CharacterModifier.GetMod(1));
        }

        public void AddClass(int id)
        {
            if(CharacterModifier.Exists(id))
                CurrentClassList.Add(CharacterModifier.GetMod(id));
        }
        public void RemoveClass(int id)
        {
            if (CurrentClassList.Where(r => r.ModifierID == id).Count() > 0)
                CurrentClassList.Remove(CurrentClassList.Where(r => r.ModifierID == id).First());
        }
    }
}