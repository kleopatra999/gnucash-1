/* config.h.  Generated automatically by configure.  */
/********************************************************************\
 * config.h -- configuration defines for xacc                       *
 * Copyright (C) 1997 Robin D. Clark                                *
 *                                                                  *
 * This program is free software; you can redistribute it and/or    *
 * modify it under the terms of the GNU General Public License as   *
 * published by the Free Software Foundation; either version 2 of   *
 * the License, or (at your option) any later version.              *
 *                                                                  *
 * This program is distributed in the hope that it will be useful,  *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of   *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    *
 * GNU General Public License for more details.                     *
 *                                                                  *
 * You should have received a copy of the GNU General Public License*
 * along with this program; if not, write to the Free Software      *
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.        *
 *                                                                  *
 *   Author: Rob Clark                                              *
 * Internet: rclark@cs.hmc.edu                                      *
 *  Address: 609 8th Street                                         *
 *           Huntington Beach, CA 92648-4632                        *
\********************************************************************/


#ifndef __XACC_CONFIG_H__
#define __XACC_CONFIG_H__

/* Are we bigendian */
/* #undef  WORDS_BIGENDIAN */     

/* Do some memory debugging stuff */
#define  DEBUG_MEMORY        0

/* Enable debugging stuff */
#define  USE_DEBUG           0

/* Enable quickfill in register window */
#define  USE_QUICKFILL       1

/* Don't color the balance depending on whether positive
 * or negative */
#define  USE_NO_COLOR        0

/* If configure found libXpm, then use it */
#define  HAVE_XPM            1

/* Use the new XmHTML widdget instead of the old htmlw widget */
#define HAVE_Z               1
#define HAVE_PNG             1
#define HAVE_JPEG            1

#if (HAVE_Z && HAVE_JPEG && HAVE_PNG && HAVE_XPM)
#define USE_HTMLW            0
#define USE_XMHTML           1
#else
#define USE_HTMLW            1
#define USE_XMHTML           0
#endif

#endif
