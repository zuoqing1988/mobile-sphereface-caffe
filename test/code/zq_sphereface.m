function [ score ] = zq_sphereface( file1, file2 )
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

gpu = 1;
if gpu
   gpu_id = 0;
   caffe.set_mode_gpu();
   caffe.set_device(gpu_id);
else
   caffe.set_mode_cpu();
end
caffe.reset_all();

model   = '../../train/code/sphereface_deploy.prototxt';
weights = '../../train/result/sphereface_model_iter_28000.caffemodel';
face_net     = caffe.Net(model, weights, 'test');



img1 = single(imread(file1));
img2 = single(imread(file2));

tic
feat1 = extractDeepFeature(img1,face_net);
toc
feat2 = extractDeepFeature(img2,face_net);

score = sum(feat1.*feat2)/(norm(feat1,2)*norm(feat2,2));

end

function feature = extractDeepFeature(img, net)
    img     = (img - 127.5)/128;
    img     = permute(img, [2,1,3]);
    img     = img(:,:,[3,2,1]);
    res     = net.forward({img});
    res_    = net.forward({flip(img, 1)});
    feature = double([res{1}; res_{1}]);
end

