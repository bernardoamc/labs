#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#define MAX_DATA 512

struct Address {
  int id;
  int set;
  char *name;
  char *email;
};

struct Database {
  long max_field_size;
  long max_rows;
  struct Address *rows;
};

struct Connection {
  FILE *file;
  struct Database *db;
};

void Database_close(struct Connection *conn)
{
  if (conn) {
    if(conn->file) fclose(conn->file);

    if(conn->db->rows) {
      int i = 0;

      for (i = 0; i < conn->db->max_rows; i++) {
        free(conn->db->rows[i].name);
        free(conn->db->rows[i].email);
      }

      free(conn->db->rows);
      free(conn->db);
    }

    free(conn);
  }
}

void die(struct Connection *conn, const char *message)
{
  if(errno) {
    perror(message);
  } else {
    printf("ERROR: %s\n", message);
  }

  Database_close(conn);

  exit(1);
};

void Address_print(struct Address *addr)
{
  printf("%d %s %s\n", addr->id, addr->name, addr->email);
}

void Database_load(struct Connection *conn) {

  struct Database *db = conn->db;

  if (fread(&db->max_field_size, sizeof(db->max_field_size), 1, conn->file) != 1) die(conn, "Failed to load database.");
  if (fread(&db->max_rows, sizeof(db->max_rows), 1, conn->file) != 1) die(conn, "Failed to load database.");

  db->rows = malloc(db->max_rows * sizeof(struct Address));
  if (!db->rows) die(conn, "Memory error.");

  int i = 0;
  struct Address *addr = NULL;

  for (i = 0; i < db->max_rows; i++) {
    addr = &db->rows[i];

    addr->name = malloc(db->max_field_size * sizeof(char));
    if (!addr->name) die(conn, "Memory error.");

    addr->email = malloc(db->max_field_size * sizeof(char));
    if (!addr->email) die(conn, "Memory error.");

    if (fread(&addr->id, sizeof(int), 1, conn->file) != 1 ||
        fread(&addr->set, sizeof(int), 1, conn->file) != 1 ||
        fread(addr->name, db->max_field_size * sizeof(char), 1, conn->file) != 1 ||
        fread(addr->email, db->max_field_size * sizeof(char), 1, conn->file) != 1) {
      die(conn, "Failed to load database row");
    }
  }
}

struct Connection *Database_open(const char *filename, char mode)
{
  struct Connection *conn = malloc(sizeof(struct Connection));
  if(!conn) die(conn, "Memory error");

  conn->db = malloc(sizeof(struct Database));
  if(!conn) die(conn, "Memory error");

  if(mode == 'c') {
    conn->file = fopen(filename, "w");
  } else {
    conn->file = fopen(filename, "r+");

    if(conn->file) {
      Database_load(conn);
    }
  }

  if(!conn->file) die(conn, "Failed to open the file");

  return conn;
}

void Database_write(struct Connection *conn)
{
  struct Database *db = conn->db;

  rewind(conn->file);

  if (fwrite(&db->max_field_size, sizeof(db->max_field_size), 1, conn->file) != 1) die(conn, "Failed to write max field size to database.");
  if (fwrite(&db->max_rows, sizeof(db->max_rows), 1, conn->file) != 1) die(conn, "Failed to write max rows database.");

  int i = 0;
  struct Address *addr = NULL;

  for (i = 0; i < db->max_rows; i++) {
    addr = &db->rows[i];

    if (fwrite(&addr->id, sizeof(addr->id), 1, conn->file) != 1 ||
        fwrite(&addr->set, sizeof(addr->set), 1, conn->file) != 1 ||
        fwrite(addr->name, db->max_field_size, 1, conn->file) != 1 ||
        fwrite(addr->email, db->max_field_size, 1, conn->file) != 1) {
      die(conn, "Failed to write row to database.");
    }
  }

  if (fflush(conn->file) == -1) die(conn, "Cannot flush database.");
}

void Database_create(struct Connection *conn, long max_field_size, long max_rows)
{
  conn->db->rows = malloc(max_rows * sizeof(struct Address));
  if(!conn->db->rows) die(conn, "Memory error.");

  conn->db->max_field_size = max_field_size;
  conn->db->max_rows = max_rows;

  int i = 0;
  struct Address *addr = NULL;

  for(i = 0; i < max_rows; i++) {
    addr = &conn->db->rows[i];

    addr->id = i;
    addr->set = 0;

    addr->name = malloc(max_field_size * sizeof(char));
    if(!addr->name) die(conn, "memory error.");
    addr->name[0] = '\0';

    addr->email = malloc(max_field_size * sizeof(char));
    if(!addr->email) die(conn, "memory error.");
    addr->email[0] = '\0';
  }
}

void Database_set(struct Connection *conn, int id, const char *name, const char *email)
{
  struct Address *addr = &conn->db->rows[id];
  if(addr->set) die(conn, "Already set, delete it first");

  addr->set = 1;

  char *res = strncpy(addr->name, name, conn->db->max_field_size);
  if(!res) die(conn, "Name copy failed");
  addr->name[conn->db->max_field_size - 1] = '\0';

  res = strncpy(addr->email, email, conn->db->max_field_size);
  if(!res) die(conn, "Email copy failed");
  addr->email[conn->db->max_field_size -1] = '\0';
}

void Database_get(struct Connection *conn, int id)
{
  struct Address *addr = &conn->db->rows[id];

  if(addr->set) {
    Address_print(addr);
  } else {
    die(conn, "ID is not set");
  }
}

void Database_delete(struct Connection *conn, int id)
{
  struct Address *addr = &conn->db->rows[id];

  addr->set = 0;
  addr->name[0] = '\0';
  addr->email[0] = '\0';
}

void Database_list(struct Connection *conn)
{
  int i = 0;
  struct Database *db = conn->db;
  struct Address *addr = NULL;

  for (i = 0; i < db->max_rows; i++) {
    addr = &db->rows[i];
    if (addr->set) Address_print(addr);
  }
}

int main(int argc, char *argv[])
{
  if(argc < 3) die(NULL, "USAGE: ex17 <dbfile> <action> [action params]");

  char *filename = argv[1];
  char action = argv[2][0];
  struct Connection *conn = Database_open(filename, action);
  int id = 0;
  long max_field_size = 0;
  long max_rows = 0;

  if(argc > 3) id = atoi(argv[3]);
  //if(id >= MAX_ROWS) die(conn, "There's not that many records.");

  switch(action) {
    case 'c':
      max_field_size = (argc >= 4) ? strtol(argv[3], NULL, 10) : 512;
      max_rows = (argc >= 5) ? strtol(argv[4], NULL, 10) : 100;

      Database_create(conn, max_field_size, max_rows);
      Database_write(conn);
      break;

    case 'g':
      if(argc != 4) die(conn, "Need an id to get");

      Database_get(conn, id);
      break;

    case 's':
      if(argc != 6) die(conn, "Need id, name, email to set");

      Database_set(conn, id, argv[4], argv[5]);
      Database_write(conn);
      break;

    case 'd':
      if(argc != 4) die(conn, "Need id to delete");

      Database_delete(conn, id);
      Database_write(conn);
      break;

    case 'l':
      Database_list(conn);
      break;
    default:
      die(conn, "Invalid action, only: c=create, g=get, s=set, d=del, l=list");
  }

  Database_close(conn);

  return 0;
}
