..\..\caffe\build\install\bin\caffe train -solver code/mobilenet-dim512/sphereface10_solver.prototxt -gpu 0
#..\..\caffe\build\install\bin\caffe train -solver code/dim256/sphereface06_solver.prototxt -gpu 0
#..\..\caffe\build\install\bin\caffe train -solver code/sphereface04_solver.prototxt -snapshot result/sphereface04_model_iter_42000.solverstate -gpu 0
#..\..\caffe\build\install\bin\caffe train -solver code/sphereface04_solver2.prototxt -weights result/sphereface04_model_iter_40000.caffemodel -gpu 0
#..\..\caffe\build\install\bin\caffe train -solver code/sphereface06_solver.prototxt -snapshot result/sphereface06_model_iter_50000.solverstate -gpu 0
#..\..\caffe\build\install\bin\caffe train -solver code/sphereface06_solver2.prototxt -weights result/sphereface06_model_iter_86000.caffemodel -gpu 0
pause

..\..\caffe\build\install\bin\caffe train -solver code/sphereface06_solver.prototxt -gpu 0
..\..\caffe\build\install\bin\caffe train -solver code/sphereface06_solver2.prototxt -weights result/sphereface06_model_iter_50000.caffemodel -gpu 0
..\..\caffe\build\install\bin\caffe train -solver code/sphereface08_solver.prototxt -gpu 0
..\..\caffe\build\install\bin\caffe train -solver code/sphereface08_solver2.prototxt -weights result/sphereface08_model_iter_50000.caffemodel -gpu 0
..\..\caffe\build\install\bin\caffe train -solver code/sphereface10_solver.prototxt -gpu 0
..\..\caffe\build\install\bin\caffe train -solver code/sphereface10_solver2.prototxt -weights result/sphereface10_model_iter_50000.caffemodel -gpu 0
pause