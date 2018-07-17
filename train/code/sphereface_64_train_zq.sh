#!/bin/bash
# Usage:
# ./code/sphereface_train.sh GPU
#
# Example:
# ./code/sphereface_train.sh 0,1,2,3
./../../caffe/build/install/bin/caffe train -solver code/sphereface_64_solver.prototxt -gpu 0 2>&1 | tee result/sphereface_64_train.log