#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "trie.h"

/**
 * Initialize a Trie struct setting its pointers to zero and boolean to false.
 *
 * Returns nothing.
 */
void TrieInitialize(Trie *trie) {
  trie->exists = false;
  memset(trie->alphabet, 0, sizeof(trie->alphabet));
}

/**
 * Inserts a string inside the Trie.
 *
 * Returns 0 on success or 1 on error.
 */
int TrieInsert(Trie *trie, char *name) {
  int letter = *name - 'a';

  if (*name == '\0')
  {
    trie->exists = true;
    return 0;
  }
  else
  {
    if (trie->alphabet[letter] == NULL) {
      trie->alphabet[letter] = malloc(sizeof(Trie));

      if (trie->alphabet[letter] == NULL) {
        return 1;
      }
    }

    return TrieInsert(trie->alphabet[letter], ++name);
  }
}

/**
 * Lists all strings inside the Trie.
 *
 * Returns nothing.
 */
bool TriePresent(Trie *trie, char *name) {
  if (*name == '\0' || trie == NULL) {
    if (trie != NULL && trie->exists) {
      return true;
    } else {
      return false;
    }
  }

  int index = *name - 'a';

  if (trie->alphabet[index] != NULL) {
    return TriePresent(trie->alphabet[index], ++name);
  } else {
    return false;
  }
}
