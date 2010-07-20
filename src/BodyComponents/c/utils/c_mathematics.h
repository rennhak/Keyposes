
/*!
 *
 * \file        c_mathematics.h
 * \author      Bjoern Rennhak <bjoern@rennhak.com>
 * \brief       Helper functions which have become handy over time.
 * \note        {
 *                Copyright (c) 2010-2011, Bjoern Rennhak
 *                All rights reserved, see COPYRIGHT file for more details.
 *
 *                o C code version used here is the ANSI C99 standard
 *                o Code style used here is a modified Allman version
 *                o Variable naming convention used here is a variation of the hungarian notation where appropriate
 *                o Explicit shortform coding which the compiler also accepts has been avoided for the sake of clarity and unambiguity
 *                o Documentation tool here used is DoxyGen ( http://www.doxygen.org ) which is licenced under GPLv2
 *                    - Documenting style used here is the QT Style
 *                    - http://www.stack.nl/~dimitri/doxygen/docblocks.html
 *                    - http://www.stack.nl/~dimitri/doxygen/commands.html
 *                o A changelog can be found in the CHANGELOG file if appropriate
 *                o Formatting is optimized for the VIM Text editor
 *                    - configuration is done automatically by reading the details at the end of each file
 *                    - tabs are converted to whitespaces
 *                    - special folding is provided by explicit formatting tags
 *                o Usage of Exuberant CTags, CScope, Lint and Valgrind is supported and encouraged
 * }
 *
 */


#ifndef _C_MATHEMATICS_H_
#  define _C_MATHEMATICS_H_


///! Prototypes
double c_eucledian_distance( double /* x1 */, double /* y1 */, double /* z1 */, double /* x2 */, double /* y2 */, double /* z2 */ );

#endif

// vim:ts=2:tw=100:wm=100
