#!/bin/bash
# Usage:
# ./code/sphereface_train.sh GPU
#
# Example:
# ./code/sphereface_train.sh 0,1,2,3
./../../caffe/build/install/bin/caffe train -solver code/sphereface04_solver.prototxt -gpu 0 2>&1 | tee result/sphereface04_train.log
./../../caffe/build/install/bin/caffe train -solver code/sphereface06_solver.prototxt -gpu 0 2>&1 | tee result/sphereface06_train.log
./../../caffe/build/install/bin/caffe train -solver code/sphereface08_solver.prototxt -gpu 0 2>&1 | tee result/sphereface08_train.log
./../../caffe/build/install/bin/caffe train -solver code/sphereface10_solver.prototxt -gpu 0 2>&1 | tee result/sphereface10_train.log