#!/bin/sh

unset DISPLAY
./home/mh/ml/bin/matlab > matlab.out 2>&1 << EOF
cd /home/mh/ml/work
frenet
exit
EOF

cd /home/mh/ml/work
chmod 644 * 
