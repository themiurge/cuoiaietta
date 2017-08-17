<?php

const VOWEL = 1;
const CONSONANT = 2; 
const NONE = 3;

$TRIPHTONGS = array("iai", "iei", "uoi", "uai", "uei", "iuo", "ioi", "iui");
const INSEP_CONS_PRE = "bcdfgptv";
const INSEP_CONS_POST = "lr";

function cleanChar($c)
{
    if (ctype_upper($c))
        $c = strtolower($c);
    switch ($c)
    {
        case 'è':
            $c = 'e';
            break;
        case 'é':
            $c = 'e';
            break;
        case 'à':
            $c = 'a';
            break;
        case 'ì':
            $c = 'i';
            break;
        case 'ù':
            $c = 'u';
            break;
        case 'ò':
            $c = 'o';
            break;
        case 'ç':
            $c = 'c';
            break;
        case '\'':
        case '-':
            return '\0';
    }
    return $c;
}

/*echo cleanChar('è');
echo cleanChar('à');
echo cleanChar('ò');
echo cleanChar('ù');
echo cleanChar('C');
echo $TRIPHTONGS[3];
echo '</br>';
*/
function toBeSeparated($a, $b)
{
    if ($a == $b) return true;
    switch ($a)
    {
        case 's':
            return false;
        case 'c':
        case 'g':
            if ($b == 'h' || $b == 'i') return false;
            return strpos(INSEP_CONS_POST, $b) === false;
    }
    return strpos(INSEP_CONS_PRE, $a) === false && strpos(INSEP_CONS_POST, $b) !== false;
}

function isDiphtong($a, $b)
{
    switch ($a)
    {
        case 'i':
        case 'u':
            return true;
        default:
            switch ($b)
            {
                case 'i':
                    return true;
                case 'u':
                    return $a == 'a' || $a == 'e';
            }
            return false;
    }
}


class CharGroup
{
    public $repr = '';
    public $t = 0;
    function __construct($s, $t_in)
    {
        $this->repr = $s;
        $this->t = $t_in;
    }
    function split()
    {
        global $TRIPHTONGS;
        $groupsToAdd = array();
        $toAddStacked = array();
        if (strlen($this->repr) == 1) return $groupsToAdd;
        $spl = false;
        if ($this->t == CONSONANT)
        {
            if (strlen($this->repr) >= 3)
                $spl = $this->repr[0] != 's';
            else
                $spl = toBeSeparated($this->repr[0], $this->repr[1]);
        }
        else
        {
            while (strlen($this->repr) > 3)
            {

                $lenToRemove = 1;

                if (in_array(substr($this->repr, strlen($this->repr) - 3), $TRIPHTONGS))
                    $lenToRemove = 3;
                else if (isDiphtong($this->repr[strlen($this->repr) - 2], $this->repr[strlen($this->repr) - 1]))
                    $lenToRemove = 2;

                array_push($toAddStacked, new CharGroup(substr($this->repr, strlen($this->repr) - $lenToRemove), VOWEL));
                $this->repr = substr($this->repr, 0, strlen($this->repr) - $lenToRemove);

            }
            if (strlen($this->repr) == 3)
                $spl = !in_array($this->repr, $TRIPHTONGS);
            else if (strlen($this->repr) == 2)
                $spl = !isDiphtong($this->repr[0], $this->repr[1]);
        }
        if ($spl)
        {
            $ret = new CharGroup(substr($this->repr, 1), $this->t);
            $this->repr = substr($this->repr, 0, 1);
            array_push($groupsToAdd, $ret);
        }
        while (count($toAddStacked) > 0)
            array_push($groupsToAdd, array_pop($toAddStacked));
        return $groupsToAdd;
    }
}

/*$test = new CharGroup('ttr', VOWEL);
var_dump($test->split());
var_dump($test);
*/

function getTypeFromChar($c, $before = null, $after = null)
{
    if ($c == 'i' && $before != null && ($before == 'c' || $before == 'g') && $after != null && getTypeFromChar($after) == VOWEL)
        return CONSONANT;
    return ($c == 'a' || $c == 'e' || $c == 'i' || $c == 'o' || $c == 'u' || $c == 'y') ? VOWEL : CONSONANT;
}

function getCharGroups($word)
{
    $temp = array();
    $curType = NONE;
    $curGroup = null;
    $i = 0;
    $prev = null;
    $next = null;

    // first: build all groups made of adjacent vocals/consonants
    for ($i = 0; $i < strlen($word); $i++)
    {
        $c = $word[$i];
        $next = ($i < strlen($word) - 1) ? $word[$i + 1] : null;
        $t = getTypeFromChar($c, $prev, $next);
        if ($t != $curType)
        {
            $curGroup = new CharGroup($c, $t);
            $curType = $t;
            array_push($temp, $curGroup);
        }
        else
            $curGroup->repr = $curGroup->repr . $c;
        $prev = $c;
    }

    // next: split groups if needed
    $ret = array(new CharGroup("", NONE));

    foreach ($temp as $group)
    {
        array_push($ret, $group);
        $groupsToAdd = $group->split();
        foreach ($groupsToAdd as $toAdd) array_push($ret, $toAdd);
    }

    array_push($ret, new CharGroup("", NONE));


    // finally: join groups as needed
    $temp = array();

    $i = 1;

    while ($i < count($ret) - 1)
    {
        $g = new CharGroup($ret[$i]->repr, $ret[$i]->t);

        while ($g->t == CONSONANT)
        {
            $g->repr = $g->repr . $ret[++$i]->repr;
            if ($ret[$i]->t != CONSONANT)
                $g->t = $ret[$i]->t;
        }

        if ($ret[$i]->t == VOWEL)
        {
            if ($ret[$i + 1]->t == CONSONANT && $ret[$i + 2]->t != VOWEL)
            {
                $g->repr = $g->repr . $ret[++$i]->repr;
                if ($ret[$i + 1]->t == CONSONANT && $ret[$i + 2]->t == NONE)
                    $g->repr = $g->repr . $ret[++$i]->repr;
            }
        }

        $i++;
        array_push($temp, $g);
    }

    return $temp;
}

function cleanString($s)
{
    $ret = "";
    for ($i = 0; $i < strlen($s); $i++)
    {
        $cur = cleanChar($s[$i]);
        if ($cur != '\0')
            $ret = $ret . $cur;
    }
    return $ret;
}

function getSyllables($word)
{

    $word = cleanString($word);

    $groups = getCharGroups($word);

    $ret = "";
    foreach ($groups as $group)
    {
        if ($ret != "") $ret = $ret . '-';
        $ret = $ret . $group->repr;
    }

    return $ret;

}
echo getSyllables('cuoiaietta');
?>