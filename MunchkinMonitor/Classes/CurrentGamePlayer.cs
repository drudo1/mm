﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MunchkinMonitor.Classes
{

    [Serializable]
    public class CurrentGamePlayer
    {
        public Player currentPlayer { get; set; }
        public bool HalfBreed { get; set; }
        public List<CharacterModifier> CurrentRaceList { get; set; }
        public bool SuperMunchkin { get; set; }
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
            HalfBreed = false;
            CurrentRaceList = new List<CharacterModifier> { CharacterModifier.GetRaceList()[0], CharacterModifier.GetRaceList()[0] };
            SuperMunchkin = false;
            CurrentClassList = new List<CharacterModifier> { CharacterModifier.GetClassList()[0], CharacterModifier.GetClassList()[0] };
        }
        public CurrentGamePlayer(Player player)
        {
            currentPlayer = player;
            CurrentGender = player.Gender;
            Helpers = new List<CharacterHelper>();
            CurrentLevel = 1;
            HalfBreed = false;
            CurrentRaceList = new List<CharacterModifier> { CharacterModifier.GetRaceList()[0], CharacterModifier.GetRaceList()[0] };
            SuperMunchkin = false;
            CurrentClassList = new List<CharacterModifier> { CharacterModifier.GetClassList()[0], CharacterModifier.GetClassList()[0] };
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
                return HalfBreed ? string.Join("/", CurrentRaceList.Select(r => r.Description)) : CurrentRaceList[0].Description;
            }
        }
        public string currentClasses
        {
            get
            {
                return SuperMunchkin ? string.Join("/", CurrentClassList.Select(r => r.Description)) : CurrentClassList[0].Description;
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

        public void ToggleHalfBreed()
        {
            HalfBreed = !HalfBreed;
            if (!HalfBreed)
                CurrentRaceList[1] = CharacterModifier.GetRaceList()[0];
        }

        public void NextRace()
        {
            List<CharacterModifier> list = CharacterModifier.GetRaceList();
            int idx = list.IndexOf(CurrentRaceList[0]);
            idx = (idx + 1) % list.Count;
            CurrentRaceList[0] = list[idx];
        }

        public void NextHalfBreed()
        {
            List<CharacterModifier> list = CharacterModifier.GetRaceList();
            if (HalfBreed && CurrentRaceList.Count == 1)
                CurrentRaceList.Add(list[0]);
            else  if(CurrentRaceList.Count == 2)
            {
                int idx = list.IndexOf(CurrentRaceList[1]);
                idx = (idx + 1) % list.Count;
                CurrentRaceList[1] = list[idx];
            }
        }

        public void ToggleSuperMunchkin()
        {
            SuperMunchkin = !SuperMunchkin;
            if (!SuperMunchkin)
                CurrentClassList[1] = CharacterModifier.GetClassList()[0];
        }

        public void NextClass()
        {
            List<CharacterModifier> list = CharacterModifier.GetClassList();
            int idx = list.IndexOf(CurrentClassList[0]);
            idx = (idx + 1) % list.Count;
            CurrentClassList[0] = list[idx];
        }

        public void NextSMClass()
        {
            List<CharacterModifier> list = CharacterModifier.GetClassList();
            if (SuperMunchkin && CurrentClassList.Count == 1)
                CurrentClassList.Add(list[0]);
            else if (CurrentClassList.Count == 2)
            {
                int idx = list.IndexOf(CurrentClassList[1]);
                idx = (idx + 1) % list.Count;
                CurrentClassList[1] = list[idx];
            }
        }
    }
}