#include <unistd.h>
#include <apr_errno.h>
#include <apr_file_io.h>

#include "db.h"
#include "bstrlib.h"
#include "dbg.h"

static FILE *DB_open(const char *path, const char *mode)
{
  return fopen(path, mode);
}

static void DB_close(FILE *db)
{
  fclose(db);
}

static bstring DB_load()
{
  FILE *db = NULL;
  bstring data = NULL;

  db = DB_open(DB_FILE, "r");
  check(db, "Failed to open database: %s", DB_FILE);

  data = bread((bNread)fread, db); // bNRead is a pointer to a function, so fread is a pointer to function.
  check(data, "Failed to read from db file: %s", DB_FILE);

  DB_close(db);
  return data;

error:
  if(db) DB_close(db);
  if(data) bdestroy(data);
  return NULL;
}

int DB_update(const char *url)
{
  if(DB_find(url)) {
    log_info("Already recorded as installed: %s", url);
  }

  FILE *db = DB_open(DB_FILE, "a+");
  check(db, "Failed to open DB file: %s", DB_FILE);

  bstring line = bfromcstr(url); // Create a new bstring and copy url into it
  bconchar(line, '\n');          // Concatenate the character c to the end of bstring b.
  int rc = fwrite(line->data, blength(line), 1, db);
  check(rc == 1, "Failed to append to the db.");

  return 0;

error:
  if(db) DB_close(db);
  return -1;
}

int DB_find(const char *url)
{
  bstring data = NULL;
  bstring line = bfromcstr(url);
  int res = -1;

  data = DB_load();
  check(data, "Failed to load: %s", DB_FILE);

  // Search for the bstring s2 in s1 starting at position pos and looking in a
  // forward (increasing) direction.  If it is found then it returns with the
  // first position after pos where it is found, otherwise it returns BSTR_ERR.
  if (binstr(data, 0, line) == BSTR_ERR) {
    res = 0;
  } else {
    res = 1;
  }

error:
  if(data) bdestroy(data);
  if(line) bdestroy(line);

  return res;
}

int DB_init()
{
  apr_pool_t *p = NULL;      // Defining a memory pool
  apr_pool_initialize();     // Setup all internal structures
  apr_pool_create(&p, NULL); // Create a new pol.

  if(access(DB_DIR, W_OK | X_OK) == -1) {

    // Creates a new directory on the file system, but behaves like 'mkdir -p'.
    // Creates intermediate directories as required. No error will be reported if PATH already exists.
    apr_status_t rc = apr_dir_make_recursive(
      DB_DIR,
      APR_UREAD | APR_UWRITE | APR_UEXECUTE |
      APR_GREAD | APR_GWRITE | APR_GEXECUTE,
      p
    );

    check(rc == APR_SUCCESS, "Failed to make database dir: %s", DB_DIR);
  }

  if(access(DB_FILE, W_OK)) {
    FILE *db = DB_open(DB_FILE, "w");
    check(db, "Cannot open database: %s", DB_FILE);
    DB_close(db);
  }

  // Free a pool of memory
  apr_pool_destroy(p);
  return 0;

error:
  apr_pool_destroy(p);
  return -1;
}

/*
 * A bstring is a structure like:
 *
 * struct tagbstring {
 *   int mlen;                  - lower bound for the memory allocated for the data field
 *   int slen;                  - the exact length for the bstring
 *   unsigned char * data;      - single contiguous buffer of unsigned chars
 * };
 *
 */
int DB_list()
{
  bstring data = DB_load();
  check(data, "Failed to read load: %s", DB_FILE);

  printf("%s", bdata(data));  // bdata returns the data part of the bstring
  bdestroy(data);             // free a bstring
  return 0;

error:
  return -1;
}
