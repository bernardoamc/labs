use phf::phf_map;

// Obtained from: https://www3.nd.edu/~busiforc/handouts/cryptography/Letter%20Frequencies.html#Results_from_Project_Gutenberg

static LETTERS: phf::Map<&'static str, f64> = phf_map! {
    "e" => 0.12575645,
    "t" => 0.09085226,
    "a" => 0.08000395,
    "o" => 0.07591270,
    "i" => 0.06920007,
    "n" => 0.06903785,
    "s" => 0.06340880,
    "h" => 0.06236609,
    "r" => 0.05959034,
    "d" => 0.04317924,
    "l" => 0.04057231,
    "u" => 0.02841783,
    "c" => 0.02575785,
    "m" => 0.02560994,
    "f" => 0.02350463,
    "w" => 0.02224893,
    "g" => 0.01982677,
    "y" => 0.01900888,
    "p" => 0.01795742,
    "b" => 0.01535701,
    "v" => 0.00981717,
    "k" => 0.00739906,
    "x" => 0.00179556,
    "j" => 0.00145188,
    "q" => 0.00117571,
    "z" => 0.00079130,
};

static BIGRAMS: phf::Map<&'static str, f64> = phf_map! {
    "th" => 0.03882543,
    "he" => 0.03681391,
    "in" => 0.02283899,
    "er" => 0.02178042,
    "an" => 0.02140460,
    "re" => 0.01749394,
    "nd" => 0.01571977,
    "on" => 0.01418244,
    "en" => 0.01383239,
    "at" => 0.01335523,
    "ou" => 0.01285484,
    "ed" => 0.01275779,
    "ha" => 0.01274742,
    "to" => 0.01169655,
    "or" => 0.01151094,
    "it" => 0.01134891,
    "is" => 0.01109877,
    "hi" => 0.01092302,
    "es" => 0.01092301,
    "ng" => 0.01053385,
};

static TRIGRAMS: phf::Map<&'static str, f64> = phf_map! {
    "the" => 0.03508232,
    "and" => 0.01593878,
    "ing" => 0.01147042,
    "her" => 0.00822444,
    "hat" => 0.00650715,
    "his" => 0.00596748,
    "tha" => 0.00593593,
    "ere" => 0.00560594,
    "for" => 0.00555372,
    "ent" => 0.00530771,
    "ion" => 0.00506454,
    "ter" => 0.00461099,
    "was" => 0.00460487,
    "you" => 0.00437213,
    "ith" => 0.00431250,
    "ver" => 0.00430732,
    "all" => 0.00422758,
    "wit" => 0.00397290,
    "thi" => 0.00394796,
    "tio" => 0.00378058,
};

static QUADRIGRAMS: phf::Map<&'static str, f64> = phf_map! {
    "that" => 0.00761242,
    "ther" => 0.00604501,
    "with" => 0.00573866,
    "tion" => 0.00551919,
    "here" => 0.00374549,
    "ould" => 0.00369920,
    "ight" => 0.00309440,
    "have" => 0.00290544,
    "hich" => 0.00284292,
    "whic" => 0.00283826,
    "this" => 0.00276333,
    "thin" => 0.00270413,
    "they" => 0.00262421,
    "atio" => 0.00262386,
    "ever" => 0.00260695,
    "from" => 0.00258580,
    "ough" => 0.00253447,
    "were" => 0.00231089,
    "hing" => 0.00229944,
    "ment" => 0.00223347,
};

pub enum NgramKind {
    Letter,
    Bigram,
    Trigram,
    Quadrigam,
}

pub fn fetch(keyword: &str) -> f64 {
    match keyword.len() {
        1 => *LETTERS.get(keyword).unwrap_or(&0.0),
        2 => *BIGRAMS.get(keyword).unwrap_or(&0.0),
        3 => *TRIGRAMS.get(keyword).unwrap_or(&0.0),
        4 => *QUADRIGRAMS.get(keyword).unwrap_or(&0.0),
        _ => 0.0
    }
}
