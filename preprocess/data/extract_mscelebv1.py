import base64
import struct
import os
import io

filename = "MsCelebV1-Faces-Aligned.tsv"
outputDir = "ms_celeb_1m"

def readline(line):
    fields = line.split("\t")
    if len(fields) != 7:
        return 0,0,0,0,0,0,0,0
    MID,ImageSearchRank,ImageURL,PageURL,FaceID,FaceRectangle,FaceData=fields
    rect=struct.unpack("ffff",base64.b64decode(FaceRectangle))
    return 1,MID,ImageSearchRank,ImageURL,PageURL,FaceID,rect,base64.b64decode(FaceData)

def writeImage(filename,data):
    with open(filename,"wb") as f:
        f.write(data)
		
with io.open(filename, 'r', encoding="utf-8") as f:
    i = 0
    for line in f:
        flag = 1
        flag,MID,ImageSearchRank,ImageURL,PageURL,FaceID,rect,FaceData=readline(line)
        if flag:
            img_dir=os.path.join(outputDir,MID)
            if not os.path.exists(img_dir):
                os.mkdir(img_dir)
            img_name="%s-%s"%(ImageSearchRank,FaceID)+".jpg"
            writeImage(os.path.join(img_dir,img_name),FaceData)
		
        i+=1
        if i%1000==0:
            print(i,"imgs finished")