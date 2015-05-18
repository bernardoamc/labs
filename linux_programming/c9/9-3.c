#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <grp.h>
#include <pwd.h>
#include <limits.h>
#include <errno.h>
#include <string.h>

gid_t groupIdFromName(const char *name);
char *groupNameFromId(gid_t gid);
int _initgroups(const char *user, gid_t group);
int getGroups(const char *user, int size, gid_t *groups);

int main(int argc, char *argv[]) {
  char *findUser = "root";
  char *findGroup = "certusers";
  char *group;
  gid_t groupsList[NGROUPS_MAX + 1], gid;
  int groupsSize, i;

  gid = groupIdFromName(findGroup);

  if (gid == -1) {
    printf("Unknown group: %s\n", findGroup);
    exit(EXIT_FAILURE);
  }

  if (_initgroups(findUser, gid) == -1) {
    printf("Couldn't init groups.\n");
    exit(EXIT_FAILURE);
  }

  groupsSize = getgroups(NGROUPS_MAX + 1, groupsList);

  if (groupsSize == -1) {
    printf("Couldn't get groups.\n");
    exit(EXIT_FAILURE);
  }

  printf("Supplementary groups:\n");

  for (i = 0; i < groupsSize; ++i) {
    gid = groupsList[i];
    group = groupNameFromId(gid);

    printf("%d - %s\n", gid, group);
  }

  exit(EXIT_SUCCESS);
}

gid_t groupIdFromName(const char *name) {
  struct group *grp;

  if (name == NULL || name == '\0') {
    return -1;
  }

  grp = getgrnam(name);

  if (grp == NULL) {
    return -1;
  }

  return grp->gr_gid;
}

char * groupNameFromId(gid_t gid) {
  struct group *grp;

  grp = getgrgid(gid);

  if (grp == NULL) {
    return NULL;
  }

  return grp->gr_name;
}

int _initgroups(const char *user, gid_t group) {
  gid_t groupsList[NGROUPS_MAX + 1];
  int groupsSize;

  groupsSize = getGroups(user, NGROUPS_MAX, groupsList);

  if (groupsSize == -1) {
    return -1;
  }

  groupsList[groupsSize++] = group;

  return setgroups(groupsSize, groupsList);
}

int getGroups(const char *user, int size, gid_t *groupsList) {
  struct group *grp;
  size_t maxUsernameLength;
  int groupsFound = 0;
  char **memberList;


  maxUsernameLength = sysconf(_SC_LOGIN_NAME_MAX);

  if (maxUsernameLength == -1) {
    maxUsernameLength = 256;
  }

  setgrent();

  while ((grp = getgrent()) != NULL) {
    memberList = grp->gr_mem;

    while(*memberList != NULL) {
      if (strncmp(user, *memberList, maxUsernameLength) == 0) {
        groupsList[groupsFound++] = grp->gr_gid;
        break;
      }

      ++memberList;
    }
  }

  endgrent();

  return groupsFound;
}
