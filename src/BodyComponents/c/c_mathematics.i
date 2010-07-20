 %module c_mathematics
 %{
 /* Includes the header in the wrapper code */
 #include "utils/c_mathematics.h"
 %}
 
 /* Parse the header file to generate wrappers */
 %include "utils/c_mathematics.h"
