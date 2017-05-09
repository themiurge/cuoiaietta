using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Syllables
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        enum enumGroupType { VOWEL, CONSONANT, NONE }

        static char cleanChar(char c)
        {
            c = char.ToLower(c);
            switch (c)
            {
                case 'è':
                case 'é':
                    c = 'e';
                    break;
                case 'à':
                    c = 'a';
                    break;
                case 'ì':
                    c = 'i';
                    break;
                case 'ù':
                    c = 'u';
                    break;
                case 'ò':
                    c = 'o';
                    break;
                case 'ç':
                    c = 'c';
                    break;
                case '\'':
                case '-':
                    return '\0';
            }
            return c;
        }

        static List<string> TRIPHTONGS = new List<string>() { "iai", "iei", "uoi", "uai", "uei", "iuo", "ioi", "iui" };

        class CharGroup
        {
            public CharGroup(string s, enumGroupType type)
            {
                this.repr = s;
                this.type = type;
            }
            public string repr;
            public enumGroupType type;
            public List<CharGroup> split()
            {
                List<CharGroup> groupsToAdd = new List<CharGroup>();
                Stack<CharGroup> toAddStacked = new Stack<CharGroup>();
                if (repr.Length == 1) return groupsToAdd;
                bool split = false;
                if (type == enumGroupType.CONSONANT)
                {
                    if (repr.Length >= 3)
                        split = repr[0] != 's';
                    else
                        split = toBeSeparated(repr[0], repr[1]);
                }
                else
                {
                    while (repr.Length > 3)
                    {

                        int lenToRemove = 1;

                        if (TRIPHTONGS.Contains(repr.Substring(repr.Length - 3)))
                            lenToRemove = 3;
                        else if (isDiphtong(repr[repr.Length - 2], repr[repr.Length - 1]))
                            lenToRemove = 2;

                        toAddStacked.Push(new CharGroup(repr.Substring(repr.Length - lenToRemove), enumGroupType.VOWEL));
                        repr = repr.Substring(0, repr.Length - lenToRemove);

                    }
                    if (repr.Length == 3)
                        split = !TRIPHTONGS.Contains(repr);
                    else if (repr.Length == 2)
                        split = !isDiphtong(repr[0], repr[1]);
                }
                if (split)
                {
                    CharGroup ret = new CharGroup(repr.Substring(1), this.type);
                    repr = repr[0].ToString();
                    groupsToAdd.Add(ret);
                }
                while (toAddStacked.Count > 0)
                    groupsToAdd.Add(toAddStacked.Pop());
                return groupsToAdd;
            }
        }

        static enumGroupType getTypeFromChar(char c, char? before = null, char? after = null)
        {
            if (c == 'i' && before.HasValue && (before == 'c' || before == 'g') && after.HasValue && getTypeFromChar(after.Value) == enumGroupType.VOWEL)
                return enumGroupType.CONSONANT;
            return (c == 'a' || c == 'e' || c == 'i' || c == 'o' || c == 'u' || c == 'y') ? enumGroupType.VOWEL : enumGroupType.CONSONANT;
        }

        static bool isDiphtong(char a, char b)
        {
            switch (a)
            {
                case 'i':
                case 'u':
                    return true;
                default:
                    switch (b)
                    {
                        case 'i':
                            return true;
                        case 'u':
                            return a == 'a' || a == 'e';
                    }
                    return false;
            }
        }

        const string INSEP_CONS_PRE = "bcdfgptv";
        const string INSEP_CONS_POST = "lr";

        static bool toBeSeparated(char a, char b)
        {
            if (a == b) return true;
            switch (a)
            {
                case 's':
                    return false;
                case 'c':
                case 'g':
                    if (b == 'h' || b == 'i') return false;
                    return !INSEP_CONS_POST.Contains(b);
            }
            return !(INSEP_CONS_PRE.Contains(a) && INSEP_CONS_POST.Contains(b));
        }

        static string cleanString(string s)
        {
            string ret = "";
            foreach (char c in s)
            {
                char cur = cleanChar(c);
                if (cur != '\0')
                    ret += cur;
            }
            return ret;
        }

        private List<CharGroup> getCharGroups(string word)
        {
            List<CharGroup> temp = new List<CharGroup>();
            enumGroupType curType = enumGroupType.NONE;
            CharGroup curGroup = null;
            int i = 0;
            char? prev = null;
            char? next = null;


            for (i = 0; i < word.Length; i++)
            {
                char c = word[i];
                next = (i < word.Length - 1) ? (char?)word[i + 1] : null;
                enumGroupType t = getTypeFromChar(c, prev, next);
                if (t != curType)
                {
                    curGroup = new CharGroup(c.ToString(), t);
                    curType = t;
                    temp.Add(curGroup);
                }
                else
                    curGroup.repr += c;
                prev = c;
            }

            List<CharGroup> ret = new List<CharGroup>() { new CharGroup("", enumGroupType.NONE) };

            foreach (var group in temp)
            {
                ret.Add(group);
                var groupsToAdd = group.split();
                foreach (var toAdd in groupsToAdd) ret.Add(toAdd);
            }

            ret.Add(new CharGroup("", enumGroupType.NONE));

            temp = new List<CharGroup>();

            i = 1;

            while (i < ret.Count - 1)
            {
                CharGroup g = new CharGroup(ret[i].repr, ret[i].type);

                while (g.type == enumGroupType.CONSONANT)
                {
                    g.repr += ret[++i].repr;
                    if (ret[i].type != enumGroupType.CONSONANT)
                        g.type = ret[i].type;
                }

                if (ret[i].type == enumGroupType.VOWEL)
                {
                    if (ret[i + 1].type == enumGroupType.CONSONANT && ret[i + 2].type != enumGroupType.VOWEL)
                    {
                        g.repr += ret[++i].repr;
                        if (ret[i + 1].type == enumGroupType.CONSONANT && ret[i + 2].type == enumGroupType.NONE)
                            g.repr += ret[++i].repr;
                    }
                }

                i++;
                temp.Add(g);
            }

            return temp;
        }

        private string getSyllables(string word)
        {

            word = cleanString(word);

            List<CharGroup> groups = getCharGroups(word);

            string ret = "";
            foreach (var group in groups)
            {
                if (ret != "") ret += '-';
                ret += group.repr;
            }

            return ret;

        }

        private void txtSource_TextChanged(object sender, EventArgs e)
        {
            string[] words = txtSource.Text.Split(' ').Select(s => s.Trim()).ToArray();
            txtStandard.Text = "";
            foreach (var word in words)
            {
                if (txtStandard.Text != "") txtStandard.Text += " ";
                txtStandard.Text += getSyllables(word);

            }
        }
    }
}
