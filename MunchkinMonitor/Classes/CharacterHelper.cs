using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace MunchkinMonitor.Classes
{
    public class CharacterHelper
    {
        public Guid ID { get; set; }
        public string Name { get; set; }
        public bool isHireling { get; set; }
        public bool isSteed { get; set; }
        public int Bonus { get; set; }
        public CharacterModifier RaceModifier { get; set; }
        public CharacterModifier ClassModifier { get; set; }
        public int GearBonus { get; set; }
        public string RaceClass
        {
            get
            {
                if (RaceModifier == null && ClassModifier == null)
                    return "None";
                else if (RaceModifier == null)
                    return ClassModifier.Description;
                else if (ClassModifier == null)
                    return RaceModifier.Description;
                else
                    return RaceModifier.Description + "/" + ClassModifier.Description;
            }
        }
        public string Race
        {
            get
            {
                return RaceModifier == null ? "None" : RaceModifier.Description;
            }
        }
        public string Class
        {
            get
            {
                return ClassModifier == null ? "None" : ClassModifier.Description;
            }
        }

        public CharacterHelper()
        { }

        public CharacterHelper(string name, bool steed, int bonus)
        {
            ID = Guid.NewGuid();
            Name = name;
            isHireling = !steed;
            isSteed = steed;
            Bonus = bonus;
            RaceModifier = steed ? null : CharacterModifier.GetRaceList()[0];
            ClassModifier = steed ? null : CharacterModifier.GetClassList()[0];
        }

        public static List<string> GetNameList(bool steed)
        {
            List<string> names = null;
            XmlSerializer serializer = new XmlSerializer(typeof(List<string>));
            string path = HttpContext.Current.Server.MapPath("~/") + string.Format("{0}Names.xml", steed ? "steed" : "hireling");
            if (!File.Exists(path))
            {
                if (steed)
                    names = new List<string>
                    {
                        "Precious",
                        "Spike",
                        "Whiskers",
                        "Spot",
                        "Tinkerbell",
                        "Gluestick",
                        "Sparkles",
                        "Thunder",
                        "Jessup",
                        "Fleabag",
                        "Shadow"
                    };
                else
                    names = new List<string>
                    {
                        "Barney",
                        "Fred",
                        "Bob",
                        "Rufus",
                        "Ted",
                        "John",
                        "Bill",
                        "Joe",
                        "Frank",
                        "Jim",
                        "Conan",
                        "Thor",
                        "Mike",
                        "Matt"
                    };
                using (FileStream stream = File.OpenWrite(path))
                {
                    serializer.Serialize(stream, names);
                }
            }
            else
            {
                using (FileStream stream = File.OpenRead(path))
                {
                    names = (List<string>)serializer.Deserialize(stream);
                }
            }
            return names;
        }
        public void ChangeRace()
        {
            List<CharacterModifier> list = CharacterModifier.GetRaceList();
            int idx = list.IndexOf(RaceModifier);
            idx = (idx + 1) % list.Count;
            RaceModifier = list[idx];
        }
        public void ChangeClass()
        {
            List<CharacterModifier> list = CharacterModifier.GetClassList();
            int idx = list.IndexOf(ClassModifier);
            idx = (idx + 1) % list.Count;
            ClassModifier = list[idx];
        }
    }
}