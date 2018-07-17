names = {'C:/Users/ZQ/Desktop/mama.jpg';
    'C:/Users/ZQ/Desktop/baba.jpg';
    'C:/Users/ZQ/Desktop/tuanzi.jpg'};
scores = zeros(3,3);
for i = 0:2
for j = 0:2
scores(i+1,j+1)=zq_test(...
    names{i+1},...
    names{j+1});
end
end