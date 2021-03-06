﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MunchkinMonitor.Classes
{

    [Serializable]
    public class CurrentGamePlayer
    {
        const string defaultMaleImage = "defaultMale.png";
        const string defaultFemaleImage = "defaultFemale.png";
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
        public int Bank { get; set; }
        public string showCheatCard { get; set; }
        public bool DroppedOut { get; set; }
        public bool NeedsASeat
        {
            get
            {
                if (Game.CurrentGame != null)
                    return Game.CurrentGame.NeedNextPlayer && !Game.CurrentGame.playerSeats.Contains(currentPlayer.PlayerID);
                else
                    return false;
            }
        }

        public static CurrentGamePlayer CurrentPlayer
        {
            get
            {
                if (HttpContext.Current.Session["RoomID"] != null && HttpContext.Current.Session["GameID"] != null && HttpContext.Current.Session["PlayerID"] != null)
                    return Game.CurrentGame.currentPlayer;
                else
                    return null;
            }
        }

        public CurrentGamePlayer()
        {
            currentPlayer = new Player { PlayerID = -1 };
            CurrentGender = currentPlayer.Gender;
            Helpers = new List<CharacterHelper> { new CharacterHelper { Name = "No Helpers", isHireling = false, isSteed = false, Bonus =  0, GearBonus = 0 } };
            CurrentLevel = 1;
            HalfBreed = false;
            CurrentRaceList = new List<CharacterModifier> { CharacterModifier.GetRaceList()[0], CharacterModifier.GetRaceList()[0] };
            SuperMunchkin = false;
            CurrentClassList = new List<CharacterModifier> { CharacterModifier.GetClassList()[0], CharacterModifier.GetClassList()[0] };
            Bank = 0;
        }
        public CurrentGamePlayer(Player player)
        {
            currentPlayer = player;
            CurrentGender = player.Gender;
            Helpers = new List<CharacterHelper> { new CharacterHelper { Name = "No Helpers", isHireling = false, isSteed = false, Bonus = 0, GearBonus = 0 } };
            CurrentLevel = 1;
            HalfBreed = false;
            CurrentRaceList = new List<CharacterModifier> { CharacterModifier.GetRaceList()[0], CharacterModifier.GetRaceList()[0] };
            SuperMunchkin = false;
            CurrentClassList = new List<CharacterModifier> { CharacterModifier.GetClassList()[0], CharacterModifier.GetClassList()[0] };
            Bank = 0;
        }

        public List<string> turnReminders
        {
            get
            {
                List<string> results = new List<string>();

                foreach (CharacterModifier cm in CurrentRaceList)
                {
                    results.AddRange(cm.turnReminders.Where(tr => CurrentLevel < 10 && !tr.Contains("{EPIC}")).Select(tr => tr.Replace("{NOTEPIC}", "")).Where(r => !results.Contains(r)).ToList());
                }

                foreach (CharacterModifier cm in CurrentClassList)
                {
                    results.AddRange(cm.turnReminders.Where(tr => CurrentLevel < 10 && !tr.Contains("{EPIC}")).Select(tr => tr.Replace("{NOTEPIC}", "")).Where(r => !results.Contains(r)).ToList());
                }

                foreach (CharacterHelper ch in Helpers)
                {
                    if(ch.RaceModifier != null)
                        results.AddRange(ch.RaceModifier.turnReminders.Where(tr => CurrentLevel < 10 && !tr.Contains("{EPIC}")).Select(tr => tr.Replace("{NOTEPIC}", "")).Where(r => !results.Contains(r)).ToList());
                    if (ch.ClassModifier != null)
                        results.AddRange(ch.ClassModifier.turnReminders.Where(tr => CurrentLevel < 10 && !tr.Contains("{EPIC}")).Select(tr => tr.Replace("{NOTEPIC}", "")).Where(r => !results.Contains(r)).ToList());
                }
                return results;
            }
        }

        public bool hasTurnReminders
        {
            get
            {
                return turnReminders.Count > 0;
            }
        }

        public List<string> victoryReminders
        {
            get
            {
                List<string> results = new List<string>();

                foreach (CharacterModifier cm in CurrentRaceList)
                {
                    results.AddRange(cm.victoryReminders.Where(tr => CurrentLevel < 10 && !tr.Contains("{EPIC}")).Select(tr => tr.Replace("{NOTEPIC}", "")).Where(r => !results.Contains(r)).ToList());
                }

                foreach (CharacterModifier cm in CurrentClassList)
                {
                    results.AddRange(cm.victoryReminders.Where(tr => CurrentLevel < 10 && !tr.Contains("{EPIC}")).Select(tr => tr.Replace("{NOTEPIC}", "")).Where(r => !results.Contains(r)).ToList());
                }

                foreach (CharacterHelper ch in Helpers)
                {
                    if (ch.RaceModifier != null)
                        results.AddRange(ch.RaceModifier.victoryReminders.Where(tr => CurrentLevel < 10 && !tr.Contains("{EPIC}")).Select(tr => tr.Replace("{NOTEPIC}", "")).Where(r => !results.Contains(r)).ToList());
                    if (ch.ClassModifier != null)
                        results.AddRange(ch.ClassModifier.victoryReminders.Where(tr => CurrentLevel < 10 && !tr.Contains("{EPIC}")).Select(tr => tr.Replace("{NOTEPIC}", "")).Where(r => !results.Contains(r)).ToList());
                }
                return results;
            }
        }

        public bool hasVictoryReminders
        {
            get
            {
                return victoryReminders.Count > 0;
            }
        }

        public List<string> failureReminders
        {
            get
            {
                List<string> results = new List<string>();

                foreach (CharacterModifier cm in CurrentRaceList)
                {
                    results.AddRange(cm.failureReminders.Where(tr => CurrentLevel < 10 && !tr.Contains("{EPIC}")).Select(tr => tr.Replace("{NOTEPIC}", "")).Where(r => !results.Contains(r)).ToList());
                }

                foreach (CharacterModifier cm in CurrentClassList)
                {
                    results.AddRange(cm.failureReminders.Where(tr => CurrentLevel < 10 && !tr.Contains("{EPIC}")).Select(tr => tr.Replace("{NOTEPIC}", "")).Where(r => !results.Contains(r)).ToList());
                }

                foreach (CharacterHelper ch in Helpers)
                {
                    if (ch.RaceModifier != null)
                        results.AddRange(ch.RaceModifier.failureReminders.Where(tr => CurrentLevel < 10 && !tr.Contains("{EPIC}")).Select(tr => tr.Replace("{NOTEPIC}", "")).Where(r => !results.Contains(r)).ToList());
                    if (ch.ClassModifier != null)
                        results.AddRange(ch.ClassModifier.failureReminders.Where(tr => CurrentLevel < 10 && !tr.Contains("{EPIC}")).Select(tr => tr.Replace("{NOTEPIC}", "")).Where(r => !results.Contains(r)).ToList());
                }
                return results;
            }
        }

        public bool hasFailureReminders
        {
            get
            {
                return failureReminders.Count > 0;
            }
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

        public int AllyLevel
        {
            get
            {
                int fLevel = CurrentLevel;
                fLevel += GearBonus;
                fLevel += NextBattleModifier;
                foreach (CharacterHelper ch in Helpers)
                {
                    fLevel += ch.Bonus;
                    fLevel += ch.GearBonus;
                }
                foreach(CharacterModifier cm in CurrentClassList)
                    fLevel += cm.combatBonusForHelp;
                foreach (CharacterModifier cm in CurrentRaceList)
                    fLevel += cm.combatBonusForHelp;

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
                return Helpers.Where(h => h.Name != "No Helpers").Count() > 0;
            }
        }
        public bool HasHirelings
        {
            get
            {
                return Hirelings.Count > 0;
            }
        }
        public bool HasSteeds
        {
            get
            {
                return Steeds.Count > 0;
            }
        }
        public List<CharacterHelper> Hirelings
        {
            get
            {
                return Helpers.Where(h => h.isHireling).ToList();
            }
        }
        public List<CharacterHelper> Steeds
        {
            get
            {
                return Helpers.Where(h => h.isSteed && h.Name != "No Helpers").ToList();
            }
        }
        public List<CharacterHelper> OrderedHelpers
        {
            get
            {
                return Helpers.OrderBy(h => h.isHireling ? 1 : 2).ThenBy(h => h.Name).ToList();
            }
        }

        public string ImagePath
        {
            get
            {
                return "Images/" + (CurrentGender == Gender.Male ? (string.IsNullOrWhiteSpace(currentPlayer.customImagePathMale) ? defaultMaleImage : ("Custom/" + currentPlayer.customImagePathMale)) : (string.IsNullOrWhiteSpace(currentPlayer.customImagePathFemale) ? defaultFemaleImage : ("Custom/" + currentPlayer.customImagePathFemale)));
            }
        }

        public void ChangeGender(int penalty)
        {
            CurrentGender = CurrentGender == Gender.Male ? Gender.Female : Gender.Male;
            NextBattleModifier -= penalty;
            GameStats.LogGenderChange(currentPlayer.PlayerID);
        }

        public void Die()
        {
            GearBonus = 0;
            Helpers = new List<CharacterHelper> { new CharacterHelper { Name = "No Helpers", isHireling = false, isSteed = false, Bonus = 0, GearBonus = 0 } };
            HalfBreed = false;
            CurrentRaceList = new List<CharacterModifier> { CharacterModifier.GetRaceList()[0], CharacterModifier.GetRaceList()[0] };
            SuperMunchkin = false;
            CurrentClassList = new List<CharacterModifier> { CharacterModifier.GetClassList()[0], CharacterModifier.GetClassList()[0] };
            GameStats.LogDeath(currentPlayer.PlayerID);
        }

        public void AddHelper (bool steed, int bonus)
        {
            if(Helpers.Where(h => h.Name == "No Helpers").Count() > 0)
                Helpers.Remove(Helpers.Where(h => h.Name == "No Helpers").FirstOrDefault());
            List<string> names = CharacterHelper.GetNameList(steed).Where(n => (steed && !Steeds.Select(s => s.Name).Contains(n)) || (!steed && !Hirelings.Select(h => h.Name).Contains(n))).ToList();
            Random r = new Random();
            int index = r.Next(names.Count);
            string name = names[index];
            Helpers.Add(new CharacterHelper(name, steed, bonus));
        }

        public void RemoveHelper (Guid id)
        {
            if (Helpers.Where(h => h.ID == id).Count() == 1)
                Helpers.Remove(Helpers.Where(h => h.ID == id).First());
            if (Helpers.Count == 0)
                Helpers.Add(new CharacterHelper("No Helpers", true, 0));
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

        public void SellItem(int amount)
        {
            Bank += amount;
            int levels = Bank / 1000;
            for(int i = 0; i< levels; i++)
            {
                if (CurrentLevel < (Game.CurrentGame.isEpic ? 18 : 9))
                    CurrentLevel = CurrentLevel + 1;
            }
            Bank = Bank % 1000;
            GameStats.LogSale(currentPlayer.PlayerID, amount);
        }
    }
}