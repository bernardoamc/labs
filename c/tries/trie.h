#ifndef _TRIE_H_
#define _TRIE_H_

#include <stdbool.h>

typedef struct trie
{
  bool exists;
  struct trie *alphabet[26];
} Trie;

/**
 * Initialize a Trie struct setting its pointers to zero and boolean to false.
 *
 * Returns nothing.
 */
void TrieInitialize(Trie *);

/**
 * Inserts a string inside the Trie.
 *
 * Returns 0 on success or 1 on error.
 */
int TrieInsert(Trie *, char *);

/**
 * Lists all strings inside the Trie.
 *
 * Returns nothing.
 */
bool TriePresent(Trie *, char *);
#endif
