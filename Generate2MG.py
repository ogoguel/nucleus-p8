
from pathlib import Path
import os
import sys
from shutil import copyfile

BLOCK_LENGTH = 512

targetDiskImage = "NUCLEUSP8.2mg"
diskFilename = 'NUCLEUS03'
prodosVolume = 'NUCLEUSP8'

nucleusLaunch = "NUCLEUS.SYSTEM#FF2000"
prodos = "PRODOS#FF2000"
nucleusData = "NUCLEUS.DATA#060000"
nucleusLaunchSource = "NucleusLauncher"

if not os.path.isfile(diskFilename):
    print("Could not find a Nucleus Rom03 image as {}".format(diskFilename))
    sys.exit()

def runCadius(_command,_param):
    print(_command)
    cmd = "./cadius {} {} {}".format(_command,targetDiskImage,_param)
    print(cmd)
    os.system(cmd)

def extractData(_data,_block, _nb):
    start = _block * BLOCK_LENGTH
    len  = _nb*BLOCK_LENGTH
    return _data[start:start+len]

def read8(_data, _idx):
    return  _data[_idx] 

def read16(_data, _idx):
    return _data[_idx + 1] << 8 | _data[_idx] 

def read32(_data, _idx):
    return _data[_idx + 3] << 24 | _data[_idx+2] << 16 | _data[_idx + 1] << 8 | _data[_idx] 


print("Reading bytes from "+diskFilename)
data = Path(diskFilename).read_bytes() 

print("Got {} bytes".format(len(data)))
loader9600 = extractData(data,7,1)

resource = bytearray()

print("Extract loading screen")
buffer0A00 = extractData(data,1,1)
buffer0B00 = extractData(data,8,4)
buffer = bytearray()
buffer.extend(buffer0A00[0:256])
buffer.extend(buffer0B00)
buffer.extend(buffer0A00[0:256])

resource.extend(buffer)

print("Extract  blocks")
for i in range(16):
    idx = i*8 + 7
    block = read16(loader9600,idx)
    num = read16(loader9600,idx+2)
    mem = read32(loader9600,idx+4)
    
    buffer = extractData(data,block,num)
    resource.extend(buffer)

print("Write resource file")
data = Path(nucleusData).write_bytes(resource)

runCadius("CREATEVOLUME","{} 800KB".format(prodosVolume))

print("Compile launcher {}".format(nucleusLaunchSource))
cmd = "./Merlin32 -v . {}.s".format(nucleusLaunchSource)
os.system(cmd )

print("Copy {} to {}".format(nucleusLaunchSource,nucleusLaunch))
copyfile(nucleusLaunchSource, nucleusLaunch)

runCadius("ADDFILE","/{} {}".format(prodosVolume,nucleusLaunch))
runCadius("ADDFILE","/{} {}".format(prodosVolume,nucleusData))

runCadius("CATALOG","")