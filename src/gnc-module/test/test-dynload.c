/*********************************************************************
 * test-dynload.c
 * test the ability to dlopen the gnc_module library and initialize
 * it via dlsym 
 *********************************************************************/

#include <stdio.h>
#ifdef G_OS_WIN32
# undef DLL_EXPORT /* Will cause warnings in ltdl.h if defined */
# define LIBLTDL_DLL_IMPORT
#endif
#include <ltdl.h>
#include <libguile.h>

#include "gnc-module.h"

#ifndef lt_ptr
# define lt_ptr lt_ptr_t
#endif

static void
guile_main(void *closure, int argc, char ** argv)
{
  lt_dlhandle handle;

  lt_dlinit();

  printf("  test-dynload.c: testing dynamic linking of libgncmodule ...");
  handle = lt_dlopen("libgncmodule.la");
  if(handle) {
    lt_ptr ptr = lt_dlsym(handle, "gnc_module_system_init");
    if(ptr) {
      void (* fn)(void) = ptr;
      fn();
      printf(" OK\n");
      exit(0);
    }
    else {
      printf(" failed to find gnc_module_system_init\n");
      exit(-1);
    }
  }
  else {
    printf(" failed to open library.\n");
    printf("%s\n", lt_dlerror());
    exit(-1);
  }
}

int
main(int argc, char ** argv)
{
  scm_boot_guile(argc, argv, guile_main, NULL);
  return 0;
}

