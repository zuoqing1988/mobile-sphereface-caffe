function [  ] = zq_get_list_for_training( prefix, thresh_num )

if isempty(thresh_num)
    thresh_num = 6;
end

folder    = fullfile(pwd, [prefix '-112X96']);
subFolder = struct2cell(dir(folder))';
subFolder = subFolder(3:end, 1);


% create the list for trianing
fid = fopen(sprintf('%s-%d%s',prefix, thresh_num, '-112X96.txt'), 'w');
count = 0;
for i = 1:length(subFolder)
    fprintf('%dth folder (total %d, valid count %d) ...\n', i, length(subFolder),count);
    subList   = struct2cell(dir(fullfile(folder, subFolder{i}, '*.jpg')))';
    fileNames = fullfile(folder, subFolder{i}, subList(:, 1));
    if length(fileNames) >= thresh_num
        for j = 1:length(fileNames)
            fprintf(fid, '%s %d\n', fileNames{j}, count);
        end
        count = count + 1;
    end
end
fclose(fid);

end

