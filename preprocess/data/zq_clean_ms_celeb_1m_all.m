
src_root = 'ms_celeb_1m';
dst_root = 'ms_celeb_1m_clean';
if ~exist(dst_root,'dir')
    mkdir(dst_root);
end

%% first pass for mkdir
fid = fopen('MS-Celeb-1M_clean_list.txt', 'r');
line = fgets(fid);
count = 0;
last_id = -1;
while ischar(line)
    split1 = strsplit(line, ' ');
    id = str2num(split1{2});
    show = false;
    if id ~= last_id
        show = true;
        split2 = strsplit(split1{1},'/');
        subfolder = sprintf('%06d',id);
        dst_subfolder = fullfile(dst_root,subfolder);
        if ~exist(dst_subfolder,'dir')
            mkdir(dst_subfolder);
        end
    end
    last_id = id;
    line = fgets(fid);
    count = count + 1;
    if show
        disp(sprintf('id=%d count=%d subfolder=%s',id,count,subfolder));
    end
end
fid = fclose(fid);

%% second pass for copy file
fid = fopen('MS-Celeb-1M_clean_list.txt', 'r');
line = fgets(fid);
count = 0;
while ischar(line)
    split1 = strsplit(line, ' ');
    id = str2num(split1{2});
    split2 = strsplit(split1{1},'/');
    src_subfolder = split2{1};
    dst_subfolder = sprintf('%06d',id);
    imgname = split2{2};
    src_filename = fullfile(src_root,src_subfolder,imgname);
    dst_subfolder = fullfile(dst_root,dst_subfolder);
    copyfile(src_filename,dst_subfolder);
    line = fgets(fid);
    count = count + 1;
    if mod(count,1000) == 0
        disp(count)
    end
end
fid = fclose(fid);