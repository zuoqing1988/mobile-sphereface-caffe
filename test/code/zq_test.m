function [score] = zq_test(file1, file2)



gpu = 1;
if gpu
   gpu_id = 0;
   caffe.set_mode_gpu();
   caffe.set_device(gpu_id);
else
   caffe.set_mode_cpu();
end
caffe.reset_all();


%% mtcnn settings
minSize   = 20;
factor    = 0.85;
threshold = [0.6 0.7 0.9];

matCaffe       = fullfile(pwd, '../../tools/caffe-sphereface/matlab');
pdollarToolbox = fullfile(pwd, '../../tools/toolbox');
MTCNN          = fullfile(pwd, '../../tools/MTCNN_face_detection_alignment/code/codes/MTCNNv1');
addpath(genpath(matCaffe));
addpath(genpath(pdollarToolbox));
addpath(genpath(MTCNN));

mtcnn_modelPath = fullfile(pwd, '../../tools/MTCNN_face_detection_alignment/code/codes/MTCNNv1/model');
mtcnn_Pnet = caffe.Net(fullfile(mtcnn_modelPath, 'det1.prototxt'), ...
                 fullfile(mtcnn_modelPath, 'det1.caffemodel'), 'test');
mtcnn_Rnet = caffe.Net(fullfile(mtcnn_modelPath, 'det2.prototxt'), ...
                 fullfile(mtcnn_modelPath, 'det2.caffemodel'), 'test');
mtcnn_Onet = caffe.Net(fullfile(mtcnn_modelPath, 'det3.prototxt'), ...
                 fullfile(mtcnn_modelPath, 'det3.caffemodel'), 'test');

%% sphere_face    
face_model   = '../../train/code/sphereface_deploy.prototxt';
face_weights = '../../train/result/sphereface_model_iter_28000.caffemodel';
face_net     = caffe.Net(face_model, face_weights, 'test');

%%
img1 = single(imread(file1));
img2 = single(imread(file2));
tic
cropImg1 = detect_face_and_crop(img1, minSize,mtcnn_Pnet, mtcnn_Rnet, mtcnn_Onet, threshold, false,factor);
toc
cropImg2 = detect_face_and_crop(img2, minSize,mtcnn_Pnet, mtcnn_Rnet, mtcnn_Onet, threshold, false,factor);
if isempty(cropImg1)
    disp('cannot find face in image1');
    return ;
end
if isempty(cropImg2)
    disp('cannot find face in image2');
    return ;
end

tic
feat1 = extractDeepFeature(cropImg1,face_net);
toc
feat2 = extractDeepFeature(cropImg2,face_net);

score = sum(feat1.*feat2)/(norm(feat1,2)*norm(feat2,2));

%%
function [cropImg] = detect_face_and_crop(img, minSize, PNet, RNet, ONet, threshold, false, factor)
    [bboxes, landmarks] = detect_face(img, minSize, PNet, RNet, ONet, threshold, false, factor);

    if size(bboxes, 1)>1
       % pick the face closed to the center
       center   = size(img) / 2;
       distance = sum(bsxfun(@minus, [mean(bboxes(:, [2, 4]), 2), ...
                                      mean(bboxes(:, [1, 3]), 2)], center(1:2)).^2, 2);
       [~, Ix]  = min(distance);
       facial5point = reshape(landmarks(:, Ix), [5, 2]);
    elseif size(bboxes, 1)==1
       facial5point = reshape(landmarks, [5, 2]);
    else
       cropImg = [];
       return ;
    end
    
    facial5point = double(facial5point);
    
    imgSize     = [112, 96];
    coord5point = [30.2946, 51.6963;
               65.5318, 51.5014;
               48.0252, 71.7366;
               33.5493, 92.3655;
               62.7299, 92.2041];
    transf   = cp2tform(facial5point, coord5point, 'similarity');
    cropImg  = imtransform(img, transf, 'XData', [1 imgSize(2)],...
                                        'YData', [1 imgSize(1)], 'Size', imgSize);
end


function feature = extractDeepFeature(img, net)
    img     = (img - 127.5)/128;
    img     = permute(img, [2,1,3]);
    img     = img(:,:,[3,2,1]);
    res     = net.forward({img});
    res_    = net.forward({flip(img, 1)});
    feature = double([res{1}; res_{1}]);
end

end