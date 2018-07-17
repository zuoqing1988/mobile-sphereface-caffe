

prefix = 'ms_celeb_1m_clean';

%% collect data
folder = fullfile(pwd, prefix);
name = prefix;
subFolders = struct2cell(dir(folder))';
subFolders = subFolders(3:end, 1);
files      = cell(size(subFolders));
for i = 1:length(subFolders)
    if mod(i,100) == 0
        fprintf('%s --- Collecting the %dth folder (total %d) ...\n', name, i, length(subFolders));
    end
    subList  = struct2cell(dir(fullfile(folder, subFolders{i}, '*.jpg')))';
    files{i} = fullfile(folder, subFolders{i}, subList(:, 1));
end
files      = vertcat(files{:});
dataset    = cell(size(files));
dataset(:) = {name};
trainList       = cell2struct([files dataset], {'file', 'dataset'}, 2);


%% mtcnn settings
minSize   = 20;
factor    = 0.85;
threshold = [0.6 0.7 0.9];

%% add toolbox paths
matCaffe       = fullfile(pwd, 'F:/Code/caffe/build/install/matlab');
pdollarToolbox = fullfile(pwd, '../../tools/toolbox');
MTCNN          = fullfile(pwd, '../../tools/MTCNN_face_detection_alignment/code/codes/MTCNNv1');
addpath(genpath(matCaffe));
addpath(genpath(pdollarToolbox));
addpath(genpath(MTCNN));

%% caffe settings
gpu = 1;
if gpu
   gpu_id = 0;
   caffe.set_mode_gpu();
   caffe.set_device(gpu_id);
else
   caffe.set_mode_cpu();
end
caffe.reset_all();
modelPath = fullfile(pwd, '../../tools/MTCNN_face_detection_alignment/code/codes/MTCNNv1/model');
PNet = caffe.Net(fullfile(modelPath, 'det1.prototxt'), ...
                 fullfile(modelPath, 'det1.caffemodel'), 'test');
RNet = caffe.Net(fullfile(modelPath, 'det2.prototxt'), ...
                 fullfile(modelPath, 'det2.caffemodel'), 'test');
ONet = caffe.Net(fullfile(modelPath, 'det3.prototxt'), ...
                 fullfile(modelPath, 'det3.caffemodel'), 'test');

%% face and facial landmark detection
dataList = trainList;
for i = 1:length(dataList)
    fprintf('detecting the %dth image...\n', i);
    % load image
    img = imread(dataList(i).file);
    if size(img, 3)==1
       img = repmat(img, [1,1,3]);
    end
    % detection
    [bboxes, landmarks] = detect_face(img, minSize, PNet, RNet, ONet, threshold, false, factor);

    if size(bboxes, 1)>1
       % pick the face closed to the center
       center   = size(img) / 2;
       distance = sum(bsxfun(@minus, [mean(bboxes(:, [2, 4]), 2), ...
                                      mean(bboxes(:, [1, 3]), 2)], center(1:2)).^2, 2);
       [~, Ix]  = min(distance);
       dataList(i).facial5point = reshape(landmarks(:, Ix), [5, 2]);
    elseif size(bboxes, 1)==1
       dataList(i).facial5point = reshape(landmarks, [5, 2]);
    else
       dataList(i).facial5point = [];
    end
	if mod(i,100000) == 0
		save(sprintf('ms_celeb_1m_dataList_%d.mat',i),'dataList');
	end
end
save ms_celeb_1m_dataList.mat dataList

%%
%load('ms_celeb_1m_dataList.mat')
%% alignment settings
imgSize     = [112, 96];
coord5point = [30.2946, 51.6963;
               65.5318, 51.5014;
               48.0252, 71.7366;
               33.5493, 92.3655;
               62.7299, 92.2041];

%% face alignment
for i = 1:length(dataList)
    fprintf('aligning the %dth image...\n', i);
    if isempty(dataList(i).facial5point)
       continue;
    end
    dataList(i).facial5point = double(dataList(i).facial5point);
    % load and crop image
    img      = imread(dataList(i).file);
    transf   = cp2tform(dataList(i).facial5point, coord5point, 'similarity');
    cropImg  = imtransform(img, transf, 'XData', [1 imgSize(2)],...
                                        'YData', [1 imgSize(1)], 'Size', imgSize);
    % save image
    [sPathStr, name, ext] = fileparts(dataList(i).file);
    tPathStr = strrep(sPathStr, dataList(i).dataset, [dataList(i).dataset '-112X96']);
    if ~exist(tPathStr, 'dir')
       mkdir(tPathStr)
    end
    imwrite(cropImg, fullfile(tPathStr, [name, '.jpg']), 'jpg');
end

%%

folder    = fullfile(pwd, [prefix '-112X96']);
subFolder = struct2cell(dir(folder))';
subFolder = subFolder(3:end, 1);


% create the list for trianing
fid = fopen([prefix '-112X96.txt'], 'w');
count = 0;
for i = 1:length(subFolder)
    fprintf('%dth folder (total %d, valid count %d) ...\n', i, length(subFolder),count);
    subList   = struct2cell(dir(fullfile(folder, subFolder{i}, '*.jpg')))';
    fileNames = fullfile(folder, subFolder{i}, subList(:, 1));
    if length(fileNames) > 5 
        for j = 1:length(fileNames)
            fprintf(fid, '%s %d\n', fileNames{j}, count);
        end
        count = count + 1;
    end
end
fclose(fid);



